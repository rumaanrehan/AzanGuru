part of 'login_bloc.dart';

abstract class LoginState {}

class LoginInitialState extends LoginState {}

class LoginLoadingState extends LoginState {}

class LoginErrorState extends LoginState {
  final String? errorMessage;

  LoginErrorState({this.errorMessage});
}

class LoginSuccessState extends LoginState {}
