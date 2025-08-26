part of 'reset_password_bloc.dart';

abstract class ResetPasswordState {}

class ResetPasswordInitialState extends ResetPasswordState {}

class ResetPasswordLoadingState extends ResetPasswordState {}

class ResetPasswordErrorState extends ResetPasswordState {
  final String? errorMessage;

  ResetPasswordErrorState({this.errorMessage});
}

class ResetPasswordSuccessState extends ResetPasswordState {}
