part of 'login_bloc.dart';

@immutable
abstract class LoginState {}

class LoginInitialState extends LoginState {}

class LoginLoadingState extends LoginState {}

class LoginSuccessState extends LoginState {
  final bool isPurchased;
  final bool isSubscribed;
  LoginSuccessState({this.isPurchased = false, this.isSubscribed = false});
}

class LoginErrorState extends LoginState {
  final String? errorMessage;
  LoginErrorState({this.errorMessage});
}

class LoginOtpSentState extends LoginState {}

class LoginRegistrationRequiredState extends LoginState {
  final String mobile;
  LoginRegistrationRequiredState({required this.mobile});
}
