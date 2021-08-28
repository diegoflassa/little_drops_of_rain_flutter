// ignore: import_of_legacy_library_into_null_safe
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:little_drops_of_rain_flutter/data/entities/config.dart';
import 'package:little_drops_of_rain_flutter/helpers/helper.dart';

class ConfigDao {
  factory ConfigDao() {
    return _instance;
  }

  ConfigDao._internal();

  static const String COLLECTION_PATH = 'config';
  static const String DOCUMENT_PATH = 'config';
  CollectionReference<Map<String, dynamic>> configRef =
      FirebaseFirestore.instance.collection(COLLECTION_PATH);

  static final ConfigDao _instance = ConfigDao._internal();

  Future<Config?> getConfig() async {
    final qse =
        await configRef.where(Config.UID_TAG, isEqualTo: DOCUMENT_PATH).get();
    final config = Helper.querySnapshotToConfig(qse);
    return config;
  }
}
