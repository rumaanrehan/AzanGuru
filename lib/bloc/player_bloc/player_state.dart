part of 'player_bloc.dart';

class PlayerState {
  final bool isPlaying;
  final double progress;
  final String? file;
  final String? duration;
  final bool loading;

  PlayerState({
    this.isPlaying = false,
    this.progress = 0.0,
    this.file,
    this.duration,
    this.loading = false,
  });

  PlayerState copyWith({
    bool? isPlaying,
    double? progress,
    String? file,
    String? duration,
    bool? loading,
  }) {
    return PlayerState(
      isPlaying: isPlaying ?? this.isPlaying,
      progress: progress ?? this.progress,
      file: file ?? this.file,
      duration: duration ?? this.duration,
      loading: loading ?? this.loading,
    );
  }
}
