import 'dart:developer';

import 'package:azan_guru_mobile/graphQL/graphql_service.dart';
import 'package:azan_guru_mobile/graphQL/queries.dart';
import 'package:azan_guru_mobile/mixin/validation_mixin.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

part 'forgot_password_event.dart';
part 'forgot_password_state.dart';

class ForgotPasswordBloc extends Bloc<ForgotPasswordEvent, ForgotPasswordState>
    with ValidationMixin {
  final graphQLService = GraphQLService();

  ForgotPasswordBloc() : super(ForgotPasswordInitialState()) {
    /// Handle sending OTP to email
    on<SendForgotPasswordOtpEvent>((event, emit) async {
      try {
        if (!validateEmailAddress(event.email)) {
          emit(ForgotPasswordErrorState(
            errorMessage: "Please enter a valid email address.",
          ));
          return;
        }

        emit(ForgotPasswordLoadingState());

        final result = await graphQLService.performMutation(
          AzanGuruQueries.sendForgotPasswordOtp,
          variables: {"email": event.email},
        );

        if (result.hasException) {
          debugPrint(
            'GraphQL Error: ${result.exception?.graphqlErrors.toString()}',
          );
          final errorMessage = result.exception?.graphqlErrors
                  .map((e) => e.message)
                  .join(',') ??
              'Failed to send OTP. Please try again.';
          emit(ForgotPasswordErrorState(errorMessage: errorMessage));
        } else if (result.data != null) {
          final success =
              result.data?['sendForgotPasswordOtp']?['success'] ?? false;
          if (success) {
            emit(ForgotPasswordOtpSentState());
          } else {
            final message =
                result.data?['sendForgotPasswordOtp']?['message'] ??
                    'Failed to send OTP';
            emit(ForgotPasswordErrorState(errorMessage: message));
          }
        }
      } catch (e) {
        debugPrint('Exception: $e');
        emit(ForgotPasswordErrorState(
          errorMessage: e.toString(),
        ));
      }
    });

    /// Handle OTP verification
    on<VerifyForgotPasswordOtpEvent>((event, emit) async {
      try {
        if (isFieldEmpty(event.otp)) {
          emit(ForgotPasswordErrorState(
            errorMessage: "Please enter the OTP.",
          ));
          return;
        }

        emit(ForgotPasswordLoadingState());

        final result = await graphQLService.performMutation(
          AzanGuruQueries.verifyForgotPasswordOtp,
          variables: {
            "email": event.email,
            "otp": event.otp,
          },
        );

        if (result.hasException) {
          debugPrint(
            'GraphQL Error: ${result.exception?.graphqlErrors.toString()}',
          );
          final errorMessage = result.exception?.graphqlErrors
                  .map((e) => e.message)
                  .join(',') ??
              'Invalid OTP. Please try again.';
          emit(ForgotPasswordErrorState(errorMessage: errorMessage));
        } else if (result.data != null) {
          final success =
              result.data?['verifyForgotPasswordOtp']?['success'] ?? false;
          if (success) {
            final otpToken =
                result.data?['verifyForgotPasswordOtp']?['otpToken'] ?? '';
            emit(ForgotPasswordOtpVerifiedState(otpToken: otpToken));
          } else {
            final message =
                result.data?['verifyForgotPasswordOtp']?['message'] ??
                    'OTP verification failed';
            emit(ForgotPasswordErrorState(errorMessage: message));
          }
        }
      } catch (e) {
        debugPrint('Exception: $e');
        emit(ForgotPasswordErrorState(
          errorMessage: e.toString(),
        ));
      }
    });

    /// Handle password update after OTP verification
    on<UpdateForgotPasswordEvent>((event, emit) async {
      try {
        if (isFieldEmpty(event.newPassword)) {
          emit(ForgotPasswordErrorState(
            errorMessage: "Please enter a new password.",
          ));
          return;
        }

        if (!passwordValidation(event.newPassword)) {
          emit(ForgotPasswordErrorState(
            errorMessage:
                "Password must be at least 8 characters and cannot contain spaces.",
          ));
          return;
        }

        emit(ForgotPasswordLoadingState());

        final result = await graphQLService.performMutation(
          AzanGuruQueries.updatePasswordAfterOtp,
          variables: {
            "email": event.email,
            "newPassword": event.newPassword,
            "otpToken": event.otpToken,
          },
        );

        if (result.hasException) {
          debugPrint(
            'GraphQL Error: ${result.exception?.graphqlErrors.toString()}',
          );
          final errorMessage = result.exception?.graphqlErrors
                  .map((e) => e.message)
                  .join(',') ??
              'Failed to update password. Please try again.';
          emit(ForgotPasswordErrorState(errorMessage: errorMessage));
        } else if (result.data != null) {
          final success =
              result.data?['updatePasswordAfterOtp']?['success'] ?? false;
          if (success) {
            final message =
                result.data?['updatePasswordAfterOtp']?['message'] ??
                    'Password reset successfully';
            emit(ForgotPasswordSuccessState(message: message));
          } else {
            final message =
                result.data?['updatePasswordAfterOtp']?['message'] ??
                    'Failed to update password';
            emit(ForgotPasswordErrorState(errorMessage: message));
          }
        }
      } catch (e) {
        debugPrint('Exception: $e');
        emit(ForgotPasswordErrorState(
          errorMessage: e.toString(),
        ));
      }
    });
  }
}
