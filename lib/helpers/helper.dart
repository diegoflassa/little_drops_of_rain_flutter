import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui' show Color;

// ignore: import_of_legacy_library_into_null_safe
import 'package:animations/animations.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diacritic/diacritic.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:little_drops_of_rain_flutter/data/entities/config.dart';
import 'package:little_drops_of_rain_flutter/data/entities/product.dart' as my_app;
import 'package:little_drops_of_rain_flutter/data/entities/user.dart' as my_app;
import 'package:little_drops_of_rain_flutter/enums/can_delete_result.dart';
import 'package:little_drops_of_rain_flutter/enums/element_type.dart';
import 'package:little_drops_of_rain_flutter/enums/order_by.dart';
import 'package:little_drops_of_rain_flutter/enums/transition_type.dart';
import 'package:little_drops_of_rain_flutter/helpers/constants.dart';
import 'package:little_drops_of_rain_flutter/i18n/app_localizations.dart';
import 'package:little_drops_of_rain_flutter/ui/themes/my_text_style.dart';

class Helper {

  static List<my_app.Product> querySnapshotToProductsList(
      QuerySnapshot<Map<String, dynamic>>? qs,
      {bool getImages = false,
      bool nestedObjects = true}) {
    final products = <my_app.Product>[];
    if (qs != null && qs.size > 0) {
      for (final doc in qs.docs) {
        products.add(my_app.Product.fromMap(doc.data(),
            reference: doc.reference, nestedObjects: nestedObjects));
      }
    }
    return products;
  }

  static List<my_app.Product> documentSnapshotsToProducts(
      List<DocumentSnapshot<Map<String, dynamic>>>? snapshots,
      {bool nestedObjects = true}) {
    final products = <my_app.Product>[];
    if (snapshots != null && snapshots.isNotEmpty) {
      for (final ss in snapshots) {
        products.add(my_app.Product.fromMap(ss.data(),
            reference: ss.reference, nestedObjects: nestedObjects));
      }
    }
    return products;
  }

  static Config? querySnapshotToConfig(
      QuerySnapshot<Map<String, dynamic>>? qs) {
    Config? config;
    if (qs != null && qs.size == 1) {
      config =
          Config.fromMap(qs.docs[0].data(), reference: qs.docs[0].reference);
    }
    return config;
  }

  static my_app.User? firebaseUserToUser(User? user) {
    my_app.User? ret;
    if (user != null) {
      ret = my_app.User();
      ret.name = (user.displayName != null) ? user.displayName! : '';
      ret.email = (user.email != null) ? user.email! : '';
      if (user.photoURL != null) {
        ret.imageUrl = Uri.parse(user.photoURL!);
      }
    }
    return ret;
  }

  static my_app.User userCredentialToUser(UserCredential uc) {
    final user = my_app.User();
    if (uc.user != null) {
      if (uc.user!.displayName != null) {
        final names = uc.user!.displayName!.split(' ');
        var idx = 0;
        for (final name in names) {
          if (idx++ == 0) {
            user.name = name;
          } else {
            user.surename = '${user.surename} $name';
          }
        }
      }
      user.email = (uc.user!.email != null) ? uc.user!.email! : '';
      if (uc.user!.photoURL != null) {
        user.imageUrl = Uri.parse(uc.user!.photoURL!);
      }
    }
    return user;
  }

  static my_app.User queryDocumentSnapshotToUser(
      QueryDocumentSnapshot<Map<String, dynamic>> qds) {
    return my_app.User.fromMap(qds.data(), reference: qds.reference);
  }

  static ContainerTransitionType containerTransitionTypeStringToEnum(
      String value) {
    var ret = ContainerTransitionType.fade;
    if (value == 'Fade') {
      ret = ContainerTransitionType.fade;
    } else if (value == 'Fade Through') {
      ret = ContainerTransitionType.fadeThrough;
    }
    return ret;
  }

