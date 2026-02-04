import 'package:azan_guru_mobile/graphQL/graphql_service.dart';
import 'package:azan_guru_mobile/graphQL/queries.dart';
import 'package:azan_guru_mobile/ui/model/mdl_choose_question.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

part 'choose_course_event.dart';

part 'choose_course_state.dart';

class ChooseCourseBloc extends Bloc<ChooseCourseEvent, ChooseCourseState> {
  final graphQLService = GraphQLService();

  ChooseCourseBloc() : super(ChooseCourseInitialState()) {
    on<GetChooseCourseListEvent>(_getChooseCourseListEvent);
  }

  _getChooseCourseListEvent(
      GetChooseCourseListEvent event, Emitter emit) async {
    emit(ChooseCourseLoadingState());
    final result = await graphQLService.performQuery(
      AzanGuruQueries.getChooseCourses,
    );
    if (result.hasException) {
      debugPrint(
          'graphQLErrors: ${result.exception?.graphqlErrors.toString()}');
      emit(ChooseCourseErrorState());
    } else {
      final dataInfo = result.data;
      debugPrint("dataInfo ===== $dataInfo");
      AgQuestions? mdlChooseQuestion;
      if (dataInfo != null) {
        mdlChooseQuestion = AgQuestions.fromJson(dataInfo['agQuestions']);
      }
      return emit(
          ChooseCourseSuccessState(mdlChooseQuestion: mdlChooseQuestion));
    }
  }
}
