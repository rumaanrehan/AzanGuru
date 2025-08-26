part of 'message_question_bloc.dart';

@immutable
abstract class MessageQuestionState {}

class MessageQuestionInitialState extends MessageQuestionState {}

class MessageQuestionLoadingState extends MessageQuestionState {}

class MessageQuestionErrorState extends MessageQuestionState {
  final String? errorMessage;

  MessageQuestionErrorState({this.errorMessage});
}

class MessageQuestionSuccessState extends MessageQuestionState {}
