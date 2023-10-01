// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'm_builders.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BuildersModel _$BuildersModelFromJson(Map<String, dynamic> json) =>
    BuildersModel(
      builder_id: json['builder_id'] as int,
      builder_name: json['builder_name'] as String,
      builder_website: json['builder_website'] as String,
      logo: json['logo'] as String,
      bld_proj: json['bld_proj'] as int,
      imageUrlList: (json['imageUrlList'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );

Map<String, dynamic> _$BuildersModelToJson(BuildersModel instance) =>
    <String, dynamic>{
      'builder_id': instance.builder_id,
      'builder_name': instance.builder_name,
      'builder_website': instance.builder_website,
      'logo': instance.logo,
      'bld_proj': instance.bld_proj,
      'imageUrlList': instance.imageUrlList,
    };
