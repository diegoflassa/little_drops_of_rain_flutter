// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Config _$ConfigFromJson(Map<dynamic, dynamic> json) {
  return Config()
    ..uid = json['uid'] as String?
    ..aboutText = json['about_text'] as String?;
}

Map<String, dynamic> _$ConfigToJson(Config instance) => <String, dynamic>{
      'uid': instance.uid,
      'about_text': instance.aboutText,
    };
