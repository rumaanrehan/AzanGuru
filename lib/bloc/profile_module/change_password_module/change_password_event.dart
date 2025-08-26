part of 'change_password_bloc.dart';


abstract class ChangePasswordEvent {}

class PasswordChangeEvent extends ChangePasswordEvent{
  MDLChangePasswordParam mdlChangePasswordParam;
  PasswordChangeEvent({required this.mdlChangePasswordParam});
}