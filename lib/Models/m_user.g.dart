// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'm_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProfileModel _$UserProfileModelFromJson(Map<String, dynamic> json) =>
    UserProfileModel(
      id: json['id'] as int,
      first_name: json['first_name'] as String?,
      last_name: json['last_name'] as String?,
      phone_number: json['phone_number'] as int?,
      email_id: json['email_id'] as String?,
      firebase_user_id: json['firebase_user_id'] as String?,
    );

Map<String, dynamic> _$UserProfileModelToJson(UserProfileModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'first_name': instance.first_name,
      'last_name': instance.last_name,
      'phone_number': instance.phone_number,
      'email_id': instance.email_id,
      'firebase_user_id': instance.firebase_user_id,
    };
