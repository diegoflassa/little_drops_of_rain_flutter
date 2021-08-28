import 'dart:async';

import 'package:flutter/material.dart';
import 'package:little_drops_of_rain_flutter/i18n/app_localizations.dart';

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'pt'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return AppLocalizations.load(locale);
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) {
    return false;
  }
}

class SpecifiedLocalizationDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const SpecifiedLocalizationDelegate(this.overriddenLocale);

  final Locale? overriddenLocale;

  @override
  bool isSupported(Locale locale) => overriddenLocale != null;

  @override
  Future<AppLocalizations> load(Locale locale) =>
      AppLocalizations.load(overriddenLocale!);

  @override
  bool shouldReload(SpecifiedLocalizationDelegate old) => true;
}
