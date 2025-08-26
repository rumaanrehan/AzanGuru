import 'dart:developer';
import 'package:azan_guru_mobile/graphQL/graphql_service.dart';
import 'package:azan_guru_mobile/graphQL/queries.dart';
import 'package:azan_guru_mobile/ui/model/mdl_notification_list.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

part 'notification_list_event.dart';

part 'notification_list_state.dart';

class NotificationListBloc
    extends Bloc<NotificationListEvent, NotificationListState> {
  final graphQLService = GraphQLService();

  NotificationListBloc() : super(NotificationListInitialState()) {
    on<GetNotificationListEvent>(_getNotificationListEvent);
  }

  _getNotificationListEvent(
      GetNotificationListEvent event, Emitter emit) async {
    emit(NotificationListLoadingState());
    final result = await graphQLService.performQuery(
      AzanGuruQueries.agNotificationsList,
    );
    if (result.hasException) {
      debugPrint(
          'graphQLErrors: ${result.exception?.graphqlErrors.toString()}');
      emit(NotificationListErrorState(
          errorMessage: result.exception?.graphqlErrors.toString()));
    } else {
      final dataInfo = result.data;
      debugPrint("dataInfo ===== $dataInfo");
      AgNotificationsList? notificationsList;
      if (dataInfo != null) {
        notificationsList =
            AgNotificationsList.fromJson(dataInfo['agNotifications']);
        emit(
            NotificationListSuccessState(notificationsList: notificationsList));
      } else {
        emit(NotificationListSuccessState());
      }
    }
  }
}
