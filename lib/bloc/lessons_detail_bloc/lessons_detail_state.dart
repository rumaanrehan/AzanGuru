part of 'lessons_detail_bloc.dart';

abstract class LessonDetailState {}

final class LessonDetailInitial extends LessonDetailState {}

final class ShowLessonDetailLoadingState extends LessonDetailState {}

final class HideLessonDetailLoadingState extends LessonDetailState {}

class LessonsDetailErrorState extends LessonDetailState {
  final String? message;

  LessonsDetailErrorState(this.message);
}

class GetLessonDetailState extends LessonDetailState {
  LessonDetail? lessonDetail;
  GetLessonDetailState({required this.lessonDetail});
}

class UpdateRequestState extends LessonDetailState {
  final SubmitQuizInput request;
  UpdateRequestState({required this.request});
}

class SubmitQuizState extends LessonDetailState {
  final String? lessonId;
  final int? lessonDbId;
  // final int? quizzId;
  // final String? quizAnswers;
  // final bool? isAnswerSubmitted;

  SubmitQuizState({
    this.lessonId,
    this.lessonDbId,
    // this.quizzId,
    // this.quizAnswers,
    // this.isAnswerSubmitted,
  });
}

class SubmitHomeworkState extends LessonDetailState {}

class SubmitLessonState extends LessonDetailState {
  final int? type;
  final int? lessonDbId;
  final String? lessonId;

  SubmitLessonState({
    required this.type,
    required this.lessonId,
    required this.lessonDbId,
  });
}

class GetSubmittedQuizzAnswersByLessonIdState extends LessonDetailState {
  final SubmittedAnswersResponse? response;

  GetSubmittedQuizzAnswersByLessonIdState({required this.response});
}
