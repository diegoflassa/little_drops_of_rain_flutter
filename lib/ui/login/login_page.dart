// ignore: import_of_legacy_library_into_null_safe
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_facebook_login_web/flutter_facebook_login_web.dart'
    as web;
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_twitter_login/flutter_twitter_login.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:google_sign_in/google_sign_in.dart';
import 'package:little_drops_of_rain_flutter/data/dao/users_dao.dart';
import 'package:little_drops_of_rain_flutter/enums/page_state.dart';
import 'package:little_drops_of_rain_flutter/helpers/constants.dart';
import 'package:little_drops_of_rain_flutter/helpers/helper.dart';
import 'package:little_drops_of_rain_flutter/helpers/logged_user.dart';
import 'package:little_drops_of_rain_flutter/helpers/my_logger.dart';
import 'package:little_drops_of_rain_flutter/i18n/app_localizations.dart';
import 'package:little_drops_of_rain_flutter/routing/routes.dart';
import 'package:little_drops_of_rain_flutter/ui/my_scaffold.dart';
import 'package:little_drops_of_rain_flutter/ui/pages/empty_items_page.dart';
import 'package:little_drops_of_rain_flutter/ui/pages/error_page.dart';
import 'package:little_drops_of_rain_flutter/ui/pages/loading_page.dart';
import 'package:pedantic/pedantic.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({Key? key, this.title = Constants.APP_NAME})
      : super(key: key);

  static Route<dynamic> route() {
    return MaterialPageRoute<dynamic>(builder: (context) => const LoginPage());
  }

  final String? title;
  static const String routeName = '/login';
  static const String routeNameWoBackslash = 'login';

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  PageState _pageState = PageState.UNKNOWN;
  dynamic _lastException;
  static final web.FacebookLoginWeb facebookSignInWeb = web.FacebookLoginWeb();
  static final FacebookLogin facebookSignIn = FacebookLogin();

  @override
  void initState() {
    super.initState();
    _pageState = PageState.INITIALIZING;
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      title: (widget.title != null) ? widget.title : '',
      body: Container(
        color: Colors.white,
        child: Center(
          child: _buildBody(context),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    Widget ret = const EmptyItemsPage();
    switch (_pageState) {
      case PageState.INITIALIZING:
      case PageState.READY:
        ret = IntrinsicWidth(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(
              width: 20,
              height: 20,
            ),
            SvgPicture.asset(
              'assets/images/font_awesome/solid/users.svg',
              placeholderBuilder: (context) => const SizedBox(
                  width: 100,
                  height: 100,
                  child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: CircularProgressIndicator())),
              width: 100,
              height: 100,
            ),
            const SizedBox(height: 50),
            _signInWithEmailPasswordButton(context),
            const SizedBox(height: 5),
            _signInGoogleButton(context),
            const SizedBox(height: 5),
            _signInFacebookButton(context),
            const SizedBox(height: 5),
            _signInTwitterButton(context),
            const SizedBox(height: 50),
          ],
        ));
        break;
      case PageState.LOADING:
        ret = LoadingPage(AppLocalizations.of(context).loading);
        break;
      case PageState.TRANSLATING:
        break;
      case PageState.TRANSLATION_ERROR:
        break;
      case PageState.ERROR:
        ret = ErrorPage(exception: _lastException);
        break;
      case PageState.EMPTY:
        ret = const EmptyItemsPage();
        break;
      case PageState.UNKNOWN:
        ret = const ErrorPage();
        break;
    }
    return ret;
  }

  Future<_HandledLoginResult> _handleLoginResult(
      UserCredential? userCredential) async {
    if (userCredential != null &&
        userCredential.user != null &&
        userCredential.user!.email != null) {
      var user = await UsersDao().getByEmail(userCredential.user!.email!);
      if (user == null) {
        user = Helper.userCredentialToUser(userCredential);
        await UsersDao().add(user);
        LoggedUser().user = user;
        if (mounted) {
          await Navigator.of(context).pushNamed(Routes.myProfile);
        }
        return _HandledLoginResult(result: _Result.SUCCESS);
      } else {
        return _HandledLoginResult(
            result: _Result.ERROR, error: 'User already exists');
      }
    }
    return _HandledLoginResult(
        result: _Result.ERROR, error: 'User credential is null');
  }

  Widget _signInWithEmailPasswordButton(BuildContext context) {
    return SignInButtonBuilder(
      padding: const EdgeInsets.symmetric(
          horizontal: Constants.DEFAULT_EDGE_INSETS_HORIZONTAL),
      text: AppLocalizations.of(context).signInWithPassword,
      icon: Icons.email,
      onPressed: () async {
        final result =
            await Navigator.of(context).pushNamed(Routes.emailPasswordSignIn);
        setState(() {
          _pageState = PageState.LOADING;
        });
        if (result != null) {
          await _handleLoginResult(result as UserCredential);
          if (mounted) {
            await Navigator.of(context).pushReplacementNamed(Routes.home);
          }
        } else {
          if (mounted) {
            Helper.showSnackBar(
                context, AppLocalizations.of(context).errorLoginIn);
          }
        }
      },
      backgroundColor: Colors.blueGrey[700]!,
    );
  }

  void _showLoadingWidget() {
    setState(() {
      _pageState = PageState.LOADING;
    });
  }

  void _hideLoadingWidget() {
    setState(() {
      _pageState = PageState.READY;
    });
  }

  Widget _signInFacebookButton(BuildContext context) {
    return SignInButton(
      Buttons.Facebook,
      padding: const EdgeInsets.symmetric(
          horizontal: Constants.DEFAULT_EDGE_INSETS_HORIZONTAL),
      text: AppLocalizations.of(context).signInWithFacebook,
      onPressed: () async {
        await (kIsWeb ? _signInWithFacebookWeb() : _signInWithFacebook()).then(
          (result) {
            _hideLoadingWidget();
            if (result != null) {
              _handleLoginResult(result);
              Navigator.of(context).pushReplacementNamed(Routes.home);
            } else {
              Helper.showSnackBar(
                  context, AppLocalizations.of(context).errorLoginIn);
            }
          },
        ).onError((error, stackTrace) {
          if (!kIsWeb) {
            FirebaseCrashlytics.instance.recordError(error, stackTrace);
          }
          Helper.showSnackBar(
              context, '${AppLocalizations.of(context).errorLoginIn}: $error');
        });
      },
    );
  }

  Widget _signInGoogleButton(BuildContext context) {
    return SignInButton(
      Buttons.GoogleDark,
      padding: const EdgeInsets.symmetric(
          horizontal: Constants.DEFAULT_EDGE_INSETS_HORIZONTAL),
      text: AppLocalizations.of(context).signInWithGoogle,
      onPressed: () async {
        await _signInWithGoogle().then(
          (result) {
            _hideLoadingWidget();
            if (result != null) {
              _handleLoginResult(result);
              Navigator.of(context).pushReplacementNamed(Routes.home);
            } else {
              Helper.showSnackBar(
                  context, AppLocalizations.of(context).errorLoginIn);
            }
          },
        ).onError((error, stackTrace) {
          if (!kIsWeb) {
            FirebaseCrashlytics.instance.recordError(error, stackTrace);
          }
          Helper.showSnackBar(
              context, '${AppLocalizations.of(context).errorLoginIn}: $error');
        });
      },
    );
  }

  Widget _signInTwitterButton(BuildContext context) {
    return SignInButton(
      Buttons.Twitter,
      padding: const EdgeInsets.symmetric(
          horizontal: Constants.DEFAULT_EDGE_INSETS_HORIZONTAL),
      text: AppLocalizations.of(context).signInWithTwitter,
      onPressed: () async {
        await _signInTwitter().then(
          (result) {
            _hideLoadingWidget();
            if (result != null) {
              _handleLoginResult(result);
              Navigator.of(context).pushReplacementNamed(Routes.home);
            } else {
              Helper.showSnackBar(
                  context, AppLocalizations.of(context).errorLoginIn);
            }
          },
        ).onError((error, stackTrace) {
          if (!kIsWeb) {
            FirebaseCrashlytics.instance.recordError(error, stackTrace);
          }
          Helper.showSnackBar(
              context, '${AppLocalizations.of(context).errorLoginIn}: $error');
        });
      },
    );
  }

  Future<UserCredential?> _signInWithGoogle() async {
    _showLoadingWidget();

    // Trigger the authentication flow
    UserCredential? ret;
    try {
      final googleUser = await GoogleSignIn(
        scopes: [
          'email',
          'https://www.googleapis.com/auth/userinfo.profile',
        ],
      ).signIn();

      if (googleUser != null) {
        final googleAuth = await googleUser.authentication;

        // Create a new credential
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        ) as GoogleAuthCredential;
        // Once signed in, return the UserCredential
        ret = await FirebaseAuth.instance.signInWithCredential(credential);
      }
    } on Exception catch (ex) {
      if (!kIsWeb) {
        unawaited(FirebaseCrashlytics.instance.log(ex.toString()));
      }
      setState(() {
        _lastException = ex;
        _pageState = PageState.ERROR;
      });
    } on Error catch (ex) {
      if (!kIsWeb) {
        unawaited(FirebaseCrashlytics.instance.recordError(ex, ex.stackTrace));
      }
      setState(() {
        _lastException = ex;
        _pageState = PageState.ERROR;
      });
    }
    return ret;
  }

  Future<UserCredential?> _signInWithFacebook() async {
    _showLoadingWidget();

    UserCredential? ret;
    try {
      final result = await facebookSignIn.logIn(['email', 'public_profile']);

      switch (result.status) {
        case FacebookLoginStatus.loggedIn:
          _hideLoadingWidget();
          final accessToken = result.accessToken;
          MyLogger().logger.d(
              'Logged in! Token: ${accessToken.token}. User id: ${accessToken.userId}');
          break;
        case FacebookLoginStatus.cancelledByUser:
          _hideLoadingWidget();
          MyLogger().logger.d('Login cancelled by the user.');
          break;
        case FacebookLoginStatus.error:
          _hideLoadingWidget();
          MyLogger().logger.d('Something went wrong with the login process.\n'
              "Here's the error Facebook gave us: ${result.errorMessage}");
          break;
      }
      final facebookAuthCred =
          FacebookAuthProvider.credential(result.accessToken.token);
      ret = await FirebaseAuth.instance.signInWithCredential(facebookAuthCred);
    } on Exception catch (ex) {
      if (!kIsWeb) {
        unawaited(FirebaseCrashlytics.instance.log(ex.toString()));
      }
      setState(() {
        _lastException = ex;
        _pageState = PageState.ERROR;
      });
    } on Error catch (ex) {
      if (!kIsWeb) {
        unawaited(FirebaseCrashlytics.instance.recordError(ex, ex.stackTrace));
      }
      setState(() {
        _lastException = ex;
        _pageState = PageState.ERROR;
      });
    }
    return ret;
  }

  Future<UserCredential?> _signInWithFacebookWeb() async {
    _showLoadingWidget();

    UserCredential? ret;
    try {
      final result = await facebookSignInWeb.logIn(['email', 'public_profile']);

      switch (result.status) {
        case web.FacebookLoginStatus.loggedIn:
          _hideLoadingWidget();
          final accessToken = result.accessToken;
          MyLogger().logger.d(
              'Logged in! Token: ${accessToken.token}. User id: ${accessToken.userId}');

          await facebookSignInWeb.testApi();
          break;
        case web.FacebookLoginStatus.cancelledByUser:
          _hideLoadingWidget();
          MyLogger().logger.d('Login cancelled by the user.');
          break;
        case web.FacebookLoginStatus.error:
          _hideLoadingWidget();
          MyLogger().logger.d('Something went wrong with the login process.\n'
              "Here's the error Facebook gave us: ${result.errorMessage}");
          break;
      }
      final facebookAuthCred =
          FacebookAuthProvider.credential(result.accessToken.token);
      ret = await FirebaseAuth.instance.signInWithCredential(facebookAuthCred);
    } on Exception catch (ex) {
      if (!kIsWeb) {
        unawaited(FirebaseCrashlytics.instance.log(ex.toString()));
      }
      setState(() {
        _lastException = ex;
        _pageState = PageState.ERROR;
      });
    } on Error catch (ex) {
      if (!kIsWeb) {
        unawaited(FirebaseCrashlytics.instance.recordError(ex, ex.stackTrace));
      }
      setState(() {
        _lastException = ex;
        _pageState = PageState.ERROR;
      });
    }
    return ret;
  }

  Future<UserCredential?> _signInTwitter() async {
    _showLoadingWidget();
    UserCredential? ret;
    try {
      // Create a TwitterLogin instance
      final twitterLogin = TwitterLogin(
        consumerKey: 'PlZ3izQV9I4IoBqdBy39zOl28',
        consumerSecret: 'w2YpnbtHRCevgbV6mOQzyXKL8TuPrVrNHyDSGKkF1o0lctxYWN',
      );

      // Trigger the sign-in flow
      final loginResult = await twitterLogin.authorize();

      // Get the Logged In session
      final twitterSession = loginResult.session;

      // Create a credential from the access token
      final AuthCredential twitterAuthCredential =
          TwitterAuthProvider.credential(
              accessToken: twitterSession.token, secret: twitterSession.secret);

      // Once signed in, return the UserCredential
      ret = await FirebaseAuth.instance
          .signInWithCredential(twitterAuthCredential);
    } on Exception catch (ex) {
      if (!kIsWeb) {
        unawaited(FirebaseCrashlytics.instance.log(ex.toString()));
      }
      setState(() {
        _lastException = ex;
        _pageState = PageState.ERROR;
      });
    } on Error catch (ex) {
      if (!kIsWeb) {
        unawaited(FirebaseCrashlytics.instance.recordError(ex, ex.stackTrace));
      }
      setState(() {
        _lastException = ex;
        _pageState = PageState.ERROR;
      });
    }
    return ret;
  }
}

class _HandledLoginResult {
  _HandledLoginResult({this.result = _Result.UNKNOWN, this.error});

  final _Result result;
  final String? error;
}

enum _Result { SUCCESS, ERROR, UNKNOWN }
