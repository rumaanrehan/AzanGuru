import 'dart:developer';
import 'package:azan_guru_mobile/graphQL/graphql_service.dart';
import 'package:azan_guru_mobile/graphQL/queries.dart';
import 'package:azan_guru_mobile/mixin/validation_mixin.dart';
import 'package:azan_guru_mobile/ui/model/mdl_login_param.dart';
import 'package:azan_guru_mobile/ui/model/user_data.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

import '../../../service/local_storage/local_storage_keys.dart';
import '../../../service/local_storage/storage_manager.dart';

part 'user_register_event.dart';

part 'user_register_state.dart';

class UserRegisterBloc extends Bloc<UserRegisterEvent, UserRegisterState>
    with ValidationMixin {
  // Access the singleton instance:
  final graphQLService = GraphQLService();

  UserRegisterBloc() : super(UserRegisterInitialState()) {
    on<RegisterUserEvent>(
      (event, emit) async {
        if (isFieldEmpty(event.mdlUserRegisterParam.firstName ?? "")) {
          emit(
            UserRegisterErrorState(errorMessage: "Please enter full name."),
          );
        } /*else if (isFieldEmpty(event.mdlUserRegisterParam.lastName ?? "")) {
          emit(UserRegisterErrorState(errorMessage: "Please enter last name."));
        }*/
        else if (isFieldEmpty(event.mdlUserRegisterParam.email ?? "")) {
          emit(UserRegisterErrorState(errorMessage: "Please enter email."));
        } else if (isFieldEmpty(event.mdlUserRegisterParam.phoneNumber ?? "")) {
          emit(UserRegisterErrorState(
              errorMessage: "Please enter phone number."));
        } else if (!validateEmailAddress(
            event.mdlUserRegisterParam.email ?? "")) {
          emit(UserRegisterErrorState(
              errorMessage: "Please enter valid email."));
        } else if (isFieldEmpty(event.mdlUserRegisterParam.password ?? "")) {
          emit(UserRegisterErrorState(errorMessage: "Please enter password."));
        } else if (!passwordValidation(
            event.mdlUserRegisterParam.password ?? "")) {
          emit(
            UserRegisterErrorState(
                errorMessage: "Please enter minimum 8 character password."),
          );
        } else if (isFieldEmpty(
            event.mdlUserRegisterParam.confirmPassword ?? "")) {
          emit(
            UserRegisterErrorState(
                errorMessage: "Please enter confirm password."),
          );
        } else if (confirmPasswordValidation(
            event.mdlUserRegisterParam.password ?? "",
            event.mdlUserRegisterParam.confirmPassword ?? "")) {
          emit(
            UserRegisterErrorState(
                errorMessage:
                    "Please enter password and confirm password are same."),
          );
        }
        // else if (event.mdlUserRegisterParam.studentAge == null ||
        //     event.mdlUserRegisterParam.studentAge == 0) {
        //   emit(UserRegisterErrorState(errorMessage: "Please enter your age."));
        // } else if (event.mdlUserRegisterParam.studentGander == null) {
        //   emit(
        //     UserRegisterErrorState(
        //         errorMessage: "Please select your gender type."),
        //   );
        // }
        //  else if (isFieldEmpty(event.mdlUserRegisterParam.country ?? "")) {
        //   emit(
        //     UserRegisterErrorState(errorMessage: "Please select your country."),
        //   );
        // } else if (isFieldEmpty(event.mdlUserRegisterParam.state ?? "")) {
        //   emit(
        //     UserRegisterErrorState(errorMessage: "Please select your state."),
        //   );
        // } else if (isFieldEmpty(event.mdlUserRegisterParam.city ?? "")) {
        //   emit(UserRegisterErrorState(errorMessage: "Please enter your city."));
        // } else if (isFieldEmpty(event.mdlUserRegisterParam.pinCode ?? "")) {
        //   emit(
        //     UserRegisterErrorState(errorMessage: "Please enter your pin code."),
        //   );
        // }
        else {
          emit(UserRegisterLoadingState());
          // Split the email address at the '@' symbol
          List<String> parts =
              (event.mdlUserRegisterParam.email ?? "").split('@');
          // Extract the part before the '@' symbol
          String username = parts[0];
          event.mdlUserRegisterParam.username = username;
          final result = await graphQLService.performMutation(
            AzanGuruQueries.createAccount,
            variables: RegisterUserInput(
              username: username,
              email: event.mdlUserRegisterParam.email ?? '',
              phoneNumber: event.mdlUserRegisterParam.phoneNumber ?? '',
              password: event.mdlUserRegisterParam.password ?? '',
              firstName: event.mdlUserRegisterParam.firstName ?? '',
              // lastName: event.mdlUserRegisterParam.lastName ?? '',
              // studentGander: event.mdlUserRegisterParam.studentGander ?? '',
              // studentAge: event.mdlUserRegisterParam.studentAge,
              studentGander: '',
              studentAge: 0,
            ).toMap(),
          );
          if (result.hasException) {
            debugPrint(
                'graphQLErrors: ${result.exception?.graphqlErrors.toString()}');
            String errorMessgae =
                result.exception!.graphqlErrors.map((e) => e.message).join(',');
            emit(
              UserRegisterErrorState(
                errorMessage: errorMessgae.isEmpty
                    ? "Internal server error"
                    : errorMessgae,
              ),
            );
          } else {
            UserData userData =
                UserData.fromJson(result.data?['registerUserWithCustomMeta']);
            debugPrint("UserData>>>>>>>>> register ${userData.toJson()}");
            if (userData.error?.isNotEmpty ?? false) {
              emit(UserRegisterErrorState(errorMessage: userData.error));
            } else {
              emit(
                UserRegisterSuccessState(
                  userData.user?.email ?? '',
                  event.mdlUserRegisterParam.password ?? '',
                ),
              );
            }
          }
          // emit(UserRegisterSuccessState());
        }
      },
    );
  }
}
