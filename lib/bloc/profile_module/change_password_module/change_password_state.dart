part of 'change_password_bloc.dart';

abstract class ChangePasswordState {}

class ChangePasswordInitialState extends ChangePasswordState {}

class ChangePasswordLoadingState extends ChangePasswordState {}

class ChangePasswordErrorState extends ChangePasswordState {
  final String? errorMessage;

  ChangePasswordErrorState({this.errorMessage});
}

class ChangePasswordSuccessState extends ChangePasswordState {}
