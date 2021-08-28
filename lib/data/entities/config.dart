// ignore: import_of_legacy_library_into_null_safe
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:json_annotation/json_annotation.dart';
import 'package:little_drops_of_rain_flutter/enums/element_source.dart';
import 'package:little_drops_of_rain_flutter/interfaces/copyable.dart';
import 'package:little_drops_of_rain_flutter/interfaces/firebase_entity.dart';

part 'config.g.dart';

@JsonSerializable()
// ignore: must_be_immutable
class Config extends Equatable implements FirebaseEntity, Copyable<Config> {
  Config();

  Config.fromMap(Map<String, dynamic>? map, {this.reference}) {
    source = ElementSource.MAP;
    if (map != null) {
      uid = map[UID_TAG] as String;
      aboutText = (map[ABOUT_TEXT] != null) ? (map[ABOUT_TEXT] as String) : '';
    }
  }

  Config.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot)
      : this.fromMap(snapshot.data(), reference: snapshot.reference);

  /// A necessary factory constructor for creating a new Config instance
  /// from a map. Pass the map to the generated `_$ConfigFromJson()` constructor.
  /// The constructor is named after the source class, in this case, Config.
  factory Config.fromJson(Map<String, dynamic> json) => Config._fromJson(json);

  @override
  List<Object?> get props => [/*reference,*/ uid, aboutText, source];

  static const String UID_TAG = 'uid';
  static const String ABOUT_TEXT = 'about_text';

  @JsonKey(ignore: true)
  DocumentReference? reference;

  @JsonKey(name: UID_TAG)
  String? uid;
  @JsonKey(name: ABOUT_TEXT)
  String? aboutText;
  @JsonKey(ignore: true)
  ElementSource source = ElementSource.UNKNOWN;

  @override
  Config copyWith(Config config, {int depth = 1}) {
    final ret = Config()..aboutText = config.aboutText;
    return ret;
  }

  @override
  Config getCopy() {
    return copyWith(this);
  }

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    map[UID_TAG] = uid;
    map[ABOUT_TEXT] = aboutText;
    return map;
  }

  /// A necessary factory constructor for creating a new Config instance
  /// from a map. Pass the map to the generated `_$ConfigFromJson()` constructor.
  /// The constructor is named after the source class, in this case, Config.
  static Config _fromJson(Map<String, dynamic> json) {
    return _$ConfigFromJson(json)..source = ElementSource.JSON;
  }

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$GradeToJson`.
  Map<String, dynamic> toJson() => _$ConfigToJson(this);

  @override
  String toString() {
    return uid!.toString();
  }
}
