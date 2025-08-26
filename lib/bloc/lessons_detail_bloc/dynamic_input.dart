import 'package:flutter/foundation.dart';

// Define a class to represent individual quiz data
@immutable
class QuizData {
  final int quizzId;
  final String quizAnswers;

  const QuizData(this.quizzId, this.quizAnswers);
}

Map<String, dynamic> buildSubmitQuizInput(
    List<QuizData> quizDataList, int lessonId, int studentId) {
  final List<Map<String, dynamic>> quizzes = quizDataList
      .map((quizData) => {
            "quizzId": quizData.quizzId,
            "quizAnswers": quizData.quizAnswers,
          })
      .toList();

  return {
    "quizzes": quizzes,
    "lessonId": lessonId,
    "studentId": studentId,
  };
}
