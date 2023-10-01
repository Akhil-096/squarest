import 'package:flutter/material.dart';
import 'package:google_maps_flutter_platform_interface/src/types/location.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
part 'm_resale_property.g.dart';


@JsonSerializable()
class ResalePropertyModel extends ClusterItem with ChangeNotifier {
  final int id;
  final String address;
  final double lat;
  final double lng;
  final bool type;
  final String name;
  final int floor;
  final  int total_floors;
  final int age;
  final List<int>? amenities;
  final double area;
  final int bhk;
  final double price;
  final String? description;
  final String? locality;
  final String? city;
  final int? pincode;
  final bool posted_by;
  final int? posted_by_user_id;
  final String? first_name;
  final String? last_name;
  final int? phone_number;
  final String? email_id;
  @JsonKey(defaultValue: false)
  bool? isLiked;
  final int? status;

  ResalePropertyModel({
    required this.id,
    required this.address,
    required this.lat,
    required this.lng,
    required this.type,
    required this.name,
    required this.floor,
    required this.total_floors,
    required this.age,
    this.amenities,
    required this.area,
    required this.bhk,
    required this.price,
    required this.description,
    required this.locality,
    required this.city,
    required this.pincode,
    required this.posted_by,
    required this.posted_by_user_id,
    this.first_name,
    this.last_name,
    this.phone_number,
    this.email_id,
    this.isLiked,
    this.status
  });

  void toggleLike() {
    isLiked = !isLiked!;
    notifyListeners();
  }

  factory ResalePropertyModel.fromJson(Map<String, dynamic> data) =>
      _$ResalePropertyModelFromJson(data);

  Map<String, dynamic> toJson() => _$ResalePropertyModelToJson(this);

  @override
  LatLng get location => LatLng(lat, lng);

}
