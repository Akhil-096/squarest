import 'package:json_annotation/json_annotation.dart';
part 'm_mem_plan.g.dart';

@JsonSerializable()
class MemPlan {
  final int? id;
  final int user_id;
  final String mem_plan_type;
  final int mem_plan_durn;
  final double mem_plan_amt;
  final DateTime created_on;
  final DateTime ending_on;


  MemPlan({
    this.id,
    required this.user_id,
    required this.mem_plan_type,
    required this.mem_plan_durn,
    required this.mem_plan_amt,
    required this.created_on,
    required this.ending_on,
  });

  factory MemPlan.fromJson(Map<String, dynamic> data) =>
      _$MemPlanFromJson(data);

  Map<String, dynamic> toJson() => _$MemPlanToJson(this);


}