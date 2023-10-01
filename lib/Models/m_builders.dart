import 'package:json_annotation/json_annotation.dart';
part 'm_builders.g.dart';

@JsonSerializable()
class BuildersModel {
  final int builder_id;
  final String builder_name;
  final String builder_website;
  final String logo;
  final int bld_proj;
  @JsonKey(defaultValue: [])
  List<String> imageUrlList;

  BuildersModel({
    required this.builder_id,
    required this.builder_name,
    required this.builder_website,
    required this.logo,
    required this.bld_proj,
    required this.imageUrlList

});

      factory BuildersModel.fromJson(Map<String, dynamic> data) =>
      _$BuildersModelFromJson(data);

  Map<String, dynamic> toJson() => _$BuildersModelToJson(this);
}