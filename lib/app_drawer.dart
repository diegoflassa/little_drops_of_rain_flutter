import 'dart:async';
import 'dart:core';
import 'dart:ui';

// ignore: import_of_legacy_library_into_null_safe
import 'package:configurable_expansion_tile/configurable_expansion_tile.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:little_drops_of_rain_flutter/data/dao/users_dao.dart';
import 'package:little_drops_of_rain_flutter/data/entities/user.dart' as my_app;
import 'package:little_drops_of_rain_flutter/enums/element_type.dart';
import 'package:little_drops_of_rain_flutter/helpers/constants.dart';
import 'package:little_drops_of_rain_flutter/helpers/dialogs.dart';
import 'package:little_drops_of_rain_flutter/helpers/helper.dart';
import 'package:little_drops_of_rain_flutter/helpers/logged_user.dart';
import 'package:little_drops_of_rain_flutter/helpers/my_logger.dart';
import 'package:little_drops_of_rain_flutter/i18n/app_localizations.dart';
import 'package:little_drops_of_rain_flutter/models/app_drawer_model.dart';
import 'package:little_drops_of_rain_flutter/real_main.dart';
import 'package:little_drops_of_rain_flutter/resources/resources.dart';
import 'package:little_drops_of_rain_flutter/routing/routes.dart';
import 'package:pedantic/pedantic.dart';
import 'package:states_rebuilder/states_rebuilder.dart';


class AppDrawer extends StatefulWidget {
  const AppDrawer({
    Key? key,
    this.isConnected = true,
  }) : super(key: key);

  final bool isConnected;

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

// 🚀Global Functional Injection
// This state will be auto-disposed when no longer used, and also testable and mockable.
final appDrawerModel = RM.inject<AppDrawerModel>(
  () => AppDrawerModel(),
  undoStackLength: Constants.DEFAULT_UNDO_STACK_LENGTH,
  //Called after new state calculation and just before state mutation
  middleSnapState: (middleSnap) {
    //Log all state transition.
    MyLogger().logger.i(middleSnap.currentSnap);
    MyLogger().logger.i(middleSnap.nextSnap);

    MyLogger().logger.i('');
    middleSnap.print(preMessage: '[AppDrawerModel]'); //Build-in logger
    //Can return another state
  },
  onDisposed: (state) => MyLogger().logger.i('[AppDrawerModel]Disposed'),
);

class _AppDrawerState extends State<AppDrawer> {
  // ignore: cancel_subscriptions
  late StreamSubscription<my_app.User?> _unsubscribe;
  String _buildNumber = '0';

  final Image _placeholder = const Image(
      width: Constants.APP_DRAWER_AVATAR_DEFAULT_WIDTH,
      height: Constants.APP_DRAWER_AVATAR_DEFAULT_HEIGHT,
      image: AssetImage(Images.littleDropsOfRainIcon));

  var _isIcnSetLangPtDisabled = false;
  var _isIcnSetLangEnDisabled = false;

  Future<void> setLocaleButtonState() async {
    if (MyApp.locale.languageCode == 'pt') {
      _isIcnSetLangEnDisabled = false;
      _isIcnSetLangPtDisabled = true;
    } else {
      _isIcnSetLangEnDisabled = true;
      _isIcnSetLangPtDisabled = false;
    }
  }

  @override
  void initState() {
    super.initState();
    // Exhaustively handle all four status
    On.all(
      // If is Idle
      onIdle: () => MyLogger().logger.i('[AppDrawerModel]Idle'),
      // If is waiting
      onWaiting: () => MyLogger().logger.i('[AppDrawerModel]Waiting'),
      // If has error
      onError: (dynamic err, refresh) =>
          MyLogger().logger.e('[AppDrawerModel]Error:$err. Refresh:$refresh'),
      // If has Data
      onData: () => MyLogger().logger.i('[AppDrawerModel]Data'),
    );

    final auth = FirebaseAuth.instance;
    loadVersionNumber();
    setLocaleButtonState();

    LoggedUser().addListener(_loggedUserListener);
    _unsubscribe = auth.authStateChanges().listen(
      (user) async {
        await checkForLoggedUser(user);
      },
    ) as StreamSubscription<my_app.User?>;
    if (kIsWeb) {
      _loggedUserListener();
    }
    super.initState();
  }

