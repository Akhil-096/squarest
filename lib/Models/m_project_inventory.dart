import 'package:json_annotation/json_annotation.dart';
part 'm_project_inventory.g.dart';

@JsonSerializable()
class ProjectInventory {
  String? building_name;
  String? apartment_type;
  double? min_area;
  int? total_apts;
  int? booked_apts;
  double? max_area;

  ProjectInventory({
    this.building_name,
    this.apartment_type,
    this.min_area,
    this.total_apts,
    this.booked_apts,
    this.max_area,
  });

  factory ProjectInventory.fromJson(Map<String, dynamic> data) =>
      _$ProjectInventoryFromJson(data);

  Map<String, dynamic> toJson() => _$ProjectInventoryToJson(this);

}

class Building {
  String buildingName;
  Inventory inventory;

  Building(this.buildingName, this.inventory);
}

class Inventory {
  String apartmentType;
  double minArea;
  int totatApts;
  int bookedApts;
  double maxArea;

  Inventory(this.apartmentType, this.bookedApts, this.maxArea, this.minArea,
      this.totatApts);
}


