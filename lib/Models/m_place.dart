import 'package:json_annotation/json_annotation.dart';
import 'package:squarest/Models/m_geometry.dart';
part 'm_place.g.dart';

@JsonSerializable(explicitToJson: true)
class Place {
  final Geometry geometry;
  final String formatted_address;

  Place(this.geometry, this.formatted_address);

  factory Place.fromJson(Map<String, dynamic> json) => _$PlaceFromJson(json);
  Map<String, dynamic> toJson() => _$PlaceToJson(this);
}
