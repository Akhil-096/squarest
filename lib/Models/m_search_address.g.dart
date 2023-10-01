// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'm_search_address.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchAddressModel _$SearchAddressModelFromJson(Map<String, dynamic> json) =>
    SearchAddressModel(
      candidates: (json['candidates'] as List<dynamic>)
          .map((e) => CandidatesModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: json['status'] as String,
    );

Map<String, dynamic> _$SearchAddressModelToJson(SearchAddressModel instance) =>
    <String, dynamic>{
      'candidates': instance.candidates,
      'status': instance.status,
    };

CandidatesModel _$CandidatesModelFromJson(Map<String, dynamic> json) =>
    CandidatesModel(
      formatted_address: json['formatted_address'] as String,
      geometry: Geometry.fromJson(json['geometry'] as Map<String, dynamic>),
      name: json['name'] as String,
    );

Map<String, dynamic> _$CandidatesModelToJson(CandidatesModel instance) =>
    <String, dynamic>{
      'formatted_address': instance.formatted_address,
      'geometry': instance.geometry,
      'name': instance.name,
    };
