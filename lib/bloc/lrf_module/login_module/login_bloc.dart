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
import 'package:azan_guru_mobile/ui/model/user.dart';
import 'package:azan_guru_mobile/ui/auth/otp_auth_service.dart';
import 'package:azan_guru_mobile/service/digits_service.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> with ValidationMixin {
  final GraphQLService graphQLService = GraphQLService();
  final OtpAuthService otpAuthService =
      OtpAuthService(DigitsService(), GraphQLService());

  LoginBloc() : super(LoginInitialState()) {
    on<UserLoginEvent>((event, emit) async {
      try {
        graphQLService.initClient();
        final result = await graphQLService.performMutation(
          AzanGuruQueries.loginUser,
          variables: event.mdlLoginParam.toMap(),
        );

        if (result.hasException || result.data == null) {
          throw Exception(
              result.exception?.graphqlErrors.firstOrNull?.message ??
                  'Login failed');
        }

        if (result.data!['login'] == null) {
          throw Exception('Invalid login credentials');
        }

        final userData = UserData.fromJson(result.data!['login']);

        if (userData.authToken == null) {
          throw Exception('Auth token is missing');
        }

        final userId = userData.databaseId ?? '';

        add(LoginWithJwtEvent(
          jwt: userData.authToken!,
          userId: userId.toString(),
        ));
      } catch (e) {
        emit(LoginErrorState(errorMessage: e.toString()));
      }
    });

    on<SendOtpEvent>((event, emit) async {
      emit(LoginLoadingState());
      try {
        await otpAuthService.sendOtp(event.mobile);
        emit(LoginOtpSentState());
      } catch (e) {
        emit(LoginErrorState(errorMessage: e.toString()));
      }
    });

    on<LoginWithOtpEvent>((event, emit) async {
      emit(LoginLoadingState());
      try {
        final (jwt, userId) = await otpAuthService.oneClickLoginOrRegister(
          mobile: event.mobile,
          otp: event.otp,
        );
        add(LoginWithJwtEvent(jwt: jwt, userId: userId));
      } catch (e) {
        emit(LoginErrorState(errorMessage: e.toString()));
      }
    });

    on<LoginWithJwtEvent>((event, emit) async {
      emit(LoginLoadingState());
      try {
        await StorageManager.instance.setString(
          LocalStorageKeys.prefAuthToken,
          event.jwt,
        );
        graphQLService.initClient();
        final meResult = await graphQLService.performQuery(r'''
          query {
            viewer {
              databaseId
              username
              email
            }
          }
        ''');

        if (meResult.hasException || meResult.data?['viewer'] == null) {
          throw Exception('Session validation failed');
        }

        final viewer = meResult.data!['viewer'];
        final userData = UserData(
          authToken: event.jwt,
          refreshToken: '',
          databaseId: viewer['databaseId']?.toString(),
          user: User(
            id: viewer['databaseId']?.toString(),
            databaseId: viewer['databaseId'],
            username: viewer['username'],
            email: viewer['email'],
          ),
        );

        await StorageManager.instance.setUserSession(
          userDataToJson(userData),
        );
        await StorageManager.instance.setBool(
          LocalStorageKeys.prefUserLogin,
          true,
        );
        await StorageManager.instance.remove(
          LocalStorageKeys.prefGuestLogin,
        );

        // --- DEBUG LOGGING ---
        print('🔥 Checking subscriptions for userId: ${event.userId}');
        int parsedUserId;
        try {
          parsedUserId = int.parse(event.userId);
        } catch (_) {
          print('🚨 Invalid userId format: ${event.userId}');
          parsedUserId = 0;
        }

        final subsResult = await graphQLService.performQuery(
          AzanGuruQueries.getSubscriptions,
          variables: {
            'userId': parsedUserId,
          },
        );

        print('🔥 Raw Subscription Response: ${subsResult.data}');
        if (subsResult.hasException) {
          print('🚨 GraphQL Exception: ${subsResult.exception}');
        }

        bool isSubbed = false;
        bool isPurchased = false;

        if (subsResult.data != null &&
            subsResult.data!['getSubscriptions'] != null) {
          final orders = subsResult.data!['getSubscriptions']?['orders']
                  as List<dynamic>? ??
              [];
          for (final item in orders) {
            final key = item['key']?.toString().toLowerCase();
            final value = item['value']?.toString().toLowerCase();

            print('🔍 Checking Order Item: $key = $value');

            if (key == 'subscription' && value == 'active') {
              isSubbed = true;
            }
            if (key == 'status' && value == 'completed') {
              isPurchased = true;
            }
          }
        }

        print(
            '🔥 Final Purchase Status -> isSubbed: $isSubbed, isPurchased: $isPurchased');

        await StorageManager.instance.setBool(
          LocalStorageKeys.isUserHasSubscription,
          isSubbed,
        );
        await StorageManager.instance.setBool(
          LocalStorageKeys.isCoursePurchased,
          isPurchased,
        );

        emit(LoginSuccessState(
          isPurchased: isPurchased,
          isSubscribed: isSubbed,
        ));
      } catch (e) {
        emit(LoginErrorState(errorMessage: e.toString()));
      }
    });
  }
}
