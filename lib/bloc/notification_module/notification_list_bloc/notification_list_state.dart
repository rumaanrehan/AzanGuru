part of 'notification_list_bloc.dart';

abstract class NotificationListState {}

class NotificationListInitialState extends NotificationListState {}

class NotificationListLoadingState extends NotificationListState {}

class NotificationListErrorState extends NotificationListState {
  String? errorMessage;

  NotificationListErrorState({this.errorMessage});
}

class NotificationListSuccessState extends NotificationListState {
  AgNotificationsList? notificationsList;

  NotificationListSuccessState({this.notificationsList});
}
