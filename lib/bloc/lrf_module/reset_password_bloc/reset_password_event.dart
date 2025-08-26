part of 'reset_password_bloc.dart';

abstract class ResetPasswordEvent {}

class ResetUserPasswordEvent extends ResetPasswordEvent {
  String username;

  ResetUserPasswordEvent({required this.username});
}
