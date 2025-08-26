import 'dart:convert';

LoginUser loginUserFromJson(String str) => LoginUser.fromJson(json.decode(str));

String loginUserToJson(LoginUser data) => json.encode(data.toJson());

class LoginUser {
  final String? message;
  final String? loginToken;

  LoginUser({
    this.message,
    this.loginToken,
  });

  factory LoginUser.fromJson(Map<String, dynamic> json) => LoginUser(
        message: json["message"],
        loginToken: json["loginToken"],
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "loginToken": loginToken,
      };
}