  static TransitionType pageTransitionTypeStringToEnum(String? value) {
    var ret = TransitionType.FADE;
    if (value != null) {
      if (value == Constants.DEFAULT_PAGE_TRANSITION_TYPE_VALUE_FOR_FADE) {
        ret = TransitionType.FADE;
      } else if (value ==
          Constants.DEFAULT_PAGE_TRANSITION_TYPE_VALUE_FOR_SCALE) {
        ret = TransitionType.SCALE;
      } else if (value ==
          Constants.DEFAULT_PAGE_TRANSITION_TYPE_VALUE_FOR_SIZE) {
        ret = TransitionType.SIZE;
      } else if (value ==
          Constants.DEFAULT_PAGE_TRANSITION_TYPE_VALUE_FOR_SLIDE) {
        ret = TransitionType.SLIDE;
      } else if (value ==
          Constants.DEFAULT_PAGE_TRANSITION_TYPE_VALUE_FOR_ROTATION) {
        ret = TransitionType.ROTATION;
      } else if (value ==
          Constants.DEFAULT_PAGE_TRANSITION_TYPE_VALUE_FOR_HERO) {
        ret = TransitionType.HERO;
      }
    }
    return ret;
  }

  static String pageTransitionTypeEnumToString(TransitionType value) {
    var ret = Constants.DEFAULT_PAGE_TRANSITION_TYPE_VALUE_FOR_FADE;
    switch (value) {
      case TransitionType.FADE:
        ret = Constants.DEFAULT_PAGE_TRANSITION_TYPE_VALUE_FOR_FADE;
        break;
      case TransitionType.SLIDE:
        ret = Constants.DEFAULT_PAGE_TRANSITION_TYPE_VALUE_FOR_SLIDE;
        break;
      case TransitionType.SCALE:
        ret = Constants.DEFAULT_PAGE_TRANSITION_TYPE_VALUE_FOR_SCALE;
        break;
      case TransitionType.ROTATION:
        ret = Constants.DEFAULT_PAGE_TRANSITION_TYPE_VALUE_FOR_ROTATION;
        break;
      case TransitionType.SIZE:
        ret = Constants.DEFAULT_PAGE_TRANSITION_TYPE_VALUE_FOR_SIZE;
        break;
      case TransitionType.HERO:
        ret = Constants.DEFAULT_PAGE_TRANSITION_TYPE_VALUE_FOR_HERO;
        break;
    }
    return ret;
  }

  static String? timeDilationValueToString(
      BuildContext context, double? value) {
    String? ret = AppLocalizations.of(context).unknown;
    if (value == Constants.DEFAULT_TIME_DILATION_VALUE_FOR_ULTRA_SLOW) {
      ret = AppLocalizations.of(context).ultraSlow;
    } else if (value == Constants.DEFAULT_TIME_DILATION_VALUE_FOR_MEGA_SLOW) {
      ret = AppLocalizations.of(context).megaSlow;
    } else if (value == Constants.DEFAULT_TIME_DILATION_VALUE_FOR_VERY_SLOW) {
      ret = AppLocalizations.of(context).verySlow;
    } else if (value == Constants.DEFAULT_TIME_DILATION_VALUE_FOR_SLOW) {
      ret = AppLocalizations.of(context).slow;
    } else if (value == Constants.DEFAULT_TIME_DILATION_VALUE_FOR_NORMAL) {
      ret = AppLocalizations.of(context).normal;
    } else if (value == Constants.DEFAULT_TIME_DILATION_VALUE_FOR_FAST) {
      ret = AppLocalizations.of(context).fast;
    } else if (value == Constants.DEFAULT_TIME_DILATION_VALUE_FOR_VERY_FAST) {
      ret = AppLocalizations.of(context).veryFast;
    }
    return ret;
  }

  static String containerTransitionTypeEnumToString(
      ContainerTransitionType value) {
    String? ret = 'Unknown';
    switch (value) {
      case ContainerTransitionType.fade:
        ret = 'Fade';
        break;
      case ContainerTransitionType.fadeThrough:
        ret = 'Fade Through';
        break;
    }
    return ret;
  }

