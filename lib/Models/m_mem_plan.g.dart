// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'm_mem_plan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MemPlan _$MemPlanFromJson(Map<String, dynamic> json) => MemPlan(
      id: json['id'] as int?,
      user_id: json['user_id'] as int,
      mem_plan_type: json['mem_plan_type'] as String,
      mem_plan_durn: json['mem_plan_durn'] as int,
      mem_plan_amt: (json['mem_plan_amt'] as num).toDouble(),
      created_on: DateTime.parse(json['created_on'] as String),
      ending_on: DateTime.parse(json['ending_on'] as String),
    );

Map<String, dynamic> _$MemPlanToJson(MemPlan instance) => <String, dynamic>{
      'id': instance.id,
      'user_id': instance.user_id,
      'mem_plan_type': instance.mem_plan_type,
      'mem_plan_durn': instance.mem_plan_durn,
      'mem_plan_amt': instance.mem_plan_amt,
      'created_on': instance.created_on.toIso8601String(),
      'ending_on': instance.ending_on.toIso8601String(),
    };
