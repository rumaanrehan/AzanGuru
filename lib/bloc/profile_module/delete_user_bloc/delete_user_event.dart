part of 'delete_user_bloc.dart';

abstract class DeleteUserEvent {}

class UserAccountDeleteEvent extends DeleteUserEvent {
  String? id;

  UserAccountDeleteEvent({this.id});
}
