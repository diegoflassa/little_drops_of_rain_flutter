import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

// ignore: import_of_legacy_library_into_null_safe
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:json_annotation/json_annotation.dart';
import 'package:little_drops_of_rain_flutter/data/dao/files_dao.dart';
import 'package:little_drops_of_rain_flutter/data/dao/users_dao.dart';
import 'package:little_drops_of_rain_flutter/enums/element_source.dart';
import 'package:little_drops_of_rain_flutter/extensions/uri_extensions.dart';
import 'package:little_drops_of_rain_flutter/helpers/constants.dart';
import 'package:little_drops_of_rain_flutter/helpers/helper.dart';
import 'package:little_drops_of_rain_flutter/data/entities/user.dart' as my_app;
import 'package:little_drops_of_rain_flutter/helpers/images_cache.dart';
import 'package:little_drops_of_rain_flutter/interfaces/copyable.dart';
import 'package:little_drops_of_rain_flutter/interfaces/firebase_entity.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:pedantic/pedantic.dart';

part 'product.g.dart';

@JsonSerializable(explicitToJson: true)
// ignore: must_be_immutable
class Product extends Equatable implements FirebaseEntity, Copyable<Product> {
  Product();

  Product.fromMap(Map<String, dynamic>? map,
      {this.reference, bool nestedObjects = true}) {
    source = ElementSource.MAP;
    if (map != null) {
      uid = map[UID] as String;
      imageUrl =
          (map[IMAGE_URL] != null) ? Uri.parse(map[IMAGE_URL] as String) : null;
      faceImageUrl = (map[FACE_IMAGE_URL] != null)
          ? Uri.parse(map[FACE_IMAGE_URL] as String)
          : null;
      weapons = (map[WEAPONS] != null) ? map[WEAPONS] as String : '';
      codename = (map[CODENAME] != null) ? map[CODENAME] as String : '';
      color = (map[COLOR] != null) ? map[COLOR] as String : color;
      updateDate = map[UPDATE_DATE] as Timestamp;
      creationDate = map[CREATION_DATE] as Timestamp;
      habilities = (map[HABILITIES] != null) ? map[HABILITIES] as String : '';
      story = (map[STORY] != null) ? map[STORY] as String : '';
      age = (map[AGE] != null) ? map[AGE] as String : '0';
      language = (map[LANGUAGE] != null) ? map[LANGUAGE] as String : '';
      birthplace = (map[BIRTHPLACE] != null) ? map[BIRTHPLACE] as String : '';
      trainningPlace =
          (map[TRAINNING_PLACE] != null) ? map[TRAINNING_PLACE] as String : '';
      civilName = (map[CIVIL_NAME] != null) ? map[CIVIL_NAME] as String : '';
      profession = (map[PROFESSION] != null) ? map[PROFESSION] as String : '';
      published = (map[PUBLISHED] != null) ? map[PUBLISHED] as bool : false;
      universeUID = map[UNIVERSE_UID] as String;
      enemiesUIDS =
          _getFriendsOrEnemiesFromMap(map[ENEMIES_UIDS] as List<dynamic>);
      enemiesUIDS.forEach((element) {
        originalEnemiesUIDS.add(element);
      });
      friendsUIDS =
          _getFriendsOrEnemiesFromMap(map[FRIENDS_UIDS] as List<dynamic>);
      friendsUIDS.forEach((element) {
        originalFriendsUIDS.add(element);
      });
      userUID = map[USER_UID] as String;
    }
  }

