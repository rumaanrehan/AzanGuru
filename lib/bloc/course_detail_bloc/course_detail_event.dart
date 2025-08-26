// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'course_detail_bloc.dart';

abstract class CourseDetailEvent {}

class GetCourseDetailEvent extends CourseDetailEvent {
  String? courseId;
  GetCourseDetailEvent({
    required this.courseId,
  });
}

class GetCourseLessonsEvent extends CourseDetailEvent {
  String? courseId;
  GetCourseLessonsEvent({required this.courseId});
}

class UpdateCompletedLessonEvent extends CourseDetailEvent {
  String? lessonId;
  UpdateCompletedLessonEvent({required this.lessonId});
}

class GetCourseAmountEvent extends CourseDetailEvent {
  String? courseId;
  GetCourseAmountEvent({required this.courseId});
}
