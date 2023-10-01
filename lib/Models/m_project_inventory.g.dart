// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'm_project_inventory.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProjectInventory _$ProjectInventoryFromJson(Map<String, dynamic> json) =>
    ProjectInventory(
      building_name: json['building_name'] as String?,
      apartment_type: json['apartment_type'] as String?,
      min_area: (json['min_area'] as num?)?.toDouble(),
      total_apts: json['total_apts'] as int?,
      booked_apts: json['booked_apts'] as int?,
      max_area: (json['max_area'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$ProjectInventoryToJson(ProjectInventory instance) =>
    <String, dynamic>{
      'building_name': instance.building_name,
      'apartment_type': instance.apartment_type,
      'min_area': instance.min_area,
      'total_apts': instance.total_apts,
      'booked_apts': instance.booked_apts,
      'max_area': instance.max_area,
    };
