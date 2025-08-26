// To parse this JSON data, do
//
//     final submittedAnswersResponse = submittedAnswersResponseFromJson(jsonString);

import 'dart:convert';

import 'package:azan_guru_mobile/ui/model/key_value_model.dart';

SubmittedAnswersResponse submittedAnswersResponseFromJson(String str) =>
    SubmittedAnswersResponse.fromJson(json.decode(str));

String submittedAnswersResponseToJson(SubmittedAnswersResponse data) =>
    json.encode(data.toJson());

class SubmittedAnswersResponse {
  List<KeyValueModel>? data;
  dynamic error;

  SubmittedAnswersResponse({
    this.data,
    this.error,
  });

  factory SubmittedAnswersResponse.fromJson(Map<String, dynamic> json) =>
      SubmittedAnswersResponse(
        data: json["data"] == null
            ? []
            : List<KeyValueModel>.from(
                json["data"]!.map((x) => KeyValueModel.fromJson(x))),
        error: json["error"],
      );

  Map<String, dynamic> toJson() => {
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
        "error": error,
      };
}
