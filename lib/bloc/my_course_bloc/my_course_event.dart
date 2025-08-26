part of 'my_course_bloc.dart';

abstract class MyCourseEvent {}

class GetMyCourseEvent extends MyCourseEvent {}

class LessonProgressUpdateEvent extends MyCourseEvent {}

class UpdateMyCourseCompletedEvent extends MyCourseEvent {
  final String? courseId;
  final String? lessonId;

  UpdateMyCourseCompletedEvent({
    required this.courseId,
    required this.lessonId,
  });
}