  static String? orderByEnumToString(OrderBy value, ElementType elementType) {
    String? ret = 'Unknown';
    switch (value) {
      case OrderBy.CREATION_DATE:
        ret = 'creation_date';
        break;
      case OrderBy.UPDATE_DATE:
        ret = 'update_date';
        break;
      case OrderBy.RATING:
        ret = 'rating';
        break;
      case OrderBy.VIEWS:
        ret = 'views';
        break;
      case OrderBy.UNKNOWN:
        ret = null;
        break;
      case OrderBy.RANDOM:
        ret = null;
        break;
      case OrderBy.ALPHABETICALLY:
        switch (elementType) {
          case ElementType.PRODUCT:
            ret = 'name';
            break;
          case ElementType.UNKNOWN:
            ret = null;
            break;
        }
        break;
    }
    return ret;
  }

  static dynamic elementTypeEnumFromString(String value,
      {ElementType defaultValue = ElementType.UNKNOWN}) {
    return ElementType.values
        .firstWhere((e) => e.toString() == value, orElse: () => defaultValue);
  }

  static Color colorFromString(String color) {
    var value = 0;
    if (color.contains('Color(0x')) {
      // kind of hacky..
      final valueString = color.split('(0x')[1].split(')')[0];
      value = int.parse(valueString, radix: 16);
    }
    return Color(value);
  }

  static Timestamp timestampFromInt(int timestamp) {
    return Timestamp.fromMicrosecondsSinceEpoch(timestamp);
  }

  static DateTime datetimeFromInt(int timestamp) {
    return DateTime.fromMicrosecondsSinceEpoch(timestamp);
  }

  static String? stringToParameter(String? string) {
    return (string != null)
        ? removeDiacritics(string.replaceAll(' ', '_'))
        : null;
  }

  static String? parameterToString(String? param) {
    return (param != null) ? param.replaceAll('_', ' ') : null;
  }

  static ColorFiltered? grayScale(Image? image) {
    ColorFiltered? ret;
    if (image != null) {
      ret = ColorFiltered(
        colorFilter: const ColorFilter.matrix(
          <double>[
            // GrayScale, based on
            // https://www.w3.org/TR/filter-effects-1/#grayscaleEquivalent
            0.2126, 0.7152, 0.0722, 0, 0,
            0.2126, 0.7152, 0.0722, 0, 0,
            0.2126, 0.7152, 0.0722, 0, 0,
            0, 0, 0, 1, 0,
          ],
        ),
        child: image,
      );
    }
    return ret;
  }

  static void showSnackBar(BuildContext context, String message,
      {Duration duration = const Duration(milliseconds: 4000)}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: duration,
      content: Container(
        //color: Colors.grey,
        decoration: BoxDecoration(
            color: Colors.grey,
            border: Border.all(width: 2, color: Colors.grey),
            borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.fromLTRB(
            0, 0, 0, Constants.DEFAULT_AD_BOTTOM_SPACE),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Text(message, style: const MyTextStyle.black()),
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 1000,
      behavior: SnackBarBehavior.floating,
    ));
  }

  static void processCanDeleteResult(
      CanDeleteResult result, List<String> references, BuildContext context) {
    var reasonText = AppLocalizations.of(context).unknown;
    switch (result) {
      case CanDeleteResult.CANT_NOT_THE_OWNER:
        {
          reasonText = AppLocalizations.of(context).notTheOwner;
        }
        break;
      case CanDeleteResult.CANT_HAS_REFERENCES:
        {
          reasonText = AppLocalizations.of(context).hasReferences;
          reasonText += references.join(', ');
        }
        break;
      case CanDeleteResult.CANT_DOES_NOT_EXISTS:
        {
          reasonText = AppLocalizations.of(context).doesNotExist;
        }
        break;
      case CanDeleteResult.UNKNOWN:
        {
          reasonText = AppLocalizations.of(context).unknown;
        }
        break;
      case CanDeleteResult.CAN:
        // Do nothing
        break;
    }
    Helper.showSnackBar(context, reasonText);
  }

