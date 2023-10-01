import 'package:json_annotation/json_annotation.dart';

part 'm_user.g.dart';

@JsonSerializable()
class UserProfileModel {
  int id;
  String? first_name;
  String? last_name;
  int? phone_number;
  String? email_id;
  String? firebase_user_id;
  // @JsonKey(defaultValue: false)
  // bool? isPaid;

  UserProfileModel(
      {required this.id,
      required this.first_name,
      required this.last_name,
      required this.phone_number,
      required this.email_id,
        this.firebase_user_id,
      // this.isPaid
      });

  factory UserProfileModel.fromJson(Map<String, dynamic> data) =>
      _$UserProfileModelFromJson(data);

  Map<String, dynamic> toJson() => _$UserProfileModelToJson(this);
}
