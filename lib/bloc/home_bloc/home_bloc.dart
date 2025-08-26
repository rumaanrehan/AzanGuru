import 'package:azan_guru_mobile/common/util.dart';
import 'package:azan_guru_mobile/graphQL/graphql_service.dart';
import 'package:azan_guru_mobile/graphQL/queries.dart';
import 'package:azan_guru_mobile/ui/model/ag_categories_data.dart';
import 'package:azan_guru_mobile/ui/model/mdl_course.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  // Access the singleton instance:
  final graphQLService = GraphQLService();
  HomeBloc() : super(HomeInitial()) {
    on<GetCategoriesEvent>(_getCategories);
  }

  _getCategories(GetCategoriesEvent event, Emitter emit) async {
    emit(HomeShowLoadingState());
    final result = await graphQLService
        .performQuery(AzanGuruQueries.getCategoryWiseCourseListing);
    emit(HomeHideLoadingState());
    if (result.hasException) {
      debugPrint(
          'graphQLErrors: ${result.exception?.graphqlErrors.first.toString()}');
    } else {
      final catData = result.data?['agCourseCategories'];
      print('Course Result ${result.data?['agCourseCategories']}');
      List<MDLCourseList>? courseList = [];
      if (catData != null) {
        AgCategories data = AgCategories.fromJson(catData);
        List<AgCategoriesNode>? list = data.nodes ?? [];
        List<AgCategoriesNode>? kidsCourseList = [];
        List<AgCategoriesNode>? adultCourseList = [];
        for (var element in list) {
          if (kidsCourseIds.contains(element.id)) {
            kidsCourseList.add(element);
          }
          if (adultCourseIds.contains(element.id)) {
            adultCourseList.add(element);
          }
        }
        kidsCourseList.sort((a, b) {
          return kidsCourseIds.indexOf(a.id ?? '') -
              kidsCourseIds.indexOf(b.id ?? '');
        });
        adultCourseList.sort((a, b) {
          return adultCourseIds.indexOf(a.id ?? '') -
              adultCourseIds.indexOf(b.id ?? '');
        });
        courseList = [
          MDLCourseList(
            title: 'Kids Courses',
            count: kidsCourseList.length,
            mdlCourse: kidsCourseList,
          ),
          MDLCourseList(
            title: 'Adult Courses',
            count: adultCourseList.length,
            mdlCourse: adultCourseList,
          ),
        ];
      }
      emit(GetCategoriesState(courseList));
    }
  }
}
