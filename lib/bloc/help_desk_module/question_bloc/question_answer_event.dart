part of 'question_answer_bloc.dart';

abstract class QuestionAnswerEvent {}

class GetQuestionSearchEvent extends QuestionAnswerEvent {
  String? search;
  bool showLoader;

  GetQuestionSearchEvent({this.search, this.showLoader = true});
}

class GetAnswerDetailEvent extends QuestionAnswerEvent {
  String? id;

  GetAnswerDetailEvent({this.id});
}
