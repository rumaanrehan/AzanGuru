part of 'video_bloc.dart';

abstract class VideoEvent {}

class LoadVideo extends VideoEvent {
  final String url;
  final int index;
  final ChewieController? chewieController;

  LoadVideo({
    required this.url,
    required this.index,
    required this.chewieController,
  });
}

class PauseVideo extends VideoEvent {
  PauseVideo();
}

class StopVideo extends VideoEvent {
  StopVideo();
}
