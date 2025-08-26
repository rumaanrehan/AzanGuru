part of 'login_bloc.dart';

abstract class LoginEvent {}

class UserLoginEvent extends LoginEvent {
  MDLLoginParam mdlLoginParam;

  UserLoginEvent({required this.mdlLoginParam});
}
