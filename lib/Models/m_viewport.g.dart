// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'm_viewport.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ViewPort _$ViewPortFromJson(Map<String, dynamic> json) => ViewPort(
      NorthEast.fromJson(json['northeast'] as Map<String, dynamic>),
      SouthWest.fromJson(json['southwest'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ViewPortToJson(ViewPort instance) => <String, dynamic>{
      'northeast': instance.northeast.toJson(),
      'southwest': instance.southwest.toJson(),
    };
