part of 'forgot_password_bloc.dart';

abstract class ForgotPasswordState {}

/// Initial state
class ForgotPasswordInitialState extends ForgotPasswordState {}

/// Loading state for OTP sending/verification/password update
class ForgotPasswordLoadingState extends ForgotPasswordState {}

/// OTP sent successfully, waiting for user input
class ForgotPasswordOtpSentState extends ForgotPasswordState {}

/// OTP verified successfully, ready for password update
class ForgotPasswordOtpVerifiedState extends ForgotPasswordState {
  final String otpToken;

  ForgotPasswordOtpVerifiedState({required this.otpToken});
}

/// Password updated successfully
class ForgotPasswordSuccessState extends ForgotPasswordState {
  final String message;

  ForgotPasswordSuccessState({this.message = 'Password reset successfully'});
}

/// Error state
class ForgotPasswordErrorState extends ForgotPasswordState {
  final String? errorMessage;

  ForgotPasswordErrorState({this.errorMessage});
}