  Product.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot)
      : this.fromMap(snapshot.data(), reference: snapshot.reference);

  /// A necessary factory constructor for creating a new Product instance
  /// from a map. Pass the map to the generated `_$ProductFromJson()` constructor.
  /// The constructor is named after the source class, in this case, Product.
  factory Product.fromJson(Map<String, dynamic> json) => Product._fromJson(json);

  @override
  List<Object?> get props => [
        //reference,
        uid,
        imageUrl,
        faceImageUrl,
        weapons,
        codename,
        color,
        updateDate,
        creationDate,
        habilities,
        story,
        age,
        language,
        birthplace,
        trainningPlace,
        civilName,
        profession,
        published,
        universeUID,
        userUID,
      ];

  static const String UID = 'uid';
  static const String IMAGE_URL = 'image_url';
  static const String FACE_IMAGE_URL = 'face_image_url';
  static const String WEAPONS = 'weapons';
  static const String CODENAME = 'codename';
  static const String COLOR = 'color';
  static const String UPDATE_DATE = 'update_date';
  static const String CREATION_DATE = 'creation_date';
  static const String HABILITIES = 'habilities';
  static const String STORY = 'story';
  static const String AGE = 'age';
  static const String LANGUAGE = 'language';
  static const String BIRTHPLACE = 'birthplace';
  static const String TRAINNING_PLACE = 'trainning_place';
  static const String CIVIL_NAME = 'civil_name';
  static const String PROFESSION = 'profession';
  static const String PUBLISHED = 'published';
  static const String UNIVERSE_UID = 'universe_uid';
  static const String ENEMIES_UIDS = 'enemies_uids';
  static const String FRIENDS_UIDS = 'friends_uids';
  static const String USER_UID = 'user_uid';
  static const String GRADES = 'grades';

  @JsonKey(ignore: true)
  DocumentReference? reference;

  @JsonKey(name: UID)
  String? uid;
  @JsonKey(ignore: true)
  Uri? previousImageUrl;
  @JsonKey(name: IMAGE_URL)
  Uri? imageUrl;
  @JsonKey(ignore: true)
  Uint8List? imageAsBytes;
  @JsonKey(ignore: true)
  Future<Uint8List?>? imageAsBytesFuture;
  @JsonKey(ignore: true)
  bool _gotImage = false;
  @JsonKey(ignore: true)
  bool _gettingImage = false;
  @JsonKey(ignore: true)
  Uri? previousFaceImageUrl;
  @JsonKey(name: FACE_IMAGE_URL)
  Uri? faceImageUrl;
  @JsonKey(ignore: true)
  Uint8List? faceImageAsBytes;
  @JsonKey(ignore: true)
  Future<Uint8List?>? faceImageAsBytesFuture;
  @JsonKey(ignore: true)
  bool _gotFaceImage = false;
  @JsonKey(ignore: true)
  bool _gettingFaceImage = false;
  @JsonKey(name: WEAPONS)
  String weapons = '';
  @JsonKey(name: CODENAME)
  String codename = '';
  @JsonKey(name: COLOR)
  String color = Constants.DEFAULT_ELEMENTS_COLOR.toString();
  @JsonKey(ignore: true)
  Timestamp? updateDate = Timestamp.fromDate(DateTime.now());
  @JsonKey(name: UPDATE_DATE)
  int updateDateAsInt = 0;
  @JsonKey(ignore: true)
  Timestamp? creationDate;
  @JsonKey(name: CREATION_DATE)
  int creationDateAsInt = 0;
  @JsonKey(name: HABILITIES)
  String habilities = '';
  @JsonKey(name: STORY)
  String story = '';
  @JsonKey(name: AGE)
  String age = '0';
  @JsonKey(name: LANGUAGE)
  String language = '';
  @JsonKey(name: BIRTHPLACE)
  String birthplace = '';
  @JsonKey(name: TRAINNING_PLACE)
  String trainningPlace = '';
  @JsonKey(name: CIVIL_NAME)
  String civilName = '';
  @JsonKey(name: PROFESSION)
  String profession = '';
  @JsonKey(name: PUBLISHED)
  bool published = false;
  @JsonKey(name: UNIVERSE_UID)
  String? universeUID;
  @JsonKey(ignore: true)
  List<String> originalEnemiesUIDS = <String>[];
  @JsonKey(name: ENEMIES_UIDS)
  List<String> enemiesUIDS = <String>[];
  @JsonKey(ignore: true)
  List<Product> enemies = <Product>[];
  @JsonKey(ignore: true)
  List<String> originalFriendsUIDS = <String>[];
  @JsonKey(name: FRIENDS_UIDS)
  List<String> friendsUIDS = <String>[];
  @JsonKey(ignore: true)
  List<Product> friends = <Product>[];
  @JsonKey(name: USER_UID)
  String? userUID;
  @JsonKey(ignore: true)
  my_app.User? user;
  @JsonKey(ignore: true)
  ElementSource source = ElementSource.UNKNOWN;

  @override
  Product copyWith(Product product, {int depth = 1}) {
    final ret = Product()
      ..reference = product.reference
      ..uid = product.uid
      ..faceImageUrl = product.faceImageUrl
      ..imageUrl = product.imageUrl
      ..weapons = product.weapons
      ..codename = product.codename
      ..color = product.color
      ..updateDate = product.updateDate
      ..updateDateAsInt = product.updateDateAsInt
      ..creationDate = product.creationDate
      ..creationDateAsInt = product.creationDateAsInt
      ..habilities = product.habilities
      ..story = product.story
      ..age = product.age
      ..language = product.language
      ..birthplace = product.birthplace
      ..trainningPlace = product.trainningPlace
      ..civilName = product.civilName
      ..profession = product.profession
      ..published = product.published
      ..universeUID = product.universeUID
      ..enemiesUIDS.clear()
      ..enemiesUIDS = product.enemiesUIDS
      ..enemies.clear()
      ..friendsUIDS.clear()
      ..friendsUIDS = product.friendsUIDS
      ..friends.clear()
      ..userUID = product.userUID
      ..source = product.source;
    if (depth == 1) {
      for (final enemy in enemies) {
        ret.enemies.add(enemy.copyWith(enemy, depth: depth + 1));
      }
      for (final friend in friends) {
        ret.friends.add(friend.copyWith(friend, depth: depth + 1));
      }
    } else {
      // ignore: avoid_function_literals_in_foreach_calls
      enemies.forEach((enemy) => {ret.enemies.add(enemy)});
      // ignore: avoid_function_literals_in_foreach_calls
      friends.forEach((friend) => {ret.friends.add(friend)});
    }
    return ret;
  }

  @override
  Product getCopy() {
    return copyWith(this);
  }

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    map[UID] = uid;

    map[IMAGE_URL] = imageUrl.toString();
    map[FACE_IMAGE_URL] = faceImageUrl.toString();
    map[WEAPONS] = weapons;
    map[CODENAME] = codename;
    map[COLOR] = color.toString();
    map[UPDATE_DATE] = FieldValue.serverTimestamp();
    map[CREATION_DATE] =
        (creationDate == null) ? FieldValue.serverTimestamp() : creationDate;
    map[HABILITIES] = habilities;
    map[STORY] = story;
    map[AGE] = age;
    map[LANGUAGE] = language;
    map[BIRTHPLACE] = birthplace;
    map[TRAINNING_PLACE] = trainningPlace;
    map[CIVIL_NAME] = civilName;
    map[PROFESSION] = profession;
    map[PUBLISHED] = published;
    map[UNIVERSE_UID] = universeUID;
    map[ENEMIES_UIDS] = enemiesUIDS;
    map[FRIENDS_UIDS] = friendsUIDS;
    map[USER_UID] = userUID;
    return map;
  }

  /// A necessary factory constructor for creating a new Product instance
  /// from a map. Pass the map to the generated `_$ProductFromJson()` constructor.
  /// The constructor is named after the source class, in this case, Product.
  static Product _fromJson(Map<String, dynamic> json) {
    return _$ProductFromJson(json)..source = ElementSource.JSON;
  }

  ///`toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$ProductToJson`.
  Map<String, dynamic> toJson() => _$ProductToJson(this);

  List<String> _getFriendsOrEnemiesFromMap(List<dynamic>? friendOrEnemies) {
    final ret = <String>[];
    if (friendOrEnemies != null) {
      for (final friendOrEnemy in friendOrEnemies) {
        ret.add(friendOrEnemy as String);
      }
    }
    return ret;
  }

  Timestamp? getCreationDateAsTimestamp() {
    if (source == ElementSource.JSON) {
      return Helper.timestampFromInt(creationDateAsInt);
    } else {
      return null;
    }
  }

  Timestamp? getUpdateDateAsTimestamp() {
    if (source == ElementSource.JSON) {
      return Helper.timestampFromInt(updateDateAsInt);
    } else {
      return null;
    }
  }

  Color getColorObject() {
    return Helper.colorFromString(color);
  }

  Future<my_app.User?> getUser() async {
    my_app.User? ret;
    if (userUID != null && userUID!.isNotEmpty) {
      ret = user = await UsersDao().getByUId(userUID!);
    }
    return ret;
  }

  bool hasGotImage() {
    return _gotImage;
  }

  bool isGettingImage() {
    return _gettingImage;
  }

  Future<Uint8List?> getImage() async {
    return imageAsBytesFuture = _getImage();
  }

  Future<Uint8List?> getImageBytes() async {
    if (imageUrl != null &&
        await ImagesCache.isCacheEnabled() &&
        ImagesCache.containsAsUri(imageUrl!)) {
      return ImagesCache.loadAsUri(imageUrl!);
    } else if (imageAsBytes != null && imageAsBytes!.isNotEmpty) {
      return imageAsBytes;
    } else {
      _gotImage = false;
      return _getImage();
    }
  }

  Future<Uint8List?> _getImage() async {
    Uint8List? ret;
    if (imageUrl != null && imageUrl!.path.isNotEmpty) {
      if (await ImagesCache.isCacheEnabled() &&
          ImagesCache.containsAsUri(imageUrl!)) {
        _gettingImage = true;
        ret = await ImagesCache.loadAsUri(imageUrl!);
        _gotImage = true;
        _gettingImage = false;
      } else if (!_gotImage && !_gettingImage) {
        _gettingImage = true;
        final bytes = await imageUrl!.downloadBytes();
        if (bytes != null && bytes.isNotEmpty) {
          if (await ImagesCache.isCacheEnabled()) {
            unawaited(ImagesCache.writeAsUri(imageUrl!, bytes));
            imageAsBytes = null;
          } else {
            imageAsBytes = bytes;
          }
          _gotImage = true;
        }
        _gettingImage = false;
        ret = bytes;
      } else if (_gotImage && !_gettingImage) {
        ret = imageAsBytes;
      }
    }
    return ret;
  }

  Future<FullMetadata?> getImageMetaData() async {
    FullMetadata? ret;
    if (imageUrl != null && imageUrl!.path.isNotEmpty) {
      ret = await FilesDao().getMetadataAsUri(imageUrl!);
    }
    return ret;
  }

  bool hasGotFaceImage() {
    return _gotFaceImage;
  }

  bool isGettingFaceImage() {
    return _gettingFaceImage;
  }

  Future<Uint8List?> getFaceImage() async {
    return faceImageAsBytesFuture = _getFaceImage();
  }

  Future<Uint8List?> getFaceImageBytes() async {
    if (faceImageUrl != null &&
        await ImagesCache.isCacheEnabled() &&
        ImagesCache.containsAsUri(faceImageUrl!)) {
      return ImagesCache.loadAsUri(faceImageUrl!);
    } else if (faceImageAsBytes != null && faceImageAsBytes!.isNotEmpty) {
      return faceImageAsBytes;
    } else {
      _gotFaceImage = false;
      return _getFaceImage();
    }
  }

  Future<Uint8List?> _getFaceImage() async {
    Uint8List? ret;
    if (faceImageUrl != null && faceImageUrl!.path.isNotEmpty) {
      if (await ImagesCache.isCacheEnabled() &&
          ImagesCache.containsAsUri(faceImageUrl!)) {
        _gettingFaceImage = true;
        ret = await ImagesCache.loadAsUri(faceImageUrl!);
        _gotFaceImage = true;
        _gettingFaceImage = false;
      } else if (!_gotFaceImage && !_gettingFaceImage) {
        _gettingFaceImage = true;
        final bytes = await faceImageUrl!.downloadBytes();
        if (bytes != null && bytes.isNotEmpty) {
          if (await ImagesCache.isCacheEnabled()) {
            unawaited(ImagesCache.writeAsUri(faceImageUrl!, bytes));
            faceImageAsBytes = null;
          } else {
            faceImageAsBytes = bytes;
          }
          _gotFaceImage = true;
        }
        _gettingFaceImage = false;
        ret = bytes;
      } else if (_gotFaceImage && !_gettingFaceImage) {
        ret = faceImageAsBytes;
      }
    }
    return ret;
  }

  String getSanitizedCodename() {
    return Helper.stringToParameter(codename)!;
  }

  Future<String> getIdentifier() async {
    return codename.replaceAll(' ', '_');;
  }

  @override
  String toString() {
    return codename;
  }
}