  Future<void> checkForLoggedUser(User? user) async {
    final userFromFirebase = Helper.firebaseUserToUser(user);
    if (userFromFirebase != null) {
      LoggedUser().user = await UsersDao().getByEmail(userFromFirebase.email);
    } else {
      LoggedUser().user = null;
    }
    if (LoggedUser().hasUser()) {
      unawaited(_getUserImage(LoggedUser().user!!));
    }
  }

  @override
  void dispose() {
    _unsubscribe.cancel();
    LoggedUser().removeListener(_loggedUserListener);
    super.dispose();
  }

  Future<void> loadVersionNumber() async {
    _buildNumber = await rootBundle.loadString('assets/version.properties');
    MyLogger()
        .logger
        .i('[loadVersionNumber]Got version.properties= $_buildNumber');
    if (_buildNumber.split('=').length == 2) {
      setState(() {
        _buildNumber = _buildNumber.split('=')[1];
      });
    }
    return Future.value(null);
  }

  Future<void> _loggedUserListener() async {
    if (LoggedUser().hasUser()) {
      if (!appDrawerModel.state.isUserLogged) {
        setState(() {
          _getUserImage(LoggedUser().user!);
          appDrawerModel.state.isUserLogged = true;
          if (!appDrawerModel.state.hasShownUserLoggedInMessage) {
            appDrawerModel.state.hasShownUserLoggedInMessage = true;
            Helper.showSnackBar(
                context, AppLocalizations.of(context).userLoggedIn);
          }
        });
        MyLogger().logger.i('User is signed in!');
      }
    } else {
      if (appDrawerModel.state.isUserLogged) {
        if (appDrawerModel.state.hasShownUserLoggedInMessage) {
          setState(() {
            appDrawerModel.state.imgUser = null;
            appDrawerModel.state.isUserLogged = false;
          });
          appDrawerModel.state.hasShownUserLoggedInMessage = false;
          Helper.showSnackBar(
              context, AppLocalizations.of(context).userLoggedOut);
          MyLogger().logger.i('User is currently signed out!');
        }
      }
    }
  }

  void _showImageUser() {
    appDrawerModel.state.imgUser = IconButton(
      iconSize: Constants.APP_DRAWER_AVATAR_DEFAULT_ICON_SIZE,
      icon: ClipOval(
        child: appDrawerModel.state.avatar,
      ),
      onPressed: () {
        Navigator.of(context).pushNamed(Routes.myProfile);
      },
    );
  }

