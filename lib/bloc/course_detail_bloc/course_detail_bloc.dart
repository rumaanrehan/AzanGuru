import 'dart:async';

import 'package:azan_guru_mobile/graphQL/graphql_service.dart';
import 'package:azan_guru_mobile/graphQL/queries.dart';
import 'package:azan_guru_mobile/ui/model/ag_course_detail.dart';
import 'package:azan_guru_mobile/ui/model/ag_lesson_list.dart';
import 'package:azan_guru_mobile/ui/model/course_amount_response_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
part 'course_detail_event.dart';
part 'course_detail_state.dart';

class CourseDetailBloc extends Bloc<CourseDetailEvent, CourseDetailState> {
  /// BLoC to manage fetching and updating course details.
  final graphQLService = GraphQLService();

  /// Constructor for the [CourseDetailBloc] class.
  /// Sets up event handlers to handle [GetCourseDetailEvent],
  /// [GetCourseLessonsEvent], [UpdateCompletedLessonEvent],
  /// and [GetCourseAmountEvent].
  CourseDetailBloc() : super(CourseDetailInitial()) {
    on<GetCourseDetailEvent>(_getCourseDetail);
    on<GetCourseLessonsEvent>(_getCourseLesson);
    on<UpdateCompletedLessonEvent>(_updateCompleteLesson);
    on<GetCourseAmountEvent>(_getCourseAmount);
  }

  /// Handles the [GetCourseDetailEvent] to fetch the course detail using
  /// [graphQLService.performQuery].
  ///
  /// Emits [ShowCourseDetailLoadingState] before making the query and
  /// [HideCourseDetailLoadingState] after the query is complete.
  ///
  /// If the query is successful, it extracts the course detail from the
  /// response data and emits a [GetCourseDetailState] with the fetched data.
  /// If the query has an exception, it logs the error.
  _getCourseDetail(GetCourseDetailEvent event, Emitter emit) async {
    emit(ShowCourseDetailLoadingState()); // Emit loading state

    final result = await graphQLService.performQuery(
      // Perform GraphQL query
      AzanGuruQueries.getCourseDetail,
      variables: {"id": event.courseId},
    );

    emit(HideCourseDetailLoadingState()); // Emit loading state

    if (result.hasException) {
      // If query has an exception
      debugPrint(
          'graphQLErrors: ${result.exception?.graphqlErrors.toString()}');
    } else {
      final catData = result.data?['agCourseCategory']; // Extract course data
      AgCourseDetail? data =
          catData != null ? AgCourseDetail.fromJson(catData) : null;
      emit(GetCourseDetailState(agCourseDetail: data)); // Emit fetched data
    }
  }

  /// Handles the [GetCourseLessonsEvent] to fetch the lessons list of a course
  /// using [graphQLService.performQuery].
  ///
  /// Emits [ShowCourseDetailLoadingState] before making the query and
  /// [HideCourseDetailLoadingState] after the query is complete.
  ///
  /// If the query is successful, it extracts the lessons list from the
  /// response data and emits a [GetCourseLessonsState] with the fetched data.
  /// If the query has an exception, it logs the error.
  _getCourseLesson(GetCourseLessonsEvent event, Emitter emit) async {
    emit(ShowCourseDetailLoadingState());
    final result = await graphQLService.performQuery(
      AzanGuruQueries.getLessonsList,
      variables: {"id": event.courseId},
    );
    emit(HideCourseDetailLoadingState());
    if (result.hasException) {
      debugPrint(
          'graphQLErrors: ${result.exception?.graphqlErrors.toString()}');
      debugPrint(
          'graphQLErrors: ${result.exception?.linkException?.toString()}');
      return;
    }
    final catData = result.data;
    if (catData == null) {
      return;
    }
    try {
      final data = AgCourseLessonList.fromJson(catData);
      emit(GetCourseLessonsState(agCourseLessonList: data));
    } on FormatException catch (e) {
      debugPrint('Error parsing JSON: $e');
    } on Object catch (e, stackTrace) {
      debugPrint('Uncaught error: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Handles the [GetCourseAmountEvent] to fetch the amount of a course
  /// using [graphQLService.performMutation].
  ///
  /// Emits [ShowCourseDetailLoadingState] before making the mutation and
  /// [HideCourseDetailLoadingState] after the mutation is complete.
  ///
  /// If the mutation is successful, it extracts the course amount data from the
  /// response data and emits a [GetCourseAmountState] with the fetched data.
  /// If the mutation has an exception, it logs the error.
  _getCourseAmount(GetCourseAmountEvent event, Emitter emit) async {
    emit(ShowCourseDetailLoadingState());
    final result = await graphQLService.performMutation(
      AzanGuruQueries.getCourseAmount,
    );
    emit(HideCourseDetailLoadingState());
    if (result.hasException) {
      debugPrint(
          'graphQLErrors: ${result.exception?.graphqlErrors.toString()}');
      debugPrint(
          'graphQLErrors: ${result.exception?.linkException.toString()}');
    } else {
      final catData = result.data?['getProductPriceFromACF'];
      CourseAmountResponseModel? data;
      if (catData != null) {
        data = CourseAmountResponseModel.fromJson(catData);
      }
      emit(GetCourseAmountState(courseAmountResponseModel: data));
    }
  }

  /// Handles the [UpdateCompletedLessonEvent] to update the completion status
  /// of a lesson.
  ///
  /// Emits [UpdateCompletedLessonState] with the updated lesson ID.
  ///
  /// Returns nothing.
  Future<void> _updateCompleteLesson(
    UpdateCompletedLessonEvent event,
    Emitter<CourseDetailState> emit,
  ) async {
    emit(UpdateCompletedLessonState(lessonId: event.lessonId));
  }
}
