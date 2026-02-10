part of 'forgot_password_bloc.dart';

abstract class ForgotPasswordEvent {}

/// Event to send OTP to the user's email
class SendForgotPasswordOtpEvent extends ForgotPasswordEvent {
  final String email;

  SendForgotPasswordOtpEvent({required this.email});
}

/// Event to verify the OTP received by user
class VerifyForgotPasswordOtpEvent extends ForgotPasswordEvent {
  final String email;
  final String otp;

  VerifyForgotPasswordOtpEvent({
    required this.email,
    required this.otp,
  });
}

/// Event to update password after OTP verification
class UpdateForgotPasswordEvent extends ForgotPasswordEvent {
  final String email;
  final String newPassword;
  final String otpToken;

  UpdateForgotPasswordEvent({
    required this.email,
    required this.newPassword,
    required this.otpToken,
  });
}
