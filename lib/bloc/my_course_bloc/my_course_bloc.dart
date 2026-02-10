import 'dart:developer';
import 'package:azan_guru_mobile/common/util.dart';
import 'package:azan_guru_mobile/graphQL/graphql_service.dart';
import 'package:azan_guru_mobile/graphQL/queries.dart';
import 'package:azan_guru_mobile/ui/model/ag_categories_data.dart';
import 'package:azan_guru_mobile/ui/model/lesson_progress_update.dart';
import 'package:azan_guru_mobile/ui/model/mdl_course.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

part 'my_course_event.dart';

part 'my_course_state.dart';

class MyCourseBloc extends Bloc<MyCourseEvent, MyCourseState> {
  final graphQLService = GraphQLService();

  MyCourseBloc() : super(MyCourseInitial()) {
    on<GetMyCourseEvent>(_getMyCourse);
    on<LessonProgressUpdateEvent>(_lessonProgressUpdate);
    on<UpdateMyCourseCompletedEvent>(_updateMyCourseCompleted);
  }

  _getMyCourse(GetMyCourseEvent event, Emitter emit) async {
    emit(MCShowLoadingState());
    graphQLService.initClient();
    final result = await graphQLService.performQuery(
      AzanGuruQueries.myCourse,
      variables: {'id': user?.id ?? ''},
    );
    emit(MCHideLoadingState());
    if (result.hasException) {
      debugPrint(
          'graphQLErrors: ${result.exception?.graphqlErrors.toString()}');
    } else {
      final catData = result.data?['user']['studentsOptions'];
      List<MDLCourseList>? courseList = [];
      if (catData != null) {
        AgCategories data = AgCategories.fromJson(catData['studentCourse']);
        List<AgCategoriesNode>? list = data.nodes ?? [];
        courseList = [
          MDLCourseList(
            studentProgress: catData['studentProgress'] == null
                ? 0
                : catData['studentProgress'].toDouble(),
            // studentProgress: catData['studentProgress'].toDouble(),
            title: 'Your Courses',
            count: list.length,
            mdlCourse: list,
            studentCompletedLessons: catData['studentCompletedLessons'] != null
                ? StudentCompletedLessons.fromJson(
                    catData['studentCompletedLessons'],
                  )
                : null,
          ),
        ];
      }
      emit(GetMyCourseState(courseList));
    }
  }

  _lessonProgressUpdate(LessonProgressUpdateEvent event, Emitter emit) async {
    graphQLService.initClient();
    final result = await graphQLService.performQuery(
      AzanGuruQueries.lessonProgressUpdate,
    );
    if (result.hasException) {
      debugPrint(
          'graphQLErrors: ${result.exception?.graphqlErrors.toString()}');
    } else {
      final data = result.data;
      MDLLessonProgress? mdlLessonProgress;
      if (data != null) {
        mdlLessonProgress = MDLLessonProgress.fromJson(data);
      }
      emit(LessonProgressUpdateState(mdlLessonProgress: mdlLessonProgress));
    }
  }

  _updateMyCourseCompleted(UpdateMyCourseCompletedEvent event, Emitter emit) {
    emit(UpdateMyCourseCompletedState(
      courseId: event.courseId,
      lessonId: event.lessonId,
    ));
  }
}
