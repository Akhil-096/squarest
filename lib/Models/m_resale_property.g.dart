// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'm_resale_property.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResalePropertyModel _$ResalePropertyModelFromJson(Map<String, dynamic> json) =>
    ResalePropertyModel(
      id: json['id'] as int,
      address: json['address'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      type: json['type'] as bool,
      name: json['name'] as String,
      floor: json['floor'] as int,
      total_floors: json['total_floors'] as int,
      age: json['age'] as int,
      amenities:
          (json['amenities'] as List<dynamic>?)?.map((e) => e as int).toList(),
      area: (json['area'] as num).toDouble(),
      bhk: json['bhk'] as int,
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String?,
      locality: json['locality'] as String?,
      city: json['city'] as String?,
      pincode: json['pincode'] as int?,
      posted_by: json['posted_by'] as bool,
      posted_by_user_id: json['posted_by_user_id'] as int?,
      first_name: json['first_name'] as String?,
      last_name: json['last_name'] as String?,
      phone_number: json['phone_number'] as int?,
      email_id: json['email_id'] as String?,
      isLiked: json['isLiked'] as bool? ?? false,
      status: json['status'] as int?,
    );

Map<String, dynamic> _$ResalePropertyModelToJson(
        ResalePropertyModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'address': instance.address,
      'lat': instance.lat,
      'lng': instance.lng,
      'type': instance.type,
      'name': instance.name,
      'floor': instance.floor,
      'total_floors': instance.total_floors,
      'age': instance.age,
      'amenities': instance.amenities,
      'area': instance.area,
      'bhk': instance.bhk,
      'price': instance.price,
      'description': instance.description,
      'locality': instance.locality,
      'city': instance.city,
      'pincode': instance.pincode,
      'posted_by': instance.posted_by,
      'posted_by_user_id': instance.posted_by_user_id,
      'first_name': instance.first_name,
      'last_name': instance.last_name,
      'phone_number': instance.phone_number,
      'email_id': instance.email_id,
      'isLiked': instance.isLiked,
      'status': instance.status,
    };
