// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'm_place.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Place _$PlaceFromJson(Map<String, dynamic> json) => Place(
      Geometry.fromJson(json['geometry'] as Map<String, dynamic>),
      json['formatted_address'] as String,
    );

Map<String, dynamic> _$PlaceToJson(Place instance) => <String, dynamic>{
      'geometry': instance.geometry.toJson(),
      'formatted_address': instance.formatted_address,
    };
