part of 'firebase_bloc.dart';

abstract class FirebaseState {}

class FirebaseInitial extends FirebaseState {}

class FirebaseTokenLoaded extends FirebaseState {
  final String token;

  FirebaseTokenLoaded(this.token);
}

class DeviceTokenUpdated extends FirebaseState {}

class FirebaseError extends FirebaseState {
  final String message;

  FirebaseError(this.message);
}
