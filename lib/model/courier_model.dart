// To parse this JSON data, do
//
//     final courierModel = courierModelFromJson(jsonString);

import 'dart:convert';

CourierModel courierModelFromJson(String str) =>
    CourierModel.fromJson(json.decode(str));

String courierModelToJson(CourierModel data) => json.encode(data.toJson());

class CourierModel {
  String? name;
  String? pinImage;
  String? serviceCode;
  String? originCountry;
  bool? international;
  bool? domestic;
  bool? onDemand;
  String? status;
  List<PackageCategory>? packageCategories;

  CourierModel({
    this.name,
    this.pinImage,
    this.serviceCode,
    this.originCountry,
    this.international,
    this.domestic,
    this.onDemand,
    this.status,
    this.packageCategories,
  });

  factory CourierModel.fromJson(Map<String, dynamic> json) => CourierModel(
    name: json["name"],
    pinImage: json["pin_image"],
    serviceCode: json["service_code"],
    originCountry: json["origin_country"],
    international: json["international"],
    domestic: json["domestic"],
    onDemand: json["on_demand"],
    status: json["status"],
    packageCategories: json["package_categories"] == null
        ? []
        : List<PackageCategory>.from(
            json["package_categories"]!.map((x) => PackageCategory.fromJson(x)),
          ),
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "pin_image": pinImage,
    "service_code": serviceCode,
    "origin_country": originCountry,
    "international": international,
    "domestic": domestic,
    "on_demand": onDemand,
    "status": status,
    "package_categories": packageCategories == null
        ? []
        : List<dynamic>.from(packageCategories!.map((x) => x.toJson())),
  };
}

class PackageCategory {
  int? id;
  String? category;

  PackageCategory({this.id, this.category});

  factory PackageCategory.fromJson(Map<String, dynamic> json) =>
      PackageCategory(id: json["id"], category: json["category"]);

  Map<String, dynamic> toJson() => {"id": id, "category": category};
}
