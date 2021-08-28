import 'dart:io';

// ignore: import_of_legacy_library_into_null_safe
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_svg/flutter_svg.dart';
import 'package:little_drops_of_rain_flutter/data/dao/users_dao.dart';
import 'package:little_drops_of_rain_flutter/helpers/constants.dart';
import 'package:little_drops_of_rain_flutter/helpers/helper.dart';
import 'package:little_drops_of_rain_flutter/helpers/logged_user.dart';
import 'package:little_drops_of_rain_flutter/helpers/my_logger.dart';
import 'package:little_drops_of_rain_flutter/i18n/app_localizations.dart';
import 'package:little_drops_of_rain_flutter/models/credential_model.dart';
import 'package:little_drops_of_rain_flutter/real_main.dart';
import 'package:little_drops_of_rain_flutter/routing/routes.dart';
import 'package:pedantic/pedantic.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:shared_preferences/shared_preferences.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:validated/validated.dart' as validate;

class EmailPasswordSignInPage extends StatefulWidget {
  const EmailPasswordSignInPage({Key? key}) : super(key: key);
  static const routeName = '/EmailPasswordSignInPage';

  @override
  _EmailPasswordSignInPageState createState() =>
      _EmailPasswordSignInPageState();
}

enum PageMode { SIGN_IN, SIGN_UP, RESET, CONFIRM_CODE, UNKNOWN }

// 🚀Global Functional Injection
// This state will be auto-disposed when no longer used, and also testable and mockable.
final model = RM.inject<CredentialModel>(
  () => CredentialModel(),
  undoStackLength: Constants.DEFAULT_UNDO_STACK_LENGTH,
  //Called after new state calculation and just before state mutation
  middleSnapState: (middleSnap) {
    //Log all state transition.
    MyLogger().logger.i(middleSnap.currentSnap);
    MyLogger().logger.i(middleSnap.nextSnap);

    MyLogger().logger.i('');
    middleSnap.print(preMessage: '[CredentialModel]'); //Build-in logger
    //Can return another state
  },
  onDisposed: (state) => MyLogger().logger.i('[CredentialModel]Disposed'),
);

