part of 'question_answer_bloc.dart';

abstract class QuestionAnswerState {}

class QuestionAnswerInitialState extends QuestionAnswerState {}

class QuestionAnswerLoadingState extends QuestionAnswerState {}

class QuestionAnswerErrorState extends QuestionAnswerState {}

class QuestionAnswerSuccessState extends QuestionAnswerState {
  MDLQuestionAnswer? mdlQuestionAnswer;

  QuestionAnswerSuccessState({this.mdlQuestionAnswer});
}

class AnswerDetailSuccessState extends QuestionAnswerState {
  HelpDeskDetail? helpDeskDetail;

  AnswerDetailSuccessState({this.helpDeskDetail});
}
