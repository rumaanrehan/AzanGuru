import 'dart:developer';

import 'package:azan_guru_mobile/graphQL/graphql_service.dart';
import 'package:azan_guru_mobile/graphQL/queries.dart';
import 'package:azan_guru_mobile/mixin/validation_mixin.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

part 'reset_password_event.dart';

part 'reset_password_state.dart';

class ResetPasswordBloc extends Bloc<ResetPasswordEvent, ResetPasswordState>
    with ValidationMixin {
  // Access the singleton instance:
  final graphQLService = GraphQLService();
  ResetPasswordBloc() : super(ResetPasswordInitialState()) {
    on<ResetUserPasswordEvent>(
      (event, emit) async {
        if (isFieldEmpty(event.username)) {
          emit(
            ResetPasswordErrorState(errorMessage: "Please enter username."),
          );
        } else {
          emit(ResetPasswordLoadingState());
          final result = await graphQLService.performMutation(
            AzanGuruQueries.resetPasswordEmail,
            variables: {"username": event.username},
          );
          if (result.hasException) {
            debugPrint(
                'graphQLErrors: ${result.exception?.graphqlErrors.toString()}');
            String errorMessgae =
                result.exception!.graphqlErrors.map((e) => e.message).join(',');
            emit(ResetPasswordErrorState(errorMessage: errorMessgae));
          } else {
            emit(ResetPasswordSuccessState());
          }
        }
      },
    );
  }
}
