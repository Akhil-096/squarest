import 'package:json_annotation/json_annotation.dart';
import 'm_latlng.dart';
part 'm_viewport.g.dart';

@JsonSerializable(explicitToJson: true)
class ViewPort {
  ViewPort(this.northeast, this.southwest);

  NorthEast northeast;
  SouthWest southwest;

  factory ViewPort.fromJson(Map<String, dynamic> json) =>
      _$ViewPortFromJson(json);
  Map<String, dynamic> toJson() => _$ViewPortToJson(this);
}
