// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'm_geometry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Geometry _$GeometryFromJson(Map<String, dynamic> json) => Geometry(
      Location.fromJson(json['location'] as Map<String, dynamic>),
      ViewPort.fromJson(json['viewport'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$GeometryToJson(Geometry instance) => <String, dynamic>{
      'location': instance.location.toJson(),
      'viewport': instance.viewport.toJson(),
    };