  Future<void> _getUserImage(my_app.User user) async {
    final metadata = LoggedUser().hasUser()
        ? await LoggedUser().user!.getImageMetaData()
        : null;
    String? filePath;
    if (metadata != null) {
      filePath =
          metadata.customMetadata![Constants.FILE_METADATA_KEY_FILE_PATH];
    }
    if (user.imageUrl != null &&
        !appDrawerModel.state.isGettingImage &&
        (appDrawerModel.state.originalFilePath != filePath ||
            !appDrawerModel.state.gotImage) &&
        user.imageUrl!.path.isNotEmpty) {
      appDrawerModel.state.isGettingImage = true;
      appDrawerModel.state.avatar = const SizedBox(
          width: Constants.APP_DRAWER_AVATAR_DEFAULT_WIDTH,
          height: Constants.APP_DRAWER_AVATAR_DEFAULT_HEIGHT,
          child: CircularProgressIndicator());
      _showImageUser();
      await user.getImageData().then((value) => {
            if (value != null && value.isNotEmpty)
              {
                if (mounted)
                  {
                    setState(() {
                      appDrawerModel.state.originalFilePath = filePath;
                      appDrawerModel.state.avatar = Image.memory(
                        value,
                        width: Constants.APP_DRAWER_AVATAR_DEFAULT_WIDTH,
                        height: Constants.APP_DRAWER_AVATAR_DEFAULT_HEIGHT,
                      );
                      _showImageUser();
                      appDrawerModel.state.gotImage = true;
                      appDrawerModel.state.isGettingImage = false;
                    })
                  }
              }
            else
              {appDrawerModel.state.isGettingImage = false}
          });
      if (!appDrawerModel.state.gotImage) {
        appDrawerModel.state.avatar = const Image(
            width: Constants.APP_DRAWER_AVATAR_DEFAULT_WIDTH,
            height: Constants.APP_DRAWER_AVATAR_DEFAULT_HEIGHT,
            image: AssetImage(Images.littleDropsOfRainIcon));
        _showImageUser();
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Constants.DEFAULT_DRAWER_WIDTH,
      child: Drawer(
        elevation: 20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(
              child: _createHeader(),
            ),
            Expanded(
              child: ListView(
                physics: const ClampingScrollPhysics(),
                children: [
                  if (widget.isConnected)
                    _createDrawerItem(
                      icon: const Icon(FontAwesome5.user_tie).icon,
                      text: appDrawerModel.state.isUserLogged
                          ? AppLocalizations.of(context).logout
                          : AppLocalizations.of(context).login,
                      onTap: () async {
                        unawaited(loginLogout());
                      },
                    ),
                  if (widget.isConnected) const Divider(),
                  _createDrawerItem(
                    icon: Icons.home,
                    text: AppLocalizations.of(context).home,
                    onTap: () => Navigator.pushNamed(context, Routes.home),
                  ),
                  const Divider(),
                  _createDrawerGroupHeroes(),
                  if (LoggedUser().hasUser() && widget.isConnected)
                    const Divider(),
                  if (LoggedUser().hasUser() && widget.isConnected)
                    _createDrawerItem(
                      text: AppLocalizations.of(context).myProfile,
                      onTap: (LoggedUser().hasUser())
                          ? () async => {
                                await Navigator.pushNamed(
                                    context, Routes.myProfile),
                              }
                          : null,
                    ),
                  const Divider(),
                  _createDrawerGroupInstitutional(),
                ],
              ),
            ),
            SizedBox(
              child: ListTile(
                title: Text('v0.0.0-alpha+$_buildNumber'),
              ),
            ),
            const SizedBox(height: 30, width: 1),
          ],
        ),
      ),
    );
  }

  Future<void> loginLogout() async {
    if (appDrawerModel.state.isUserLogged) {
      final ret = await Dialogs.showLogoffConfirmationDialog(context);
      if (ret == Dialogs.LOGOFF_DIALOG_RET_YES) {
        if (!kIsWeb) {
          try {
            final googleSignIn = GoogleSignIn();
            await googleSignIn.signOut();
          } catch (ex) {
            MyLogger().logger.e(ex.toString());
          }
        }
        await FirebaseAuth.instance.signOut();
        setState(() {
          LoggedUser().user = null;
          appDrawerModel.state.isUserLogged = false;
          appDrawerModel.state.gotImage = false;
        });
        Future.delayed(
            const Duration(milliseconds: Constants.DEFAULT_DELAY_TO_GO_TO_HOME),
            () {
          unawaited(Navigator.of(context).pushNamed(Routes.home));
        });
      }
    } else {
      unawaited(Navigator.pushNamed(context, Routes.login));
    }
  }

