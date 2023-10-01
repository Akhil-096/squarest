import 'package:json_annotation/json_annotation.dart';
part 'm_latlng.g.dart';

@JsonSerializable()
class Location {
  final double lat;
  final double lng;

  Location({required this.lat, required this.lng});

  factory Location.fromJson(Map<String, dynamic> json) =>
      _$LocationFromJson(json);
  Map<String, dynamic> toJson() => _$LocationToJson(this);
}

@JsonSerializable()
class NorthEast {
  final double lat;
  final double lng;

  NorthEast({required this.lat, required this.lng});

  factory NorthEast.fromJson(Map<String, dynamic> json) =>
      _$NorthEastFromJson(json);
  Map<String, dynamic> toJson() => _$NorthEastToJson(this);
}

@JsonSerializable()
class SouthWest {
  final double lat;
  final double lng;

  SouthWest({required this.lat, required this.lng});

  factory SouthWest.fromJson(Map<String, dynamic> json) =>
      _$SouthWestFromJson(json);
  Map<String, dynamic> toJson() => _$SouthWestToJson(this);
}
