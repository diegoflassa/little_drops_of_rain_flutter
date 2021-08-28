// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Product _$ProductFromJson(Map<dynamic, dynamic> json) {
  return Product()
    ..uid = json['uid'] as String?
    ..imageUrl = json['image_url'] == null
        ? null
        : Uri.parse(json['image_url'] as String)
    ..faceImageUrl = json['face_image_url'] == null
        ? null
        : Uri.parse(json['face_image_url'] as String)
    ..weapons = json['weapons'] as String
    ..codename = json['codename'] as String
    ..color = json['color'] as String
    ..updateDateAsInt = json['update_date'] as int
    ..creationDateAsInt = json['creation_date'] as int
    ..habilities = json['habilities'] as String
    ..story = json['story'] as String
    ..age = json['age'] as String
    ..language = json['language'] as String
    ..birthplace = json['birthplace'] as String
    ..trainningPlace = json['trainning_place'] as String
    ..civilName = json['civil_name'] as String
    ..profession = json['profession'] as String
    ..published = json['published'] as bool
    ..universeUID = json['universe_uid'] as String?
    ..enemiesUIDS = (json['enemies_uids'] as List<dynamic>)
        .map((dynamic e) => e as String)
        .toList()
    ..friendsUIDS = (json['friends_uids'] as List<dynamic>)
        .map((dynamic e) => e as String)
        .toList()
    ..userUID = json['user_uid'] as String?;
}

Map<String, dynamic> _$ProductToJson(Product instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'image_url': instance.imageUrl?.toString(),
      'face_image_url': instance.faceImageUrl?.toString(),
      'weapons': instance.weapons,
      'codename': instance.codename,
      'color': instance.color,
      'update_date': instance.updateDateAsInt,
      'creation_date': instance.creationDateAsInt,
      'habilities': instance.habilities,
      'story': instance.story,
      'age': instance.age,
      'language': instance.language,
      'birthplace': instance.birthplace,
      'trainning_place': instance.trainningPlace,
      'civil_name': instance.civilName,
      'profession': instance.profession,
      'published': instance.published,
      'universe_uid': instance.universeUID,
      'enemies_uids': instance.enemiesUIDS,
      'friends_uids': instance.friendsUIDS,
      'user_uid': instance.userUID,
    };
