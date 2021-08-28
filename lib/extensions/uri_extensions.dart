import 'dart:io' as io;
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
// ignore: import_of_legacy_library_into_null_safe
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:little_drops_of_rain_flutter/data/dao/files_dao.dart';
import 'package:little_drops_of_rain_flutter/helpers/constants.dart';

extension UriExtensions on Uri {
  String? lastPath() {
    String? ret;
    if (pathSegments.isNotEmpty) {
      ret = pathSegments[pathSegments.length - 1];
    } else {
      ret = null;
    }
    return ret;
  }

  String? penultimatePath() {
    String? ret;
    if (pathSegments.length > 1) {
      ret = pathSegments[pathSegments.length - 2];
    } else {
      ret = null;
    }
    return ret;
  }

  bool isFromStorage() {
    final ret = host.toLowerCase() == Constants.FIREBASE_STORAGE_BASE_URL ||
        host.toLowerCase() == Constants.FIREBASE_BUCKET_BASE_URL;
    return ret;
  }

  bool isFromWeb() {
    final ret = scheme == 'http' || scheme == 'https';
    return ret;
  }

  Future<Uint8List?> downloadBytes() async {
    Uint8List? bytes;
    if (path.isNotEmpty && path.toLowerCase() != 'null') {
      if (isFromStorage()) {
        bytes = await FilesDao().downloadBytesAsUri(this);
      } else if (isFromWeb()) {
        bytes = await http.readBytes(this);
      } else {
        if (kIsWeb) {
          final file = PickedFile(toString());
          bytes = await file.readAsBytes();
        } else {
          final file = io.File(toString());
          if (file.existsSync()) {
            bytes = await file.readAsBytes();
          }
        }
      }
    }
    return bytes;
  }
}
