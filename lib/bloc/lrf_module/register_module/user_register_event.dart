part of 'user_register_bloc.dart';

@immutable
abstract class UserRegisterEvent {}

class RegisterSendOtpEvent extends UserRegisterEvent {
  final String name;
  final String email;
  final String mobile;

  RegisterSendOtpEvent({required this.name, required this.email, required this.mobile});
}

class RegisterVerifyOtpEvent extends UserRegisterEvent {
  final String name;
  final String email;
  final String mobile;
  final String otp;

  RegisterVerifyOtpEvent({required this.name, required this.email, required this.mobile, required this.otp});
}

class RegisterUserEvent extends UserRegisterEvent {
  final MDLUserRegisterParam mdlUserRegisterParam;

  RegisterUserEvent({required this.mdlUserRegisterParam});
}
