import 'package:json_annotation/json_annotation.dart';

import 'm_geometry.dart';
part 'm_search_address.g.dart';

@JsonSerializable()
class SearchAddressModel {
  final List<CandidatesModel> candidates;
  final String status;

  SearchAddressModel({
   required this.candidates,
   required this.status
});
  factory SearchAddressModel.fromJson(Map<String, dynamic> json) =>
      _$SearchAddressModelFromJson(json);
  Map<String, dynamic> toJson() => _$SearchAddressModelToJson(this);

}

@JsonSerializable()
class CandidatesModel {
  final String formatted_address;
  final Geometry geometry;
  final String name;
  CandidatesModel({
    required this.formatted_address,
    required this.geometry,
    required this.name
  });
  factory CandidatesModel.fromJson(Map<String, dynamic> json) =>
      _$CandidatesModelFromJson(json);
  Map<String, dynamic> toJson() => _$CandidatesModelToJson(this);

}

// @JsonSerializable()
// class Geometry {
//   final Location location;
//   final Viewport viewport;
//   Geometry({
//     required this.location,
//     required this.viewport
// });
//   factory Geometry.fromJson(Map<String, dynamic> json) =>
//       _$GeometryFromJson(json);
//   Map<String, dynamic> toJson() => _$GeometryToJson(this);
//
// }

// @JsonSerializable()
// class Location {
//   final double lat;
//   final double lng;
//   Location({
//     required this.lat,
//     required this.lng,
// });
//   factory Location.fromJson(Map<String, dynamic> json) =>
//       _$LocationFromJson(json);
//   Map<String, dynamic> toJson() => _$LocationToJson(this);
//
// }

// @JsonSerializable()
// class Viewport {
//   final Northeast northeast;
//   final Southwest southwest;
//   Viewport({
//     required this.northeast,
//     required this.southwest});
//   factory Viewport.fromJson(Map<String, dynamic> json) =>
//       _$ViewportFromJson(json);
//   Map<String, dynamic> toJson() => _$ViewportToJson(this);
//
// }

// @JsonSerializable()
// class Southwest {
//   final double lat;
//   final double lng;
//   Southwest({
//     required this.lat,
//     required this.lng
//   });
//   factory Southwest.fromJson(Map<String, dynamic> json) =>
//       _$SouthwestFromJson(json);
//   Map<String, dynamic> toJson() => _$SouthwestToJson(this);
//
// }
//
// @JsonSerializable()
// class Northeast {
//   final double lat;
//   final double lng;
//   Northeast({
//     required this.lat,
//     required this.lng
//   });
//   factory Northeast.fromJson(Map<String, dynamic> json) =>
//       _$NortheastFromJson(json);
//   Map<String, dynamic> toJson() => _$NortheastToJson(this);
//
// }