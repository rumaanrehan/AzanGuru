import 'dart:developer';

import 'package:azan_guru_mobile/common/util.dart';
import 'package:azan_guru_mobile/firebase_message_sevice.dart';
import 'package:azan_guru_mobile/graphQL/graphql_service.dart';
import 'package:azan_guru_mobile/graphQL/queries.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

part 'firebase_event.dart';
part 'firebase_state.dart';

class FirebaseBloc extends Bloc<FirebaseEvent, FirebaseState> {
  final FCMService firebaseMessagingService;
  final GraphQLService graphQLService = GraphQLService();

  FirebaseBloc({required this.firebaseMessagingService})
      : super(FirebaseInitial()) {
    on<GetFirebaseToken>(_onGetFirebaseToken);
    on<UpdateDeviceToken>(_onUpdateDeviceToken);

    firebaseMessagingService.onTokenRefresh((token) {
      if (user != null) {
        add(UpdateDeviceToken(deviceToken: token));
      }
    });
  }

  _onGetFirebaseToken(GetFirebaseToken event, Emitter emit) async {
    try {
      String? token = await firebaseMessagingService.getFirebaseToken();
      if (token != null) {
        emit(FirebaseTokenLoaded(token));
        if (user != null) {
          add(UpdateDeviceToken(deviceToken: token));
        }
      } else {
        emit(FirebaseError('Failed to retrieve Firebase token'));
      }
    } catch (e) {
      emit(FirebaseError('Failed to retrieve Firebase token'));
    }
  }

  _onUpdateDeviceToken(UpdateDeviceToken event, Emitter emit) async {
    try {
      var result = await graphQLService.performQuery(
        AzanGuruQueries.updateDeviceToken,
        variables: {
          "userId": user?.databaseId,
          "deviceToken": event.deviceToken,
        },
      );

      if (result.hasException) {
        debugPrint(
            'graphQLErrors: ${result.exception?.graphqlErrors.toString()}');
      } else {
        final dataInfo = result.data?["updateUserDeviceToken"];
        debugPrint('graphResponse: $dataInfo');
        emit(DeviceTokenUpdated());
      }
    } catch (e) {
      emit(FirebaseError('Failed to update device token'));
    }
  }
}
