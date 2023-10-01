import 'package:json_annotation/json_annotation.dart';
import 'package:squarest/Models/m_latlng.dart';
import 'package:squarest/Models/m_viewport.dart';

part 'm_geometry.g.dart';

@JsonSerializable(explicitToJson: true)
class Geometry {
  final Location location;
  final ViewPort viewport;

  Geometry(this.location, this.viewport);

  factory Geometry.fromJson(Map<String, dynamic> json) =>
      _$GeometryFromJson(json);
  Map<String, dynamic> toJson() => _$GeometryToJson(this);
}
