import 'package:json_annotation/json_annotation.dart';
part 'm_search_project.g.dart';

@JsonSerializable()
class SearchProjectModel{
  final int id;
  final String applicationno;
  final String name_of_project;
  final String promoter_name;
  final String? builder_name;
  final String project_village;
  final String project_district;
  final double lat;
  final double lng;

  SearchProjectModel({
    required this.id,
    required this.applicationno,
    required this.name_of_project,
    required this.promoter_name,
    this.builder_name,
    required this.project_village,
    required this.project_district,
    required this.lat,
    required this.lng
  });

  factory SearchProjectModel.fromJson(Map<String, dynamic> data) =>
      _$SearchProjectModelFromJson(data);

  Map<String, dynamic> toJson() => _$SearchProjectModelToJson(this);

}
