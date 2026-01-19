// To parse this JSON data, do
//
//     final userData = userDataFromJson(jsonString);

import 'dart:convert';

import 'package:azan_guru_mobile/ui/model/user.dart';

UserData userDataFromJson(String str) => UserData.fromJson(json.decode(str));

String userDataToJson(UserData data) => json.encode(data.toJson());

class UserData {
  String? authToken;
  String? refreshToken;
  String? error;
  String? databaseId;
  User? user;

  UserData({
    this.authToken,
    this.refreshToken,
    this.error,
    this.databaseId,
    this.user,
  });

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
        authToken: json["authToken"],
        refreshToken: json["refreshToken"],
        error: json["error"],
        databaseId: json["databaseId"]?.toString(),
        user: json["user"] == null ? null : User.fromJson(json["user"]),
      );

  Map<String, dynamic> toJson() => {
        "authToken": authToken,
        "refreshToken": refreshToken,
        "error": error,
        "databaseId": databaseId,
        "user": user?.toJson(),
      };
}
