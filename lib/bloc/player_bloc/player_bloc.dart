import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:azan_guru_mobile/constant/extensions.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

part 'player_event.dart';
part 'player_state.dart';

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  final AudioPlayer player;
  bool isPlaying = false;
  Timer? timer;
  PlayerBloc({required this.player}) : super(PlayerState()) {
    on(_onPlayPauseEvent);
    on(_onPlayEvent);
    on(_progressUpdate);
    on(_resetStates);
  }

  Future<void> _onPlayPauseEvent(
    PlayPauseEvent event,
    Emitter<PlayerState> emit,
  ) async {
    // If you want to retrieve the current wakelock status,
    // you will have to be in an async scope
    // to await the Future returned by `enabled`.
    bool wakelockEnabled = await WakelockPlus.enabled;
    if (isPlaying) {
      await player.pause();
      if (timer != null && (timer?.isActive ?? false)) {
        timer?.cancel();
      }
      if (wakelockEnabled) {
        // The next line disables the wakelock again.
        WakelockPlus.disable();
      }
      emit(state.copyWith(isPlaying: false));
    } else {
      await player.resume();
      if (!wakelockEnabled) {
        // The following line will enable the Android and iOS wakelock.
        WakelockPlus.enable();
      }
      emit(state.copyWith(isPlaying: true));
    }
    isPlaying = event.isPlaying;
  }

  Future<void> _onPlayEvent(
    OnPlayEvent event,
    Emitter<PlayerState> emit,
  ) async {
    emit(state.copyWith(loading: true));
    // If you want to retrieve the current wakelock status,
    // you will have to be in an async scope
    // to await the Future returned by `enabled`.
    bool wakelockEnabled = await WakelockPlus.enabled;
    await player.play(UrlSource(event.file.toString()));
    isPlaying = true;
    if (!wakelockEnabled) {
      // The following line will enable the Android and iOS wakelock.
      WakelockPlus.enable();
    }
    emit(state.copyWith(isPlaying: true, loading: false, file: event.file));
    player.onPlayerComplete.listen((event) {
      if (timer != null && (timer?.isActive ?? false)) {
        timer?.cancel();
      }
      add(OnResetPlayStatesEvent());
    });

    timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) async {
        double progress = 0.0;
        Duration? duration = await player.getDuration();
        Duration? position = await player.getCurrentPosition();
        Duration remainingDuration = Duration(
          milliseconds:
              (duration?.inMilliseconds ?? 0) - (position?.inMilliseconds ?? 0),
        );
        String? remDuration = remainingDuration.toHoursMinutesSeconds();
        progress = duration == null
            ? 0.0
            : (position?.inMilliseconds ?? 0) / duration.inMilliseconds;
        add(ProgressUpdateEvent(progress: progress, duration: remDuration));
        // if (progress >= (duration?.inMilliseconds ?? 0)) {
        //   timer.cancel();
        // }
      },
    );
  }

  void _progressUpdate(ProgressUpdateEvent event, Emitter<PlayerState> emit) {
    if (event.progress == 1.0) {
      if (timer != null && (timer?.isActive ?? false)) {
        timer?.cancel();
      }
      emit(state.copyWith(progress: 0.0, isPlaying: false));
    } else {
      emit(state.copyWith(progress: event.progress, duration: event.duration));
    }
  }

  Future<void> _resetStates(
      OnResetPlayStatesEvent event, Emitter<PlayerState> emit) async {
    player.stop();
    // If you want to retrieve the current wakelock status,
    // you will have to be in an async scope
    // to await the Future returned by `enabled`.
    bool wakelockEnabled = await WakelockPlus.enabled;
    if (wakelockEnabled) {
      // The next line disables the wakelock again.
      WakelockPlus.disable();
    }
    if (timer != null && (timer?.isActive ?? false)) {
      timer?.cancel();
    }
    emit(
      state.copyWith(
        progress: 0,
        duration: null,
        isPlaying: false,
        file: null,
      ),
    );
  }
}
