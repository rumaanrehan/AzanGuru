part of 'video_bloc.dart';

abstract class VideoState {}

final class VideoInitial extends VideoState {}

class VideoLoading extends VideoState {
  final int index;

  VideoLoading(this.index);
}

class VideoLoaded extends VideoState {
  final ChewieController? controller;
  final int index;

  VideoLoaded(this.controller, this.index);
}

class VideoError extends VideoState {
  final String message;
  final int index;

  VideoError(this.message, this.index);
}
