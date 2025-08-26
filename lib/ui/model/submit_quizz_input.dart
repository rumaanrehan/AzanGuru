// To parse this JSON data, do
//
//     final submitQuizRequest = submitQuizRequestFromJson(jsonString);

import 'dart:convert';

SubmitQuizInput submitQuizRequestFromJson(String str) =>
    SubmitQuizInput.fromJson(json.decode(str));

String submitQuizRequestToJson(SubmitQuizInput data) =>
    json.encode(data.toJson());

class SubmitQuizInput {
  List<Quiz>? quizzes;
  int? lessonDbId;
  int? studentId;

  /// for local use only
  String? lessonId;

  SubmitQuizInput({
    this.quizzes,
    this.lessonDbId,
    this.studentId,
    this.lessonId,
  });

  factory SubmitQuizInput.fromJson(Map<String, dynamic> json) =>
      SubmitQuizInput(
        quizzes: json["quizzes"] == null
            ? []
            : List<Quiz>.from(json["quizzes"]!.map((x) => Quiz.fromJson(x))),
        lessonDbId: json["lessonId"],
        studentId: json["studentId"],
      );

  Map<String, dynamic> toJson() => {
        "quizzes": quizzes == null
            ? []
            : List<dynamic>.from(quizzes!.map((x) => x.toJson())),
        "lessonId": lessonDbId,
        "studentId": studentId,
      };
}

class Quiz {
  int? quizzId;
  String? quizAnswers;

  Quiz({
    this.quizzId,
    this.quizAnswers,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) => Quiz(
        quizzId: json["quizzId"],
        quizAnswers: json["quizAnswers"],
      );

  Map<String, dynamic> toJson() => {
        "quizzId": quizzId,
        "quizAnswers": quizAnswers,
      };
}
