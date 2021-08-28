// ignore: import_of_legacy_library_into_null_safe
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class FirebaseEntity {
  FirebaseEntity.fromMap(Map<String, dynamic>? map);

  FirebaseEntity.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot);

  Map<String, dynamic> toMap() {
    return <String, dynamic>{};
  }
}
