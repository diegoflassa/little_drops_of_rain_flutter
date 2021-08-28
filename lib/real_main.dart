import 'package:devicelocale/devicelocale.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:little_drops_of_rain_flutter/bloc/main_bloc.dart';
import 'package:little_drops_of_rain_flutter/helpers/constants.dart';
import 'package:little_drops_of_rain_flutter/helpers/navigation_service.dart';
import 'package:little_drops_of_rain_flutter/helpers/settings.dart';
import 'package:little_drops_of_rain_flutter/i18n/app_localizations.dart';
import 'package:little_drops_of_rain_flutter/i18n/app_localizations_delegate.dart';
import 'package:little_drops_of_rain_flutter/routing/routes.dart';
import 'package:little_drops_of_rain_flutter/ui/about/about_page.dart';
import 'package:little_drops_of_rain_flutter/ui/cropper/image_crop_widget.dart';
import 'package:little_drops_of_rain_flutter/ui/products/view_products.dart';
import 'package:little_drops_of_rain_flutter/ui/login/email_password_signin_page.dart';
import 'package:little_drops_of_rain_flutter/ui/login/login_page.dart';
import 'package:little_drops_of_rain_flutter/ui/search/search_page.dart';
import 'package:little_drops_of_rain_flutter/ui/settings/settings_page.dart';
import 'package:little_drops_of_rain_flutter/ui/themes/my_app_bar_theme.dart';
import 'package:little_drops_of_rain_flutter/ui/themes/my_button_theme.dart';
import 'package:little_drops_of_rain_flutter/ui/themes/my_color_scheme.dart';
import 'package:little_drops_of_rain_flutter/ui/themes/my_toggle_button_theme.dart';
import 'package:little_drops_of_rain_flutter/ui/users/my_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

void realMain() {
  runApp(MyApp());
}

//Fix for the "page scroll when spacebar is pressed" issue
final shortcuts = WidgetsApp.defaultShortcuts;

late final SharedPreferences _prefs;

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  static Locale locale = const Locale('en', 'US');

  static Future<bool> setLocale(BuildContext context, Locale newLocale) async {
    final state = context.findAncestorStateOfType<_MyAppState>();
    if (state != null) {
      state.changeLanguage(newLocale);
      return true;
    } else {
      return false;
    }
  }

  @override
  _MyAppState createState() => _MyAppState();

  static SharedPreferences getSharedPreferences() {
    return _prefs;
  }
}

class _MyAppState extends State<MyApp> {
  SpecifiedLocalizationDelegate? _localeOverrideDelegate;

  // Toggle this to cause an async error to be thrown during initialization
  // and to test that runZonedGuarded() catches the error
  final _kShouldTestAsyncErrorOnInit = false;

  // Toggle this for testing Crashlytics in your app locally.
  final _kTestingCrashlytics = true;

  // Define an async function to initialize FlutterFire
  Future<void> _initializeFlutterFire() async {
    if (_kTestingCrashlytics) {
      // Force enable crashlytics collection enabled if we're testing it.
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    } else {
      // Else only enable it in non-debug builds.
      // You could additionally extend this to allow users to opt-in.
      await FirebaseCrashlytics.instance
          .setCrashlyticsCollectionEnabled(!kDebugMode);
    }

    // Pass all uncaught errors to Crashlytics.
    final Function? originalOnError = FlutterError.onError;
    FlutterError.onError = (errorDetails) async {
      await FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
      // Forward to original handler.
      if (originalOnError != null) {
        // ignore: avoid_dynamic_calls
        originalOnError(errorDetails);
      }
    };

    if (_kShouldTestAsyncErrorOnInit) {
      await _testAsyncErrorOnInit();
      FirebaseCrashlytics.instance.crash();
    }
  }

  Future<void> _testAsyncErrorOnInit() async {
    Future<void>.delayed(const Duration(seconds: 2), () {
      final list = <int>[];
      // ignore: avoid_print
      print(list[100]);
    });
  }

  static GetIt locator = GetIt.instance;

  void _initializeLocator() {
    locator.registerLazySingleton(() => NavigationService());
  }

  @override
  void initState() {
    if (!kIsWeb) {
      _initializeFlutterFire();
    }
    Devicelocale.currentAsLocale.then(
          (locale) => () {
        if (locale != null) {
          MyApp.locale = locale;
          _localeOverrideDelegate = SpecifiedLocalizationDelegate(MyApp.locale);
        }
      },
    );
    _initializeLocator();
    Settings.applySettings();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final materialApp = _getMaterialApp(context, locale: MyApp.locale);
    return MultiBlocProvider(
      providers: MainBloc.allBlocs(),
      child: materialApp,
    );
  }

  void changeLanguage(Locale locale) {
    setState(() {
      MyApp.locale = locale;
      _localeOverrideDelegate = SpecifiedLocalizationDelegate(locale);
    });
  }

  MaterialApp _getMaterialApp(BuildContext context,
      {Locale? locale, LocaleResolutionCallback? localeResolutionCallback}) {
    return MaterialApp(
      //Fix for the "page scroll when spacebar is pressed" issue
      shortcuts: shortcuts,
      locale: locale,
      initialRoute: '/',
      localeResolutionCallback: localeResolutionCallback,
      navigatorKey: GetIt.instance<NavigationService>().navigatorKey,
      onGenerateRoute: Routes.generateRoute,
      routes: {
        Routes.home: (context) => const ViewProductsPage(),
        Routes.login: (context) => const LoginPage(),
        Routes.myProfile: (context) => const MyProfilePage(),
        Routes.emailPasswordSignIn: (context) =>
        const EmailPasswordSignInPage(),
        Routes.about: (context) => const AboutPage(),
        Routes.imageCropWidget: (context) => const ImageCropWidget(),
        Routes.settings: (context) => const SettingsPage(),
        Routes.search: (context) => const SearchPage(),
        //Routes.console: (context) => LogConsole(),
      },
      localizationsDelegates: [
        // ... app-specific localization delegate[s] here
        if (_localeOverrideDelegate != null) _localeOverrideDelegate!,
        const AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'), // English, with country code
        Locale('pt', 'BR') // Português, with country code
      ],
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      theme: ThemeData(
        fontFamily: Constants.DEFAULT_APP_FONT_FAMILY,
        primarySwatch: MyColorScheme().primaryAsMaterial,
        appBarTheme: MyAppBarTheme(MyColorScheme()),
        colorScheme: MyColorScheme(),
        buttonTheme: MyButtonTheme(MyColorScheme()),
        toggleButtonsTheme: MyToggleButtonTheme(MyColorScheme()),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: <TargetPlatform, PageTransitionsBuilder>{
            TargetPlatform.android: ZoomPageTransitionsBuilder(),
          },
        ),
      ),
    );
  }
}
