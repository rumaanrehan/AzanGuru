part of 'user_register_bloc.dart';

abstract class UserRegisterState {}

class UserRegisterInitialState extends UserRegisterState {}

class UserRegisterLoadingState extends UserRegisterState {}

class UserRegisterErrorState extends UserRegisterState {
  final String? errorMessage;

  UserRegisterErrorState({this.errorMessage});
}

class UserRegisterSuccessState extends UserRegisterState {

  final String email;
  final String password;
      UserRegisterSuccessState(this.email, this.password, );
}
