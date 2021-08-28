import 'dart:typed_data';

import 'package:little_drops_of_rain_flutter/helpers/my_logger.dart';
import 'package:little_drops_of_rain_flutter/routing/routing_data.dart';
import 'package:little_drops_of_rain_flutter/extensions/uri_extensions.dart';


extension StringExtensions on String {
  static List<String> unwise = [
    ' ',
    '{',
    '}',
    '|',
    r'\\',
    '^',
    '[',
    ']',
    r'\',
    '*',
    '#',
  ];
  static List<String> reserved = [
    ';',
    '/',
    '?',
    ':',
    '@',
    '&',
    '=',
    '+',
    r'$',
    ','
  ];
  static List<String> allowed = [
    '-',
    '_',
    '.',
    '~',
    '!',
    //'*',
    "'",
    '(',
    ')',
    ';',
    ':',
    '@',
    '&',
    '=',
    '+',
    r'$',
    ',',
    '/',
    //'?',
    '%',
    '#',
    //'[',
    //']',
    //'?',
    '@',
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
    'H',
    'I',
    'J',
    'K',
    'L',
    'M',
    'N',
    'O',
    'P',
    'Q',
    'R',
    'S',
    'T',
    'U',
    'V',
    'W',
    'X',
    'Y',
    'Z',
    'a',
    'b',
    'c',
    'd',
    'e',
    'f',
    'g',
    'h',
    'i',
    'j',
    'k',
    'l',
    'm',
    'n',
    'o',
    'p',
    'q',
    'r',
    's',
    't',
    'u',
    'v',
    'w',
    'x',
    'y',
    'z',
    '0',
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9'
  ];

  RoutingData get getRoutingData {
    final uriData = Uri.parse(this);
    MyLogger().logger.i('uri: ${uriData.toString()} from: $this');
    MyLogger().logger.i(
        'queryParameters: ${uriData.queryParameters} path: ${uriData.path} pathSegments: ${uriData.pathSegments.toString()} ');
    return RoutingData(
      queryParameters: uriData.queryParameters,
      route: uriData,
    );
  }

  bool parseBool() {
    return toLowerCase() == 'true';
  }

  bool isUrl() {
    bool ret;
    try {
      Uri.parse(this);
      ret = true;
    } on FormatException catch (ex) {
      MyLogger().logger.i(ex.toString());
      ret = false;
    }
    return ret;
  }

  List<String> getInvalidURLCharacters() {
    final ret = <String>[];
    for (final rune in runes) {
      final outerChar = String.fromCharCode(rune);
      for (final innerChar in unwise) {
        if (outerChar == innerChar) {
          ret.add(innerChar);
        }
      }
      for (final innerChar in reserved) {
        if (outerChar == innerChar) {
          ret.add(innerChar);
        }
      }
      if (!allowed.contains(outerChar)) {
        ret.add(outerChar);
      }
    }
    return ret;
  }

  bool isFromStorage() {
    final uri = Uri.parse(this);
    return uri.isFromStorage();
  }

  bool isFromWeb() {
    final uri = Uri.parse(this);
    return uri.isFromWeb();
  }

  Future<Uint8List?> downloadBytes() async {
    final uri = Uri.parse(this);
    return uri.downloadBytes();
  }
}
