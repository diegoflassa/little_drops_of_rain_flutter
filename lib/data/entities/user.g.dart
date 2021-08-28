// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<dynamic, dynamic> json) {
  return User()
    ..uid = json['uid'] as String?
    ..imageUrl = json['image_url'] == null
        ? null
        : Uri.parse(json['image_url'] as String)
    ..email = json['email'] as String
    ..name = json['name'] as String
    ..surename = json['surename'] as String
    ..nickname = json['nickname'] as String
    ..birthdateAsInt = json['birthdate'] as int
    ..country = json['country'] as String
    ..receiveNotifications = json['receive_notifications'] as bool
    ..creationDateAsInt = json['creation_date'] as int
    ..credits = json['credits'] as String;
}

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'uid': instance.uid,
      'image_url': instance.imageUrl?.toString(),
      'email': instance.email,
      'name': instance.name,
      'surename': instance.surename,
      'nickname': instance.nickname,
      'birthdate': instance.birthdateAsInt,
      'country': instance.country,
      'receive_notifications': instance.receiveNotifications,
      'creation_date': instance.creationDateAsInt,
      'credits': instance.credits,
    };
