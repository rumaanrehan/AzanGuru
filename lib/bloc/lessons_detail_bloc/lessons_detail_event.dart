part of 'lessons_detail_bloc.dart';

abstract class LessonDetailEvent {}

class GetLessonDetailEvent extends LessonDetailEvent {
  final String? lessonId;
  GetLessonDetailEvent({required this.lessonId});
}

class UpdateRequestEvent extends LessonDetailEvent {
  final SubmitQuizInput request;
  UpdateRequestEvent({required this.request});
}

class SubmitQuizEvent extends LessonDetailEvent {
  final SubmitQuizInput? request;
  SubmitQuizEvent({this.request});
}

class SubmitHomeworkEvent extends LessonDetailEvent {
  final int? lessonId;
  final int? studentId;
  final int? homeworkId;
  final String? file;
  SubmitHomeworkEvent({
    required this.lessonId,
    required this.studentId,
    required this.homeworkId,
    required this.file,
  });
}

class SubmitLessonEvent extends LessonDetailEvent {
  final int? lessonDbId;
  final String? lessonId;
  // 1 - Homework
  final int? type;

  SubmitLessonEvent({
    required this.lessonId,
    required this.lessonDbId,
    this.type,
  });
}

class GetSubmittedQuizzAnswersByLessonIdEvent extends LessonDetailEvent {
  final int? lessonDbId;

  GetSubmittedQuizzAnswersByLessonIdEvent({required this.lessonDbId});
}
