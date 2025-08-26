part of 'delete_user_bloc.dart';


abstract class DeleteUserState {}

class DeleteUserInitialState extends DeleteUserState {}

class DeleteUserLoadingState extends DeleteUserState {}

class DeleteUserErrorState extends DeleteUserState {}

class DeleteUserSuccessState extends DeleteUserState {}
