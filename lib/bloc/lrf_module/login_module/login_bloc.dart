import 'dart:developer';

import 'package:azan_guru_mobile/graphQL/graphql_service.dart';
import 'package:azan_guru_mobile/graphQL/queries.dart';
import 'package:azan_guru_mobile/mixin/validation_mixin.dart';
import 'package:azan_guru_mobile/service/local_storage/local_storage_keys.dart';
import 'package:azan_guru_mobile/service/local_storage/storage_manager.dart';
import 'package:azan_guru_mobile/ui/model/mdl_login_param.dart';
import 'package:azan_guru_mobile/ui/model/user_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'login_event.dart';

part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> with ValidationMixin {
  // Access the singleton instance:
  final graphQLService = GraphQLService();
  LoginBloc() : super(LoginInitialState()) {
    on<UserLoginEvent>(
      (event, emit) async {
        if (isFieldEmpty(event.mdlLoginParam.userName ?? "")) {
          emit(LoginErrorState(errorMessage: "Please enter user name."));
        } else if (isFieldEmpty(event.mdlLoginParam.password ?? "")) {
          emit(LoginErrorState(errorMessage: "Please enter password."));
        } else if (!passwordValidation(event.mdlLoginParam.password ?? "")) {
          emit(LoginErrorState(
              errorMessage: "Please enter minimum 8 character password."));
        } else {
          emit(LoginLoadingState());
          graphQLService.initClient(addToken: false);
          final result = await graphQLService.performMutation(
            AzanGuruQueries.loginUser,
            variables: event.mdlLoginParam.toMap(),
          );
          if (result.hasException) {
            debugPrint(
                'graphQLErrors: ${result.exception?.graphqlErrors.toString()}');
            // String errorMessgae =
            //     result.exception!.graphqlErrors.map((e) => e.message).join(',');
            emit(LoginErrorState(errorMessage: 'Invalid Email or Password.'));
          } else {
            // final loginData = result.data?['login'];
            // UserData userData = UserData.fromJson(loginData);
            // debugPrint("UserData>>>>>>>>> login ${userData.toJson()}");
            // StorageManager.instance.setUserSession(userDataToJson(userData));
            // StorageManager.instance
            //     .setString(LocalStorageKeys.prefAuthToken, userData.authToken!);
            // StorageManager.instance.setString(
            //     LocalStorageKeys.prefRefreshToken, userData.refreshToken!);
            // StorageManager.instance
            //     .setBool(LocalStorageKeys.prefUserLogin, true);
            // await StorageManager.getInstance().remove(LocalStorageKeys.prefGuestLogin);
            // emit(LoginSuccessState());
            final loginData = result.data?['login'];
            UserData userData = UserData.fromJson(loginData);

// Save login session
            await StorageManager.instance.setUserSession(userDataToJson(userData));
            await StorageManager.instance.setString(LocalStorageKeys.prefAuthToken, userData.authToken!);
            await StorageManager.instance.setString(LocalStorageKeys.prefRefreshToken, userData.refreshToken!);
            await StorageManager.instance.setBool(LocalStorageKeys.prefUserLogin, true);
            await StorageManager.instance.remove(LocalStorageKeys.prefGuestLogin);

// ✅ NEW: Call getSubscriptions and update StorageManager
            final email = userData.user?.email ?? ''; // adjust based on user_data.dart
            final response = await GraphQLService().performQuery(r'''
  query GetSubscriptions($email: String!) {
    getSubscriptions(email: $email) {
      orders {
        key
        value
      }
    }
  }
''', variables: {"email": email});

            bool isSubbed = false;
            bool isPurchased = false;
            final orders = response.data?['getSubscriptions']?['orders'] as List<dynamic>? ?? [];

            for (final item in orders) {
              final key = item['key']?.toString().toLowerCase();
              final value = item['value']?.toString().toLowerCase();
              if (key == 'subscription' && (value == 'true' || value == 'active')) {
                isSubbed = true;
              }
              if (key == 'status' && value == 'completed') {
                isPurchased = true;
              }
            }

            await StorageManager.instance.setBool('isUserHasSubscription', isSubbed);
            await StorageManager.instance.setBool('isCoursePurchased', isPurchased);

// Emit success
            emit(LoginSuccessState());

          }
        }
      },
    );
  }
}
