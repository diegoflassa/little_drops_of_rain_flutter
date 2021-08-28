import 'dart:typed_data';

// ignore: import_of_legacy_library_into_null_safe
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:firebase_storage/firebase_storage.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:json_annotation/json_annotation.dart';
import 'package:little_drops_of_rain_flutter/data/dao/files_dao.dart';
import 'package:little_drops_of_rain_flutter/enums/element_source.dart';
import 'package:little_drops_of_rain_flutter/helpers/helper.dart';
import 'package:little_drops_of_rain_flutter/interfaces/copyable.dart';
import 'package:little_drops_of_rain_flutter/interfaces/firebase_entity.dart';
import 'package:little_drops_of_rain_flutter/extensions/uri_extensions.dart';

part 'user.g.dart';

@JsonSerializable()
// ignore: must_be_immutable
class User extends Equatable implements FirebaseEntity, Copyable<User> {
  User();

  User.fromMap(Map<String, dynamic>? map, {this.reference}) {
    source = ElementSource.MAP;
    if (map != null) {
      uid = map[UID] as String;
      imageUrl =
          (map[IMAGE_URL] != null) ? Uri.parse(map[IMAGE_URL] as String) : null;
      email = (map[EMAIL] != null) ? map[EMAIL] as String : '';
      name = (map[NAME] != null) ? map[NAME] as String : '';
      surename = (map[SURENAME] != null) ? map[SURENAME] as String : '';
      nickname = (map[NICKNAME] != null) ? map[NICKNAME] as String : '';
      birthdate = (map[BIRTHDATE] != null) ? map[BIRTHDATE] as Timestamp : null;
      country = (map[COUNTRY] != null) ? map[COUNTRY] as String : '';
      receiveNotifications = (map[RECEIVE_NOTIFICATIONS] != null)
          ? map[RECEIVE_NOTIFICATIONS] as bool
          : false;
      creationDate = map[CREATION_DATE] as Timestamp;
      credits = (map[CREDITS] != null) ? map[CREDITS] as String : '';
    }
  }

  User.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot)
      : this.fromMap(snapshot.data(), reference: snapshot.reference);

  /// A necessary factory constructor for creating a new User instance
  /// from a map. Pass the map to the generated `_$UserFromJson()` constructor.
  /// The constructor is named after the source class, in this case, User.
  factory User.fromJson(Map<String, dynamic> json) => User._fromJson(json);

  @override
  List<Object?> get props => [
        //reference,
        uid,
        imageUrl,
        email,
        name,
        surename,
        nickname,
        birthdate,
        country,
        receiveNotifications,
        creationDate,
        credits
      ];

  static const String UID = 'uid';
  static const String IMAGE_URL = 'image_url';
  static const String EMAIL = 'email';
  static const String NAME = 'name';
  static const String SURENAME = 'surename';
  static const String NICKNAME = 'nickname';
  static const String BIRTHDATE = 'birthdate';
  static const String COUNTRY = 'country';
  static const String RECEIVE_NOTIFICATIONS = 'receive_notifications';
  static const String CREATION_DATE = 'creation_date';
  static const String CREDITS = 'credits';

  @JsonKey(ignore: true)
  DocumentReference? reference;

  @JsonKey(name: UID)
  String? uid;
  @JsonKey(ignore: true)
  Uri? previousImageUrl;
  @JsonKey(name: IMAGE_URL)
  Uri? imageUrl;
  @JsonKey(ignore: true)
  Uint8List? imageBytes;
  @JsonKey(name: EMAIL)
  String email = '';
  @JsonKey(name: NAME)
  String name = '';
  @JsonKey(name: SURENAME)
  String surename = '';
  @JsonKey(name: NICKNAME)
  String nickname = '';
  @JsonKey(ignore: true)
  Timestamp? birthdate;
  @JsonKey(name: BIRTHDATE)
  int birthdateAsInt = 0;
  @JsonKey(name: COUNTRY)
  String country = '';
  @JsonKey(name: RECEIVE_NOTIFICATIONS)
  bool receiveNotifications = true;
  @JsonKey(ignore: true)
  Timestamp? creationDate;
  @JsonKey(name: CREATION_DATE)
  int creationDateAsInt = 0;
  @JsonKey(name: CREDITS)
  String credits = '';
  @JsonKey(ignore: true)
  ElementSource source = ElementSource.UNKNOWN;

  @override
  User copyWith(User user, {int depth = 1}) {
    final ret = User()
      ..reference = user.reference
      ..uid = user.uid
      ..imageUrl = user.imageUrl
      ..email = user.email
      ..name = user.name
      ..surename = user.surename
      ..nickname = user.nickname
      ..birthdate = user.birthdate
      ..country = user.country
      ..receiveNotifications = user.receiveNotifications
      ..creationDate = user.creationDate
      ..creationDateAsInt = user.creationDateAsInt
      ..credits = user.credits
      ..source = user.source;
    return ret;
  }

  @override
  User getCopy() {
    return copyWith(this);
  }

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    map[UID] = uid;
    map[IMAGE_URL] = imageUrl.toString();
    map[EMAIL] = email;
    map[NAME] = name;
    map[SURENAME] = surename;
    map[NICKNAME] = nickname;
    map[BIRTHDATE] = birthdate;
    map[COUNTRY] = country;
    map[RECEIVE_NOTIFICATIONS] = receiveNotifications;
    map[CREATION_DATE] =
        (creationDate == null) ? FieldValue.serverTimestamp() : creationDate;
    map[CREDITS] = credits;
    return map;
  }

  /// A necessary factory constructor for creating a new User instance
  /// from a map. Pass the map to the generated `_$UserFromJson()`
  /// constructor.
  /// The constructor is named after the source class, in this case, User.
  static User _fromJson(Map<String, dynamic> json) {
    return _$UserFromJson(json)..source = ElementSource.JSON;
  }

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$UserToJson`.
  Map<String, dynamic> toJson() => _$UserToJson(this);

  Timestamp getCreationDateAsTimestamp() {
    return Helper.timestampFromInt(creationDateAsInt);
  }

  String getIdentification() {
    return nickname.isNotEmpty
        ? nickname
        : name.isNotEmpty
            ? name
            : email.split('@')[0];
  }

  Future<Uint8List?> getImageData() async {
    if (imageUrl != null && imageUrl!.path.isNotEmpty) {
      return imageUrl!.downloadBytes();
    } else {
      return Future.value(null);
    }
  }

  Future<FullMetadata?> getImageMetaData() async {
    if (imageUrl != null && imageUrl!.path.isNotEmpty) {
      if (imageUrl!.isFromStorage()) {
        return FilesDao().getMetadataAsUri(imageUrl!);
      }
    } else {
      return Future.value(null);
    }
  }

  @override
  String toString() {
    return '$name - $email';
  }
}
