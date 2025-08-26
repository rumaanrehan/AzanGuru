part of 'my_course_bloc.dart';

abstract class MyCourseState {}

final class MyCourseInitial extends MyCourseState {}

final class MCShowLoadingState extends MyCourseState {}

final class MCHideLoadingState extends MyCourseState {}

final class GetMyCourseState extends MyCourseState {
  final List<MDLCourseList>? nodes;

  GetMyCourseState(this.nodes);
}

final class LessonProgressUpdateState extends MyCourseState {
  final MDLLessonProgress? mdlLessonProgress;

  LessonProgressUpdateState({this.mdlLessonProgress});
}

class UpdateMyCourseCompletedState extends MyCourseState {
  final String? courseId;
  final String? lessonId;

  UpdateMyCourseCompletedState({
    required this.courseId,
    required this.lessonId,
  });
}
