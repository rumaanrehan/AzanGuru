part of 'choose_course_bloc.dart';

abstract class ChooseCourseState {}

class ChooseCourseInitialState extends ChooseCourseState {}

class ChooseCourseLoadingState extends ChooseCourseState {}

class ChooseCourseErrorState extends ChooseCourseState {}

class ChooseCourseSuccessState extends ChooseCourseState {
  AgQuestions? mdlChooseQuestion;

  ChooseCourseSuccessState({this.mdlChooseQuestion});
}