  ConfigurableExpansionTile _createDrawerGroupHeroes() {
    return ConfigurableExpansionTile(
      header: Expanded(
        child: Container(
          padding:
              const EdgeInsets.all(Constants.DEFAULT_EDGE_INSETS_ALL_QUARTER),
          child: Text(AppLocalizations.of(context).products),
        ),
      ),
      animatedWidgetFollowingHeader: const Icon(
        Icons.expand_more,
        color: Constants.DEFAULT_EXPANSION_TILE_ARROW_COLOR,
      ),
      children: <Widget>[
        if (LoggedUser().hasUser())
          _createDrawerItem(
            text: AppLocalizations.of(context).myProducts,
            onTap: (LoggedUser().hasUser())
                ? () => {
                      Navigator.pushNamed(
                          context,
                          Routes.getParameterizedRouteByViewElements(
                              ElementType.PRODUCT,
                              myElements: true)),
                    }
                : () {},
          ),
      ],
    );
  }

  ConfigurableExpansionTile _createDrawerGroupInstitutional() {
    return ConfigurableExpansionTile(
      header: Expanded(
        child: Container(
          padding:
              const EdgeInsets.all(Constants.DEFAULT_EDGE_INSETS_ALL_QUARTER),
          child: Text(AppLocalizations.of(context).institutional),
        ),
      ),
      animatedWidgetFollowingHeader: const Icon(
        Icons.expand_more,
        color: Constants.DEFAULT_EXPANSION_TILE_ARROW_COLOR,
      ),
      children: <Widget>[
        _createDrawerItem(
          icon: const Icon(FontAwesome5.user_tie).icon,
          text: AppLocalizations.of(context).about,
          onTap: () => {
            Navigator.pushNamed(context, Routes.about),
          },
        ),
      ],
    );
  }

  Widget _createHeader() {
    final icnBtnLogin = IconButton(
      icon: const Icon(Icons.login),
      onPressed: () => Navigator.pushNamed(context, Routes.login),
    );

    final icnBtnLogout = IconButton(
        icon: const Icon(Icons.logout),
        onPressed: () async {
          unawaited(loginLogout());
        });

    void _onPressedIcnSetLangEn() {
      MyApp.setLocale(context, const Locale('en'));
      setLocaleButtonState();
    }

    final icnSetLangEn = IconButton(
      icon: const Image(image: AssetImage('assets/images/flags/us-square.png')),
      onPressed: _isIcnSetLangEnDisabled ? null : _onPressedIcnSetLangEn,
    );
    void _onPressedIcnSetLangPt() {
      MyApp.setLocale(context, const Locale('pt'));
      setLocaleButtonState();
    }

    final icnSetLangPt = IconButton(
      icon: const Image(image: AssetImage('assets/images/flags/br-square.png')),
      onPressed: _isIcnSetLangPtDisabled ? null : _onPressedIcnSetLangPt,
    );

    return SizedBox(
      height: Constants.DEFAULT_DRAWER_HEADER_HEIGHT,
      child: DrawerHeader(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Align(
              alignment: Alignment.topRight,
              child: Row(children: <Widget>[
                if (widget.isConnected)
                  SizedBox(
                    child: appDrawerModel.state.isUserLogged
                        ? icnBtnLogout
                        : icnBtnLogin,
                  ),
                const Spacer(),
                SizedBox(
                  child: icnSetLangPt,
                ),
                SizedBox(
                  child: icnSetLangEn,
                ),
              ]),
            ),
            const SizedBox(
              height: 15,
            ),
            Row(
              children: [
                if (appDrawerModel.state.isUserLogged &&
                    appDrawerModel.state.imgUser != null)
                  appDrawerModel.state.imgUser!
                else
                  _placeholder,
                Text(
                    appDrawerModel.state.isUserLogged
                        ? LoggedUser().user!.getIdentification()
                        // ignore: use_build_context_synchronously
                        : AppLocalizations.of(context).appName,
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _createDrawerItem(
      {IconData? icon, String text = '', GestureTapCallback? onTap}) {
    return InkWell(
      child: ListTile(
        dense: true,
        title: Row(
          children: <Widget>[
            Icon(icon),
            Padding(
              padding: const EdgeInsets.only(
                  left: Constants.DEFAULT_EDGE_INSETS_LEFT),
              child: Text(text),
            )
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
