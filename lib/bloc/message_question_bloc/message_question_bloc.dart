import 'dart:developer';
import 'package:azan_guru_mobile/graphQL/graphql_service.dart';
import 'package:azan_guru_mobile/graphQL/queries.dart';
import 'package:azan_guru_mobile/mixin/validation_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'message_question_event.dart';

part 'message_question_state.dart';

class MessageQuestionBloc
    extends Bloc<MessageQuestionEvent, MessageQuestionState>
    with ValidationMixin {
  final graphQLService = GraphQLService();

  MessageQuestionBloc() : super(MessageQuestionInitialState()) {
    on<QuestionMessageEvent>(_questionMessageEvent);
  }

  _questionMessageEvent(QuestionMessageEvent event, Emitter emit) async {
    if (isFieldEmpty(event.title ?? "")) {
      emit(
        MessageQuestionErrorState(
          errorMessage: "Please enter title.",
        ),
      );
    } else if (isFieldEmpty(event.email ?? "")) {
      emit(
        MessageQuestionErrorState(errorMessage: "Please enter your email."),
      );
    } else if (isFieldEmpty(event.description ?? "")) {
      emit(
        MessageQuestionErrorState(errorMessage: "Please enter description."),
      );
    } else {
      emit(MessageQuestionLoadingState());
      final result = await graphQLService.performQuery(
        AzanGuruQueries.sendQuestionByEmail,
        variables: {
          'email': event.email ?? '',
          'phone': event.phone ?? '',
          'description': event.description ?? "",
          'subject': "",
          'title': event.title ?? "",
        },
      );
      if (result.hasException) {
        debugPrint('graphQLErrors: ${result.exception?.graphqlErrors.toString()}');
        emit(
          MessageQuestionErrorState(
            errorMessage: (result.exception?.graphqlErrors.isNotEmpty == true)
                ? result.exception!.graphqlErrors.first.message
                : result.exception?.linkException?.toString() ??
                "Something went wrong. Please try again.",
          ),
        );
      } else {
        emit(MessageQuestionSuccessState());
      }
      debugPrint("GraphQL response: ${result.data}");
    }
  }
}
