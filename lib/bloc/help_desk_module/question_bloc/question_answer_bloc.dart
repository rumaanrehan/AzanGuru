import 'dart:developer';
import 'package:azan_guru_mobile/graphQL/graphql_service.dart';
import 'package:azan_guru_mobile/graphQL/queries.dart';
import 'package:azan_guru_mobile/ui/model/help_desk_detail.dart';
import 'package:azan_guru_mobile/ui/model/mdl_question_answer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

part 'question_answer_event.dart';

part 'question_answer_state.dart';

class QuestionAnswerBloc
    extends Bloc<QuestionAnswerEvent, QuestionAnswerState> {
  final graphQLService = GraphQLService();

  QuestionAnswerBloc() : super(QuestionAnswerInitialState()) {
    on<GetQuestionSearchEvent>(_getQuestionSearchEvent);
    on<GetAnswerDetailEvent>(_getAnswerDetailEvent);
  }

  _getQuestionSearchEvent(GetQuestionSearchEvent event, Emitter emit) async {
    if (event.showLoader) {
      emit(QuestionAnswerLoadingState());
    }
    final result = await graphQLService.performQuery(
      AzanGuruQueries.agHelpDesks,
      variables: {"search": event.search},
    );
    if (result.hasException) {
      debugPrint(
          'graphQLErrors: ${result.exception?.graphqlErrors.toString()}');
      emit(QuestionAnswerErrorState());
    } else {
      MDLQuestionAnswer? mdlQuestionAnswer;
      final dataInfo = result.data?["agHelpDesks"];
      debugPrint('graphResponse: $dataInfo');
      mdlQuestionAnswer = MDLQuestionAnswer.fromJson(dataInfo);
      emit(QuestionAnswerSuccessState(mdlQuestionAnswer: mdlQuestionAnswer));
    }
  }

  _getAnswerDetailEvent(GetAnswerDetailEvent event, Emitter emit) async {
    emit(QuestionAnswerLoadingState());
    final result = await graphQLService.performQuery(
      AzanGuruQueries.agHelpDeskBy,
      variables: {"id": event.id},
    );
    if (result.hasException) {
      debugPrint(
          'graphQLErrors: ${result.exception?.graphqlErrors.toString()}');
      emit(QuestionAnswerErrorState());
    } else {
      final dataInfo = result.data?["agHelpDeskBy"];
      debugPrint('graphResponse: $dataInfo');
      HelpDeskDetail helpDeskDetail = HelpDeskDetail.fromJson(dataInfo);
      emit(AnswerDetailSuccessState(helpDeskDetail: helpDeskDetail));
    }
  }
}