  static bool isSameQuery(Query query, Query newQuery) {
    var ret = true;
    if (query.parameters.length == newQuery.parameters.length) {
      for (final key in query.parameters.keys) {
        if (!newQuery.parameters.containsKey(key)) {
          ret = false;
          break;
        } else {
          if (query.parameters[key] is Iterable &&
              newQuery.parameters[key] is Iterable &&
              (query.parameters[key] as Iterable).length ==
                  (newQuery.parameters[key] as Iterable).length) {
            ret = compareIterables(query.parameters[key] as Iterable,
                newQuery.parameters[key] as Iterable);
          } else if (query.parameters[key] != newQuery.parameters[key]) {
            ret = false;
            break;
          }
        }
      }
    }
    return ret;
  }

  static bool compareIterables(
      Iterable<dynamic> items, Iterable<dynamic> otherItems) {
    var ret = true;
    var idx = 0;
    for (final item in items) {
      if (item is Iterable<dynamic> &&
          otherItems.elementAt(idx) is Iterable<dynamic>) {
        ret = compareIterables(
            item, otherItems.elementAt(idx) as Iterable<dynamic>);
      } else if (item != otherItems.elementAt(idx)) {
        ret = false;
        break;
      }
      idx++;
    }
    return ret;
  }

  static Future<bool?> showImageThumbnail(
      BuildContext context, ui.Image cropped) {
    return showModalBottomSheet<bool?>(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.only(
            top: Constants.DEFAULT_EDGE_INSETS_VERTICAL,
            bottom: Constants.DEFAULT_AD_BOTTOM_SPACE),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            RawImage(
              image: cropped,
              fit: BoxFit.contain,
              height: (cropped.height.toDouble() <=
                      ((MediaQuery.of(context).size.height * 9.0 / 16.0) -
                          110 -
                          Constants.DEFAULT_AD_BOTTOM_SPACE))
                  ? cropped.height.toDouble()
                  : (MediaQuery.of(context).size.height * 9.0 / 16.0) -
                      110 -
                      Constants.DEFAULT_AD_BOTTOM_SPACE,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text(AppLocalizations.of(context).apply),
            ),
            //const SizedBox(height: Constants.DEFAULT_AD_BOTTOM_SPACE-10),
          ],
        ),
      ),
    );
  }

  static Uint8List stringToBytes(String source) {
    // String (Dart uses UTF-16) to bytes
    final list = <int>[];
    source.runes.forEach((rune) {
      if (rune >= 0x10000) {
        rune -= 0x10000;
        final firstWord = (rune >> 10) + 0xD800;
        list.add(firstWord >> 8);
        list.add(firstWord & 0xFF);
        final secondWord = (rune & 0x3FF) + 0xDC00;
        list.add(secondWord >> 8);
        list.add(secondWord & 0xFF);
      } else {
        list.add(rune >> 8);
        list.add(rune & 0xFF);
      }
    });
    return Uint8List.fromList(list);
  }

  static String bytesToString(Uint8List bytes) {
    // Bytes to UTF-16 string
    final buffer = StringBuffer();
    for (var i = 0; i < bytes.length;) {
      final firstWord = (bytes[i] << 8) + bytes[i + 1];
      if (0xD800 <= firstWord && firstWord <= 0xDBFF) {
        final secondWord = (bytes[i + 2] << 8) + bytes[i + 3];
        buffer.writeCharCode(
            ((firstWord - 0xD800) << 10) + (secondWord - 0xDC00) + 0x10000);
        i += 4;
      } else {
        buffer.writeCharCode(firstWord);
        i += 2;
      }
    }
    // Outcome
    return buffer.toString();
  }
}
