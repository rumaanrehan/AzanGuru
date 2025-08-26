part of 'message_question_bloc.dart';

@immutable
abstract class MessageQuestionEvent {}

class QuestionMessageEvent extends MessageQuestionEvent {
  final String? description;
  final String? email;
  final String? title;
  final String? phone;

  QuestionMessageEvent({this.description, this.title, this.phone, this.email});
}


