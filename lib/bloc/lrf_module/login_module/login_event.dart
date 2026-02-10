part of 'login_bloc.dart';

abstract class LoginEvent {}

class UserLoginEvent extends LoginEvent {
  MDLLoginParam mdlLoginParam;

  UserLoginEvent({required this.mdlLoginParam});
}

class LoginWithOtpEvent extends LoginEvent {
  final String mobile;
  final String otp;

  LoginWithOtpEvent({
    required this.mobile,
    required this.otp,
  });
}

class LoginWithJwtEvent extends LoginEvent {
  final String jwt;
  final String userId;

  LoginWithJwtEvent({
    required this.jwt,
    required this.userId,
  });
}

class SendOtpEvent extends LoginEvent {
  final String mobile;

  SendOtpEvent({required this.mobile});
}
