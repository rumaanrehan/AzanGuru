part of 'profile_bloc.dart';

abstract class ProfileState {}

class ProfileInitialState extends ProfileState {}

class ProfileLoadingState extends ProfileState {}

class ProfileErrorState extends ProfileState {
  final String? errorMessage;
  final bool? isOpenSetting;

  ProfileErrorState({
    this.errorMessage,
    this.isOpenSetting,
  });
}

class ProfileSuccessState extends ProfileState {}

class ResetPasswordSuccessState extends ProfileState {}

class GetProfileState extends ProfileState {
  final User? user;

  GetProfileState(this.user);
}

class ImagePickerLoading extends ProfileState {}

class ImagePickerLoaded extends ProfileState {
  final String imagePath;

  ImagePickerLoaded({required this.imagePath});
}
