// To parse this JSON data, do
//
//     final userOrder = userOrderFromJson(jsonString);

import 'dart:convert';

import 'package:azan_guru_mobile/ui/model/key_value_model.dart';

UserOrder userOrderFromJson(String str) => UserOrder.fromJson(json.decode(str));

String userOrderToJson(UserOrder data) => json.encode(data.toJson());

class UserOrder {
  List<KeyValueModel>? orders;
  String? number;
  dynamic error;

  UserOrder({
    this.orders,
    this.number,
    this.error,
  });

  factory UserOrder.fromJson(Map<String, dynamic> json) => UserOrder(
        orders: json["orders"] == null
            ? []
            : List<KeyValueModel>.from(
                json["orders"]!.map((x) => KeyValueModel.fromJson(x))),
        number: json["number"] ?? '',
        error: json["error"],
      );

  Map<String, dynamic> toJson() => {
        "orders": orders == null
            ? []
            : List<dynamic>.from(orders!.map((x) => x.toJson())),
        "error": error,
        "number": number,
      };
}
