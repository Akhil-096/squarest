// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'm_project.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Project _$ProjectFromJson(Map<String, dynamic> json) => Project(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      name_of_project: json['name_of_project'] as String,
      project_village: json['project_village'] as String,
      project_district: json['project_district'] as String,
      pincode: json['pincode'] as int,
      applicationno: json['applicationno'] as String,
      promoter_name: json['promoter_name'] as String,
      sanctioned_bldg_count: json['sanctioned_bldg_count'] as int? ?? 0,
      proposed_completion_date:
          Project._fromJsonPropDate(json['proposed_completion_date'] as String),
      total_num_apts: json['total_num_apts'] as int? ?? 0,
      total_bkd_apts: json['total_bkd_apts'] as int? ?? 0,
      last_modified_date:
          Project._fromJsonLastDate(json['last_modified_date'] as String),
      project_is_township: json['project_is_township'] as bool? ?? false,
      one_bhk: json['one_bhk'] as bool? ?? false,
      two_bhk: json['two_bhk'] as bool? ?? false,
      three_bhk: json['three_bhk'] as bool? ?? false,
      four_bhk: json['four_bhk'] as bool? ?? false,
      min_price: (json['min_price'] as num?)?.toDouble() ?? 0.0,
      max_price: (json['max_price'] as num?)?.toDouble() ?? 0.0,
      min_area: (json['min_area'] as num).toDouble(),
      max_area: (json['max_area'] as num).toDouble(),
      id: json['id'] as int,
      builder_id: json['builder_id'] as int? ?? 0,
      builder_name: json['builder_name'] as String? ?? ' ',
      videos: json['videos'] as String? ?? ' ',
      vr_videos: json['vr_videos'] as String? ?? ' ',
      imageUrlList: (json['imageUrlList'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      isLiked: json['isLiked'] as bool? ?? false,
      project_views_total: json['project_views_total'] as int? ?? 0,
      insert_date: Project._fromJsonInsertDate(json['insert_date'] as String),
    );

Map<String, dynamic> _$ProjectToJson(Project instance) => <String, dynamic>{
      'applicationno': instance.applicationno,
      'lat': instance.lat,
      'lng': instance.lng,
      'name_of_project': instance.name_of_project,
      'pincode': instance.pincode,
      'project_district': instance.project_district,
      'project_village': instance.project_village,
      'promoter_name': instance.promoter_name,
      'sanctioned_bldg_count': instance.sanctioned_bldg_count,
      'proposed_completion_date':
          instance.proposed_completion_date.toIso8601String(),
      'total_num_apts': instance.total_num_apts,
      'total_bkd_apts': instance.total_bkd_apts,
      'last_modified_date': instance.last_modified_date.toIso8601String(),
      'project_is_township': instance.project_is_township,
      'one_bhk': instance.one_bhk,
      'two_bhk': instance.two_bhk,
      'three_bhk': instance.three_bhk,
      'four_bhk': instance.four_bhk,
      'min_price': instance.min_price,
      'max_price': instance.max_price,
      'min_area': instance.min_area,
      'max_area': instance.max_area,
      'id': instance.id,
      'builder_id': instance.builder_id,
      'builder_name': instance.builder_name,
      'videos': instance.videos,
      'vr_videos': instance.vr_videos,
      'imageUrlList': instance.imageUrlList,
      'isLiked': instance.isLiked,
      'project_views_total': instance.project_views_total,
      'insert_date': instance.insert_date.toIso8601String(),
    };

Projects _$ProjectsFromJson(Map<String, dynamic> json) => Projects(
      projects: (json['projects'] as List<dynamic>)
          .map((e) => Project.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ProjectsToJson(Projects instance) => <String, dynamic>{
      'projects': instance.projects,
    };
