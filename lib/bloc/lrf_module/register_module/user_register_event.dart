part of 'user_register_bloc.dart';

abstract class UserRegisterEvent {}

class RegisterUserEvent extends UserRegisterEvent {
  MDLUserRegisterParam mdlUserRegisterParam;

  RegisterUserEvent({required this.mdlUserRegisterParam});
}