class _EmailPasswordSignInPageState extends State<EmailPasswordSignInPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _resetCodeController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController =
      TextEditingController();
  final _scrollController = ScrollController(initialScrollOffset: 5);
  bool _success = false;
  bool _attemptedSignIn = false;
  String _userEmail = '';
  String _buttonText = '';
  String _errorMessage = '';
  bool _rememberMe = true;
  bool _gotPageMode = false;
  bool _processing = false;
  PageMode _pageMode = PageMode.SIGN_IN;
  SharedPreferences? _prefs;
  bool _obscureText = true;
  late Widget _widgetEyeSlash;
  late Widget _widgetEye;

  @override
  void initState() {
    super.initState();

    // Exhaustively handle all four status
    On.all(
      // If is Idle
      onIdle: () => MyLogger().logger.i('[CredentialModel]Idle'),
      // If is waiting
      onWaiting: () => MyLogger().logger.i('[CredentialModel]Waiting'),
      // If has error
      onError: (dynamic err, refresh) =>
          MyLogger().logger.e('[CredentialModel]Error:$err. Refresh:$refresh'),
      // If has Data
      onData: () => MyLogger().logger.i('[CredentialModel]Data'),
    );

    _widgetEyeSlash = InkWell(
      onTap: () {
        setState(() {
          _obscureText = true;
        });
      },
      child: SvgPicture.asset('assets/images/font_awesome/solid/eye-slash.svg',
          placeholderBuilder: (context) => const SizedBox(
              width: 12,
              height: 12,
              child: FittedBox(
                  fit: BoxFit.scaleDown, child: CircularProgressIndicator())),
          width: 12,
          height: 12),
    );
    _widgetEye = InkWell(
      onTap: () {
        setState(() {
          _obscureText = false;
        });
      },
      child: SvgPicture.asset('assets/images/font_awesome/solid/eye.svg',
          placeholderBuilder: (context) => const SizedBox(
              width: 12,
              height: 12,
              child: FittedBox(
                  fit: BoxFit.scaleDown, child: CircularProgressIndicator())),
          width: 12,
          height: 12),
    );
    SharedPreferences.getInstance().then((prefs) {
      _prefs = prefs;
    });
  }

  @override
  void dispose() {
    _confirmPasswordController.dispose();
    _resetCodeController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  bool _isPageModeSignUp() {
    return _pageMode == PageMode.SIGN_UP;
  }

  bool _isPageModeNotSignUp() {
    return _pageMode != PageMode.SIGN_UP;
  }

  bool _isPageModeSignIn() {
    return _pageMode == PageMode.SIGN_IN;
  }

  bool _isPageModeNotSignIn() {
    return _pageMode != PageMode.SIGN_IN;
  }

  bool _isPageModeConfirmCode() {
    return _pageMode == PageMode.CONFIRM_CODE;
  }

  bool _isPageModeReset() {
    return _pageMode == PageMode.RESET;
  }

  void _getSignButtonText() {
    if (_pageMode == PageMode.SIGN_UP) {
      _buttonText = AppLocalizations.of(context).signUp;
    } else if (_pageMode == PageMode.SIGN_IN) {
      _buttonText = AppLocalizations.of(context).signIn;
    } else if (_pageMode == PageMode.RESET) {
      _buttonText = AppLocalizations.of(context).reset;
    } else if (_pageMode == PageMode.CONFIRM_CODE) {
      _buttonText = AppLocalizations.of(context).enterConfirmationCode;
    } else {
      _buttonText = '';
    }
  }

  Future<PageMode> _getPageMode() async {
    final prefs = MyApp.getSharedPreferences();
    if (!prefs.containsKey(Constants.PREFS_REMEMBER_ME)) {
      await prefs.setBool(Constants.PREFS_REMEMBER_ME, _rememberMe);
    }
    var sentConfirmationCode = prefs.getBool(Constants.PREFS_SENT_CONFIRM_CODE);
    sentConfirmationCode =
        (sentConfirmationCode != null) ? sentConfirmationCode : false;
    if (prefs.containsKey(Constants.PREFS_SENT_CONFIRM_CODE) &&
        sentConfirmationCode) {
      _pageMode = PageMode.CONFIRM_CODE;
    } else {
      var rememberMe = prefs.getBool(Constants.PREFS_REMEMBER_ME);
      rememberMe = (rememberMe != null)
          ? rememberMe
          : Constants.DEFAULT_REMEMBER_ME_VALUE;
      if (_rememberMe) {
        if (prefs.containsKey(Constants.PREFS_USER_EMAIL) &&
            prefs.containsKey(Constants.PREFS_USER_PASSWORD)) {
          _pageMode = PageMode.SIGN_IN;
          // ignore: use_build_context_synchronously
          _buttonText = AppLocalizations.of(context).signIn;
        }
      }
    }
    setState(() {});
    return _pageMode;
  }

  @override
  Widget build(BuildContext context) {
    if (!_gotPageMode && _prefs != null) {
      if (!kIsWeb && Platform.isIOS) {
        _getUser(_prefs!);
        _gotPageMode = true;
      }
    }
    _getSignButtonText();
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints.loose(
              Size(640, MediaQuery.of(context).size.height)),
          child: Material(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: Constants.DEFAULT_EDGE_INSETS_HORIZONTAL),
              child: _processing
                  ? const CircularProgressIndicator()
                  : Form(
                      key: _formKey,
                      child: Scrollbar(
                        controller: _scrollController,
                        isAlwaysShown: kIsWeb,
                        child: ListView(
                          controller: _scrollController,
                          children: <Widget>[
                            ..._getBasicWidgets(),
                            if (_isPageModeSignUp()) ..._getSignUpWidgets(),
                            if (_isPageModeConfirmCode())
                              ..._getConfirmationCodeWidgets(),
                            if (!_isPageModeReset() &&
                                !_isPageModeConfirmCode())
                              if (!kIsWeb && Platform.isIOS)
                                ..._getRememberMeWidgets(),
                            ..._getButtonsWidgets(),
                            const SizedBox(
                                height: Constants.DEFAULT_AD_BOTTOM_SPACE,
                                width: 1),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _getBasicWidgets() {
    final widgets = <Widget>[];
    widgets.add(const SizedBox(
      width: 20,
      height: 20,
    ));
    widgets.add(
        Center(child: Text(AppLocalizations.of(context).emailPasswordSignIn)));
    widgets.add(const SizedBox(
      width: 20,
      height: 20,
    ));
    widgets.add(
      SvgPicture.asset('assets/images/font_awesome/solid/user.svg',
          placeholderBuilder: (context) => const SizedBox(
              width: 100,
              height: 100,
              child: FittedBox(
                  fit: BoxFit.scaleDown, child: CircularProgressIndicator())),
          width: 100,
          height: 100),
    );
    widgets.add(const SizedBox(height: 10));
    widgets.add(TextFormField(
      autofocus: true,
      controller: model.state.idEdit,
      decoration: InputDecoration(
          labelText: !_isPageModeReset()
              ? _isPageModeSignUp()
                  ? AppLocalizations.of(context).emailSignUp
                  : AppLocalizations.of(context).emailSignIn
              : AppLocalizations.of(context).emailReset),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppLocalizations.of(context).pleaseEnterEmail;
        } else if (!validate.isEmail(value)) {
          return AppLocalizations.of(context).invalidEmail;
        }
        return null;
      },
    ));
    if (!_isPageModeReset()) {
      widgets.add(
        TextFormField(
          obscureText: _obscureText,
          controller: model.state.passwordEdit,
          decoration: InputDecoration(
              suffixIcon: (!_obscureText) ? _widgetEyeSlash : _widgetEye,
              labelText: AppLocalizations.of(context).password),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppLocalizations.of(context).pleaseEnterPassword;
            }
            return null;
          },
        ),
      );
    }
    return widgets;
  }

  List<Widget> _getConfirmationCodeWidgets() {
    final widgets = <Widget>[];
    widgets.add(TextFormField(
      obscureText: true,
      controller: _resetCodeController,
      decoration:
          InputDecoration(labelText: AppLocalizations.of(context).resetCode),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppLocalizations.of(context).pleaseEnterResetCode;
        }
        return null;
      },
    ));
    widgets.add(TextFormField(
      obscureText: true,
      controller: _newPasswordController,
      decoration: InputDecoration(
          labelText: AppLocalizations.of(context).confirmPassword),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppLocalizations.of(context).pleaseEnterPassword;
        } else if (_confirmPasswordController.text !=
            model.state.passwordEdit.text) {
          return AppLocalizations.of(context).thePasswordsMustMatch;
        }
        return null;
      },
    ));
    widgets.add(TextFormField(
      obscureText: true,
      controller: _confirmNewPasswordController,
      decoration: InputDecoration(
          labelText: AppLocalizations.of(context).confirmPassword),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppLocalizations.of(context).pleaseEnterPassword;
        } else if (_confirmNewPasswordController.text !=
            _newPasswordController.text) {
          return AppLocalizations.of(context).thePasswordsMustMatch;
        }
        return null;
      },
    ));
    return widgets;
  }

  List<Widget> _getRememberMeWidgets() {
    final widgets = <Widget>[];
    if (!_isPageModeReset()) {
      widgets.add(CheckboxListTile(
        value: _rememberMe,
        onChanged: (isChecked) async {
          final prefs = MyApp.getSharedPreferences();
          await prefs.setBool(Constants.PREFS_REMEMBER_ME, _rememberMe);
          setState(() {
            _rememberMe = isChecked!;
            _getPageMode();
            if (_rememberMe) {
              //_saveUser(prefs);
            } else {
              _removeUser(prefs);
            }
          });
        },
        subtitle: Text(AppLocalizations.of(context).clickToSaveUser),
        title: Text(
          AppLocalizations.of(context).rememberMe,
          style: const TextStyle(fontSize: 14),
        ),
        controlAffinity: ListTileControlAffinity.leading,
        activeColor: Colors.green,
      ));
    }
    return widgets;
  }

  List<Widget> _getSignUpWidgets() {
    final widgets = <Widget>[];
    widgets.add(TextFormField(
      obscureText: true,
      controller: _confirmPasswordController,
      decoration: InputDecoration(
          labelText: AppLocalizations.of(context).confirmPassword),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppLocalizations.of(context).pleaseEnterPassword;
        } else if (_confirmPasswordController.text !=
            model.state.passwordEdit.text) {
          return AppLocalizations.of(context).thePasswordsMustMatch;
        }
        return null;
      },
    ));
    return widgets;
  }

  List<Widget> _getButtonsWidgets() {
    final widgets = <Widget>[];
    widgets.add(Container(
      padding: const EdgeInsets.symmetric(
          vertical: Constants.DEFAULT_EDGE_INSETS_VERTICAL_QUARTER),
      alignment: Alignment.center,
      child: ElevatedButton(
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            await _register();
          }
        },
        child: Text(_buttonText),
      ),
    ));
    if (_isPageModeNotSignIn()) {
      widgets.add(Container(
        padding: const EdgeInsets.symmetric(
            vertical: Constants.DEFAULT_EDGE_INSETS_VERTICAL_QUARTER),
        alignment: Alignment.center,
        child: ElevatedButton(
          onPressed: () async {
            setState(() {
              _pageMode = PageMode.SIGN_IN;
            });
          },
          // ignore: use_build_context_synchronously
          child: Text(AppLocalizations.of(context).alreadyHaveAnAccount),
        ),
      ));
    }
    if (_isPageModeNotSignUp()) {
      widgets.add(Container(
        padding: const EdgeInsets.symmetric(
            vertical: Constants.DEFAULT_EDGE_INSETS_VERTICAL_QUARTER),
        alignment: Alignment.center,
        child: ElevatedButton(
          onPressed: () async {
            setState(() {
              _pageMode = PageMode.SIGN_UP;
            });
          },
          // ignore: use_build_context_synchronously
          child: Text(AppLocalizations.of(context).doesNotHaveAnAccount),
        ),
      ));
    }
    if (_isPageModeConfirmCode()) {
      widgets.add(Container(
        padding: const EdgeInsets.symmetric(
            vertical: Constants.DEFAULT_EDGE_INSETS_VERTICAL_QUARTER),
        alignment: Alignment.center,
        child: ElevatedButton(
          onPressed: (_isPageModeConfirmCode())
              ? () async {
                  setState(() {
                    _pageMode = PageMode.CONFIRM_CODE;
                  });
                }
              : null,
          // ignore: use_build_context_synchronously
          child: Text(AppLocalizations.of(context).enterConfirmationCode),
        ),
      ));
    }
    if (!_isPageModeReset()) {
      widgets.add(Container(
        padding: const EdgeInsets.symmetric(
            vertical: Constants.DEFAULT_EDGE_INSETS_VERTICAL_QUARTER),
        alignment: Alignment.center,
        child: ElevatedButton(
          onPressed: () async {
            setState(() {
              _pageMode = PageMode.RESET;
            });
          },
          child:
              // ignore: use_build_context_synchronously
              Text(mounted ? AppLocalizations.of(context).resetPassword : ''),
        ),
      ));
    }
    if (_attemptedSignIn) {
      widgets.add(Container(
          alignment: Alignment.center,
          child: Text(_success
              // ignore: use_build_context_synchronously
              ? AppLocalizations.of(context).successfullySignInEmail +
                  _userEmail
              // ignore: use_build_context_synchronously
              : '${AppLocalizations.of(context).failedSignIn}:$_errorMessage')));
    }
    return widgets;
  }

  void _getUser(SharedPreferences prefs) {
    if (!prefs.containsKey(Constants.PREFS_REMEMBER_ME)) {
      prefs.setBool(Constants.PREFS_REMEMBER_ME, _rememberMe);
    } else {
      final prefsRememberMe = prefs.getBool(Constants.PREFS_REMEMBER_ME);
      _rememberMe = (prefsRememberMe != null)
          ? prefsRememberMe
          : Constants.DEFAULT_REMEMBER_ME_VALUE;
    }
    if (_rememberMe) {
      if (prefs.containsKey(Constants.PREFS_USER_EMAIL)) {
        var userEmail = prefs.getString(Constants.PREFS_USER_EMAIL);
        userEmail = (userEmail != null) ? userEmail : '';
        model.state.idEdit.text = userEmail;
        if (prefs.containsKey(Constants.PREFS_USER_PASSWORD)) {
          var password = prefs.getString(Constants.PREFS_USER_PASSWORD);
          password = (password != null) ? password : '';
          var userEmail = prefs.getString(Constants.PREFS_USER_EMAIL);
          userEmail = (userEmail != null) ? userEmail : '';
          model.state.idEdit.text = userEmail;
          model.state.passwordEdit.text = password;
          _pageMode = PageMode.SIGN_IN;
        }
      }
    }
  }

  void _saveUser(SharedPreferences prefs) {
    prefs.setString(Constants.PREFS_USER_EMAIL, model.state.idEdit.text);
    prefs.setString(
        Constants.PREFS_USER_PASSWORD, model.state.passwordEdit.text);
  }

  void _removeUser(SharedPreferences prefs) {
    prefs.remove(Constants.PREFS_USER_EMAIL);
    prefs.remove(Constants.PREFS_USER_PASSWORD);
  }

  Future<bool> _register() async {
    setState(() {
      _processing = true;
    });
    _attemptedSignIn = true;
    _errorMessage = '';
    UserCredential? userCredential;
    try {
      if (_isPageModeSignUp()) {
        userCredential = await _auth.createUserWithEmailAndPassword(
          email: model.state.idEdit.text,
          password: model.state.passwordEdit.text,
        );
      } else if (_isPageModeSignIn()) {
        userCredential = await _auth.signInWithEmailAndPassword(
          email: model.state.idEdit.text,
          password: model.state.passwordEdit.text,
        );
      } else if (_isPageModeReset()) {
        await _auth.sendPasswordResetEmail(email: model.state.idEdit.text);
        final prefs = MyApp.getSharedPreferences();
        await prefs.setBool(Constants.PREFS_SENT_CONFIRM_CODE, true);
      } else if (_isPageModeConfirmCode()) {
        await _auth.confirmPasswordReset(
            code: _resetCodeController.text,
            newPassword: _newPasswordController.text);
        final prefs = MyApp.getSharedPreferences();
        await prefs.remove(Constants.PREFS_SENT_CONFIRM_CODE);
      }
      _success = true;
    } on Exception catch (ex) {
      if (!kIsWeb) {
        unawaited(FirebaseCrashlytics.instance.log(ex.toString()));
      }
      MyLogger().logger.e(ex.toString());
      _errorMessage = ex.toString();
      userCredential = null;
    } on Error catch (ex) {
      if (!kIsWeb) {
        unawaited(FirebaseCrashlytics.instance.recordError(ex, ex.stackTrace));
      }
      MyLogger().logger.e(ex.toString());
      _errorMessage = ex.toString();
      userCredential = null;
    }
    if (userCredential != null) {
      if (userCredential.user != null) {
        setState(() {
          _success = true;
          _userEmail = (userCredential!.user!.email != null)
              ? userCredential.user!.email!
              : '';
        });
        final prefs = MyApp.getSharedPreferences();
        if (_rememberMe) {
          _saveUser(prefs);
        } else {
          _removeUser(prefs);
        }
        var user = await UsersDao().getByEmail(userCredential.user!.email!);
        if (user == null) {
          user = Helper.userCredentialToUser(userCredential);
          await UsersDao().add(user);
          if (mounted) {
            await Navigator.of(context).pushNamed(Routes.myProfile);
          }
          _success = true;
        } else {
          _success = false;
        }
        LoggedUser().user = user;
        if (mounted) {
          Navigator.of(context).pop(userCredential);
        }
        _success = true;
      } else {
        _success = false;
      }
    } else {
      _success = false;
    }
    setState(() {
      _success = false;
      _processing = false;
    });
    return _success;
  }
}
