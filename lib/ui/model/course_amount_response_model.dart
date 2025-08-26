// To parse this JSON data, do
//
//     final courseAmountResponseModel = courseAmountResponseModelFromJson(jsonString);

import 'dart:convert';

CourseAmountResponseModel courseAmountResponseModelFromJson(String str) =>
    CourseAmountResponseModel.fromJson(json.decode(str));

String courseAmountResponseModelToJson(CourseAmountResponseModel data) =>
    json.encode(data.toJson());

class CourseAmountResponseModel {
  String? clientMutationId;
  String? discountedPrice;
  String? regularPrice;
  String? salePrice;

  CourseAmountResponseModel({
    this.clientMutationId,
    this.discountedPrice,
    this.regularPrice,
    this.salePrice,
  });

  factory CourseAmountResponseModel.fromJson(Map<String, dynamic> json) =>
      CourseAmountResponseModel(
        clientMutationId: json["clientMutationId"],
        discountedPrice: json["discountedPrice"],
        regularPrice: json["regularPrice"],
        salePrice: json["salePrice"],
      );

  Map<String, dynamic> toJson() => {
        "clientMutationId": clientMutationId,
        "discountedPrice": discountedPrice,
        "regularPrice": regularPrice,
        "salePrice": salePrice,
      };
}
