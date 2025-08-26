part of 'player_bloc.dart';

abstract class PlayerEvent {}

class PlayPauseEvent extends PlayerEvent {
  final bool isPlaying;
  final double progress;
  PlayPauseEvent({
    required this.isPlaying,
    this.progress = 0.0,
  });
}

class OnPlayEvent extends PlayerEvent {
  final bool isPlaying;
  final String file;

  OnPlayEvent({this.isPlaying = true, required this.file});
}

class ProgressUpdateEvent extends PlayerEvent {
  final double progress;
  final String? duration;
  ProgressUpdateEvent({
    required this.progress,
    this.duration,
  });
}

class OnResetPlayStatesEvent extends PlayerEvent {}
