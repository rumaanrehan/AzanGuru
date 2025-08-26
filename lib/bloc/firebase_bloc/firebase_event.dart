part of 'firebase_bloc.dart';

abstract class FirebaseEvent {}

class GetFirebaseToken extends FirebaseEvent {}

class UpdateDeviceToken extends FirebaseEvent {
  final String deviceToken;

  UpdateDeviceToken({required this.deviceToken});
}
