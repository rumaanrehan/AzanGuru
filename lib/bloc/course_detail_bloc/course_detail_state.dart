part of 'course_detail_bloc.dart';

abstract class CourseDetailState {}

final class CourseDetailInitial extends CourseDetailState {}

final class ShowCourseDetailLoadingState extends CourseDetailState {}

final class HideCourseDetailLoadingState extends CourseDetailState {}

final class GetCourseDetailState extends CourseDetailState {
  final AgCourseDetail? agCourseDetail;

  GetCourseDetailState({required this.agCourseDetail});
}

final class GetCourseLessonsState extends CourseDetailState {
  final AgCourseLessonList? agCourseLessonList;

  GetCourseLessonsState({required this.agCourseLessonList});
}

class UpdateCompletedLessonState extends CourseDetailState {
  String? lessonId;
  UpdateCompletedLessonState({required this.lessonId});
}

class GetCourseAmountState extends CourseDetailState {
  CourseAmountResponseModel? courseAmountResponseModel;
  GetCourseAmountState({required this.courseAmountResponseModel});
}
