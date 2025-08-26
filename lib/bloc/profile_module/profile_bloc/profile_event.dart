part of 'profile_bloc.dart';

abstract class ProfileEvent {}

class UpdateProfileEvent extends ProfileEvent {
  String displayName;
  String lastName;
  String email;
  String gender;
  String phone;

  UpdateProfileEvent({
    required this.displayName,
    required this.email,
    required this.gender,
    required this.lastName,
    required this.phone,
  });
}

class GetProfileEvent extends ProfileEvent {}

class ResetUserPasswordEvent extends ProfileEvent {
  String username;

  ResetUserPasswordEvent({required this.username});
}

class PickImage extends ProfileEvent {
  final bool fromCamera;

  PickImage({required this.fromCamera});
}
