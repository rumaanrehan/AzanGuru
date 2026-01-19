part of 'user_register_bloc.dart';

@immutable
abstract class UserRegisterState {}

class UserRegisterInitialState extends UserRegisterState {}

class UserRegisterLoadingState extends UserRegisterState {}

class UserRegisterSuccessState extends UserRegisterState {
  final String email;
  final String password;

  UserRegisterSuccessState(this.email, this.password);
}

class UserRegisterErrorState extends UserRegisterState {
  final String? errorMessage;

  UserRegisterErrorState({this.errorMessage});
}

class RegisterOtpSentState extends UserRegisterState {}
