import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:language_pickers/language_pickers.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:language_pickers/languages.dart';
import 'package:little_drops_of_rain_flutter/helpers/menu_item_ext.dart';
import 'package:little_drops_of_rain_flutter/i18n/app_localizations.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:popup_menu/popup_menu.dart';

class Dialogs {
  static const EDIT_DELETE_MENU_RET_EDIT = 'edit';
  static const EDIT_DELETE_MENU_RET_DELETE = 'delete';

  static Future<bool> showDeleteEditPopupMenu(BuildContext context,
      Offset offset, MenuClickCallback onClickMenu) async {
    PopupMenu.context = context;
    PopupMenu(
      items: [
        MenuItemExt(
            title: AppLocalizations.of(context).edit,
            value: EDIT_DELETE_MENU_RET_EDIT),
        MenuItemExt(
            title: AppLocalizations.of(context).delete,
            value: EDIT_DELETE_MENU_RET_DELETE),
      ],
      onClickMenu: onClickMenu,
    ).show(rect: Rect.fromPoints(offset, offset));
    return true;
  }

  static const DELETE_DIALOG_RET_CANCEL = 'cancel';
  static const DELETE_DIALOG_RET_CONFIRM = 'confirm';

  static Future<String?> showDeleteConfirmationDialog(
      BuildContext context) async {
    // set up the buttons
    final cancelButton = TextButton(
      onPressed: () {
        Navigator.of(context).pop(DELETE_DIALOG_RET_CANCEL);
      },
      child: Text(AppLocalizations.of(context).cancel),
    );
    final continueButton = TextButton(
      onPressed: () {
        Navigator.of(context).pop(DELETE_DIALOG_RET_CONFIRM);
      },
      child: Text(AppLocalizations.of(context).confirm),
    );
    // set up the AlertDialog
    final alert = AlertDialog(
      title: Text(AppLocalizations.of(context).deleteConfirmationTitle),
      content: Text(AppLocalizations.of(context).deleteConfirmationMessage),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    // show the dialog
    return showDialog<String>(
      context: context,
      builder: (context) {
        return alert;
      },
    );
  }

  static Future<String?> showClearCacheConfirmationDialog(
      BuildContext context) async {
    // set up the buttons
    final cancelButton = TextButton(
      onPressed: () {
        Navigator.of(context).pop(DELETE_DIALOG_RET_CANCEL);
      },
      child: Text(AppLocalizations.of(context).cancel),
    );
    final continueButton = TextButton(
      onPressed: () {
        Navigator.of(context).pop(DELETE_DIALOG_RET_CONFIRM);
      },
      child: Text(AppLocalizations.of(context).confirm),
    );
    // set up the AlertDialog
    final alert = AlertDialog(
      title: Text(AppLocalizations.of(context).clearCacheConfirmationTitle),
      content: Text(AppLocalizations.of(context).clearCacheConfirmationMessage),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    // show the dialog
    return showDialog<String>(
      context: context,
      builder: (context) {
        return alert;
      },
    );
  }

  static Future<String?> showResetCacheSettingsConfirmationDialog(
      BuildContext context) async {
    // set up the buttons
    final cancelButton = TextButton(
      onPressed: () {
        Navigator.of(context).pop(DELETE_DIALOG_RET_CANCEL);
      },
      child: Text(AppLocalizations.of(context).cancel),
    );
    final continueButton = TextButton(
      onPressed: () {
        Navigator.of(context).pop(DELETE_DIALOG_RET_CONFIRM);
      },
      child: Text(AppLocalizations.of(context).confirm),
    );
    // set up the AlertDialog
    final alert = AlertDialog(
      title: Text(AppLocalizations.of(context).resetCacheConfirmationTitle),
      content: Text(AppLocalizations.of(context).resetCacheConfirmationMessage),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    // show the dialog
    return showDialog<String>(
      context: context,
      builder: (context) {
        return alert;
      },
    );
  }

  static void showLanguagePickerDialog(
      BuildContext context, ValueChanged<Language> onLanguageSelected,
      {String? title}) {
    showDialog<Language>(
      context: context,
      builder: (context) => LanguagePickerDialog(
        itemBuilder: _buildDialogItem,
        onValuePicked: onLanguageSelected,
        titlePadding: const EdgeInsets.all(8),
        searchCursorColor: Colors.pinkAccent,
        searchInputDecoration:
            InputDecoration(hintText: AppLocalizations.of(context).search),
        isSearchable: true,
        title: (title == null)
            ? Text(AppLocalizations.of(context).selectYourLanguage)
            : Text(title),
      ),
    );
  }

  static const DEFAULT_LANGUAGE = 'default';

  static void showLanguageTranslationPickerDialog(
      BuildContext context, ValueChanged<Language> onLanguageSelected,
      {String? title}) {
    LanguageList.langs[DEFAULT_LANGUAGE] =
        AppLocalizations.of(context).defaultLanguage;
    showDialog<Language>(
      context: context,
      builder: (context) => LanguagePickerDialog(
        itemBuilder: _buildDialogItem,
        onValuePicked: onLanguageSelected,
        titlePadding: const EdgeInsets.all(8),
        searchCursorColor: Colors.pinkAccent,
        searchInputDecoration:
            InputDecoration(hintText: AppLocalizations.of(context).search),
        isSearchable: true,
        title: (title == null)
            ? Text(AppLocalizations.of(context).selectYourLanguage)
            : Text(title),
        //languages: LanguagesList.languages,
        languagesList: _languageListToMap(LanguageList.langs),
      ),
    );
  }

  static List<Map<String, String>> _languageListToMap(
      Map<String, String> languageList) {
    final ret = <Map<String, String>>[];
    Map<String, String> convertedLanguage;

    for (final entry in languageList.entries) {
      convertedLanguage = <String, String>{};
      convertedLanguage['isoCode'] = entry.key;
      convertedLanguage['name'] = entry.value;
      ret.add(convertedLanguage);
    }

    return ret;
  }

  // It's sample code of Dialog Item.
  static Widget _buildDialogItem(Language language) => Row(
        children: <Widget>[
          Text(language.name),
          const SizedBox(width: 8),
          Flexible(child: Text('(${language.isoCode})'))
        ],
      );

  static const LOGOFF_DIALOG_RET_YES = 'yes';
  static const LOGOFF_DIALOG_RET_NO = 'no';

  static Future<String?> showLogoffConfirmationDialog(
      BuildContext context) async {
// set up the buttons
    final noButton = TextButton(
      onPressed: () {
        Navigator.of(context).pop(LOGOFF_DIALOG_RET_NO);
      },
      child: Text(AppLocalizations.of(context).no),
    );
    final yesButton = TextButton(
      onPressed: () {
        Navigator.of(context).pop(LOGOFF_DIALOG_RET_YES);
      },
      child: Text(AppLocalizations.of(context).yes),
    );
// set up the AlertDialog
    final alert = AlertDialog(
      title: Text(AppLocalizations.of(context).logoffConfirmationTitle),
      content: Text(AppLocalizations.of(context).logoffConfirmationMessage),
      actions: [
        yesButton,
        noButton,
      ],
    );
// show the dialog
    return showDialog<String>(
      context: context,
      builder: (context) {
        return alert;
      },
    );
  }
}

// ignore: avoid_classes_with_only_static_members
/*
class LanguagesList {
  static final languages = [
    Language.fromMap({'name':Dialogs.DEFAULT_LANGUAGE, 'isoCode':'Default Language'}),
    Language.fromIsoCode('af'),
    Language.fromIsoCode('sq'),
    Language.fromIsoCode('am'),
    Language.fromIsoCode('ar'),
    Language.fromIsoCode('hy'),
    Language.fromIsoCode('az'),
    Language.fromIsoCode('eu'),
    Language.fromIsoCode('be'),
    Language.fromIsoCode('bn'),
    Language.fromIsoCode('bs'),
    Language.fromIsoCode('bg'),
    Language.fromIsoCode('ca'),
    Language.fromIsoCode('ceb'),
    Language.fromIsoCode('ny'),
    Language.fromIsoCode('zh-cn'),
    Language.fromIsoCode('zh-tw'),
    Language.fromIsoCode('co'),
    Language.fromIsoCode('hr'),
    Language.fromIsoCode('cs'),
    Language.fromIsoCode('da'),
    Language.fromIsoCode('nl'),
    Language.fromIsoCode('en'),
    Language.fromIsoCode('eo'),
    Language.fromIsoCode('et'),
    Language.fromIsoCode('tl'),
    Language.fromIsoCode('fi'),
    Language.fromIsoCode('fr'),
    Language.fromIsoCode('fy'),
    Language.fromIsoCode('gl'),
    Language.fromIsoCode('ka'),
    Language.fromIsoCode('de'),
    Language.fromIsoCode('el'),
    Language.fromIsoCode('gu'),
    Language.fromIsoCode('ht'),
    Language.fromIsoCode('haw'),
    Language.fromIsoCode('iw'),
    Language.fromIsoCode('hi'),
    Language.fromIsoCode('hmn'),
    Language.fromIsoCode('hu'),
    Language.fromIsoCode('is'),
    Language.fromIsoCode('ig'),
    Language.fromIsoCode('id'),
    Language.fromIsoCode('ga'),
    Language.fromIsoCode('it'),
    Language.fromIsoCode('ja'),
    Language.fromIsoCode('jw'),
    Language.fromIsoCode('kn'),
    Language.fromIsoCode('kk'),
    Language.fromIsoCode('km'),
    Language.fromIsoCode('ko'),
    Language.fromIsoCode('ku'),
    Language.fromIsoCode('ky'),
    Language.fromIsoCode('lo'),
    Language.fromIsoCode('la'),
    Language.fromIsoCode('lv'),
    Language.fromIsoCode('lt'),
    Language.fromIsoCode('lb'),
    Language.fromIsoCode('mg'),
    Language.fromIsoCode('ms'),
    Language.fromIsoCode('ml'),
    Language.fromIsoCode('mt'),
    Language.fromIsoCode('mi'),
    Language.fromIsoCode('mr'),
    Language.fromIsoCode('mn'),
    Language.fromIsoCode('my'),
    Language.fromIsoCode('ne'),
    Language.fromIsoCode('no'),
    Language.fromIsoCode('ps'),
    Language.fromIsoCode('fa'),
    Language.fromIsoCode('pl'),
    Language.fromIsoCode('pt'),
    Language.fromIsoCode('pa'),
    Language.fromIsoCode('ro'),
    Language.fromIsoCode('ru'),
    Language.fromIsoCode('sm'),
    Language.fromIsoCode('gd'),
    Language.fromIsoCode('sr'),
    Language.fromIsoCode('st'),
    Language.fromIsoCode('sn'),
    Language.fromIsoCode('sd'),
    Language.fromIsoCode('si'),
    Language.fromIsoCode('sk'),
    Language.fromIsoCode('sl'),
    Language.fromIsoCode('so'),
    Language.fromIsoCode('es'),
    Language.fromIsoCode('su'),
    Language.fromIsoCode('sw'),
    Language.fromIsoCode('sv'),
    Language.fromIsoCode('tg'),
    Language.fromIsoCode('ta'),
    Language.fromIsoCode('te'),
    Language.fromIsoCode('th'),
    Language.fromIsoCode('tr'),
    Language.fromIsoCode('uk'),
    Language.fromIsoCode('ur'),
    Language.fromIsoCode('uz'),
    Language.fromIsoCode('vi'),
    Language.fromIsoCode('cy'),
    Language.fromIsoCode('xh'),
    Language.fromIsoCode('yi'),
    Language.fromIsoCode('yo'),
    Language.fromIsoCode('zu'),
  ];
}
*/

// ignore: avoid_classes_with_only_static_members
class LanguageList {
  static final langs = {
    Dialogs.DEFAULT_LANGUAGE: 'Default Language',
    'af': 'Afrikaans',
    'sq': 'Albanian',
    'am': 'Amharic',
    'ar': 'Arabic',
    'hy': 'Armenian',
    'az': 'Azerbaijani',
    'eu': 'Basque',
    'be': 'Belarusian',
    'bn': 'Bengali',
    'bs': 'Bosnian',
    'bg': 'Bulgarian',
    'ca': 'Catalan',
    'ceb': 'Cebuano',
    'ny': 'Chichewa',
    'zh-cn': 'Chinese Simplified',
    'zh-tw': 'Chinese Traditional',
    'co': 'Corsican',
    'hr': 'Croatian',
    'cs': 'Czech',
    'da': 'Danish',
    'nl': 'Dutch',
    'en': 'English',
    'eo': 'Esperanto',
    'et': 'Estonian',
    'tl': 'Filipino',
    'fi': 'Finnish',
    'fr': 'French',
    'fy': 'Frisian',
    'gl': 'Galician',
    'ka': 'Georgian',
    'de': 'German',
    'el': 'Greek',
    'gu': 'Gujarati',
    'ht': 'Haitian Creole',
    'ha': 'Hausa',
    'haw': 'Hawaiian',
    'iw': 'Hebrew',
    'hi': 'Hindi',
    'hmn': 'Hmong',
    'hu': 'Hungarian',
    'is': 'Icelandic',
    'ig': 'Igbo',
    'id': 'Indonesian',
    'ga': 'Irish',
    'it': 'Italian',
    'ja': 'Japanese',
    'jw': 'Javanese',
    'kn': 'Kannada',
    'kk': 'Kazakh',
    'km': 'Khmer',
    'ko': 'Korean',
    'ku': 'Kurdish (Kurmanji)',
    'ky': 'Kyrgyz',
    'lo': 'Lao',
    'la': 'Latin',
    'lv': 'Latvian',
    'lt': 'Lithuanian',
    'lb': 'Luxembourgish',
    'mk': 'Macedonian',
    'mg': 'Malagasy',
    'ms': 'Malay',
    'ml': 'Malayalam',
    'mt': 'Maltese',
    'mi': 'Maori',
    'mr': 'Marathi',
    'mn': 'Mongolian',
    'my': 'Myanmar (Burmese)',
    'ne': 'Nepali',
    'no': 'Norwegian',
    'ps': 'Pashto',
    'fa': 'Persian',
    'pl': 'Polish',
    'pt': 'Portuguese',
    'pa': 'Punjabi',
    'ro': 'Romanian',
    'ru': 'Russian',
    'sm': 'Samoan',
    'gd': 'Scots Gaelic',
    'sr': 'Serbian',
    'st': 'Sesotho',
    'sn': 'Shona',
    'sd': 'Sindhi',
    'si': 'Sinhala',
    'sk': 'Slovak',
    'sl': 'Slovenian',
    'so': 'Somali',
    'es': 'Spanish',
    'su': 'Sundanese',
    'sw': 'Swahili',
    'sv': 'Swedish',
    'tg': 'Tajik',
    'ta': 'Tamil',
    'te': 'Telugu',
    'th': 'Thai',
    'tr': 'Turkish',
    'uk': 'Ukrainian',
    'ur': 'Urdu',
    'uz': 'Uzbek',
    'vi': 'Vietnamese',
    'cy': 'Welsh',
    'xh': 'Xhosa',
    'yi': 'Yiddish',
    'yo': 'Yoruba',
    'zu': 'Zulu'
  };
}
