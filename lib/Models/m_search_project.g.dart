// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'm_search_project.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchProjectModel _$SearchProjectModelFromJson(Map<String, dynamic> json) =>
    SearchProjectModel(
      id: json['id'] as int,
      applicationno: json['applicationno'] as String,
      name_of_project: json['name_of_project'] as String,
      promoter_name: json['promoter_name'] as String,
      builder_name: json['builder_name'] as String?,
      project_village: json['project_village'] as String,
      project_district: json['project_district'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );

Map<String, dynamic> _$SearchProjectModelToJson(SearchProjectModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'applicationno': instance.applicationno,
      'name_of_project': instance.name_of_project,
      'promoter_name': instance.promoter_name,
      'builder_name': instance.builder_name,
      'project_village': instance.project_village,
      'project_district': instance.project_district,
      'lat': instance.lat,
      'lng': instance.lng,
    };
