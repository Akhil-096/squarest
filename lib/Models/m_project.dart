import 'package:flutter/foundation.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter_platform_interface/src/types/location.dart';
import 'package:json_annotation/json_annotation.dart';
part 'm_project.g.dart';

@JsonSerializable()
class Project extends ClusterItem with ChangeNotifier {
  final String applicationno;
  final double lat;
  final double lng;
  final String name_of_project;
  final int pincode;
  final String project_district;
  final String project_village;
  final String promoter_name;
  @JsonKey(defaultValue: 0)
  final int sanctioned_bldg_count;
  @JsonKey(fromJson: _fromJsonPropDate)
  final DateTime proposed_completion_date;
  @JsonKey(defaultValue: 0)
  final int total_num_apts;
  @JsonKey(defaultValue: 0)
  final int total_bkd_apts;
  @JsonKey(fromJson: _fromJsonLastDate)
  final DateTime last_modified_date;
  @JsonKey(defaultValue: false)
  final bool project_is_township;
  @JsonKey(defaultValue: false)
  final bool one_bhk;
  @JsonKey(defaultValue: false)
  final bool two_bhk;
  @JsonKey(defaultValue: false)
  final bool three_bhk;
  @JsonKey(defaultValue: false)
  final bool four_bhk;
  @JsonKey(defaultValue: 0.0)
  final double min_price;
  @JsonKey(defaultValue: 0.0)
  final double max_price;
  final double min_area;
  final double max_area;
  final int id;
  @JsonKey(defaultValue: 0)
  final int builder_id;
  @JsonKey(defaultValue: " ")
  final String builder_name;
  @JsonKey(defaultValue: " ")
  final String videos;
  @JsonKey(defaultValue: " ")
  final String vr_videos;
  @JsonKey(defaultValue: [])
  List<String> imageUrlList;
  @JsonKey(defaultValue: false)
  bool isLiked;
  @JsonKey(defaultValue: 0)
  final int project_views_total;
  @JsonKey(fromJson: _fromJsonInsertDate)
  final DateTime insert_date;

  Project(
      {required this.lat,
      required this.lng,
      required this.name_of_project,
      required this.project_village,
      required this.project_district,
      required this.pincode,
      required this.applicationno,
      required this.promoter_name,
      required this.sanctioned_bldg_count,
      required this.proposed_completion_date,
      required this.total_num_apts,
      required this.total_bkd_apts,
      required this.last_modified_date,
      required this.project_is_township,
      required this.one_bhk,
      required this.two_bhk,
      required this.three_bhk,
      required this.four_bhk,
      required this.min_price,
      required this.max_price,
      required this.min_area,
      required this.max_area,
      required this.id,
      required this.builder_id,
      required this.builder_name,
      required this.videos,
      required this.vr_videos,
      required this.imageUrlList,
        required this.isLiked,
      required this.project_views_total,
      required this.insert_date});

  void toggleLike() {
    isLiked = !isLiked;
    notifyListeners();
  }

  factory Project.fromJson(Map<String, dynamic> json) =>
      _$ProjectFromJson(json);
  Map<String, dynamic> toJson() => _$ProjectToJson(this);

  static DateTime _fromJsonPropDate(String proposed_completion_date) =>
      DateTime.parse(proposed_completion_date);

  static DateTime _fromJsonLastDate(String last_modified_date) =>
      DateTime.parse(last_modified_date);

  static DateTime _fromJsonInsertDate(String insert_date) =>
      DateTime.parse(insert_date);

  @override
  LatLng get location => LatLng(lat, lng);
}

@JsonSerializable()
class Projects {
  Projects({
    required this.projects,
  });

  factory Projects.fromJson(Map<String, dynamic> json) =>
      _$ProjectsFromJson(json);
  Map<String, dynamic> toJson() => _$ProjectsToJson(this);

  final List<Project> projects;
}
