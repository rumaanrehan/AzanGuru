import 'dart:async';

import 'package:azan_guru_mobile/constant/app_colors.dart';
import 'package:azan_guru_mobile/constant/font_style.dart';
import 'package:azan_guru_mobile/ui/common/audio_recorder_io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:record/record.dart';

class Recorder extends StatefulWidget {
  final void Function(String path) onStop;
  final void Function() pause;
  final void Function() resume;
  final AudioRecorder audioRecorder;

  /// Callback when audio recording starts
  final VoidCallback onStart;

  const Recorder({
    super.key,
    required this.onStop,
    required this.onStart,
    required this.pause,
    required this.resume,
    required this.audioRecorder,
  });

  @override
  State<Recorder> createState() => _RecorderState();
}

class _RecorderState extends State<Recorder> with AudioRecorderMixin {
  int _recordDuration = 0;
  final int _maxRecordingDuration = 5 * 60; // 5 minutes in seconds
  Timer? _timer;
  // late final AudioRecorder audioRecorder;
  StreamSubscription<RecordState>? _recordSub;
  RecordState _recordState = RecordState.stop;

  @override
  void initState() {
    // widget.audioRecorder = AudioRecorder();

    _recordSub = widget.audioRecorder.onStateChanged().listen((recordState) {
      _updateRecordState(recordState);
    });

    super.initState();
  }

  /// Starts the audio recording process.
  ///
  /// First, it checks if the app has permission to record audio. If it does, it
  /// proceeds to list the available input devices and checks if the
  /// encoder (in this case, WAV) is supported. If it's not supported, it
  /// returns without doing anything.
  ///
  /// If the encoder is supported, it records audio to a file using the
  /// specified configuration (encoder and number of channels). It resets the
  /// recording duration to 0 and starts a timer. Finally, it calls the
  /// `onStart` callback.
  Future<void> _start() async {
    try {
      // Check if the app has permission to record audio
      if (await widget.audioRecorder.hasPermission()) {
        // Specify the encoder and number of channels for recording
        const encoder = AudioEncoder.wav;
        const config = RecordConfig(encoder: encoder, numChannels: 1);

        // Check if the encoder is supported
        if (!await _isEncoderSupported(encoder)) {
          return;
        }

        // List the available input devices
        final devices = await widget.audioRecorder.listInputDevices();
        debugPrint(devices.toString());

        // Record audio to a file
        await recordFile(widget.audioRecorder, config);

        // Reset the recording duration to 0
        _recordDuration = 0;

        // Start a timer
        _startTimer();

        // Call the `onStart` callback
        widget.onStart();
      }
    } catch (e) {
      // Print the error (only in debug mode)
      if (kDebugMode) {
        print(e);
      }
    }
  }

  /// Stops the audio recording process.
  ///
  /// This function calls the [widget.audioRecorder.stop] method to stop the
  /// recording and retrieve the path of the recorded file. If a path is
  /// returned, it calls the [widget.onStop] callback with the path as an
  /// argument.
  Future<void> _stop() async {
    final path = await widget.audioRecorder.stop();
    if (path != null) {
      widget.onStop(path);
    }
  }

  /// Pauses the audio recording process.
  ///
  /// This function calls the [widget.pause] method to pause the recording.
  Future<void> _pause() async {
    // Call the `pause` callback
    widget.pause();
  }

  /// Resumes the audio recording process.
  ///
  /// This function calls the [widget.resume] method to resume the recording.
  Future<void> _resume() async {
    // Call the `resume` callback
    widget.resume();
  }
  // Future<void> _pause() => widget.audioRecorder.pause();
  // Future<void> _resume() => widget.audioRecorder.resume();

  /// Updates the state of the recording based on the given [recordState].
  ///
  /// This function updates the `_recordState` variable with the provided
  /// [recordState]. It also updates the `_recordDuration` variable to 0 if
  /// the [recordState] is [RecordState.stop]. Additionally, it starts or
  /// cancels a timer based on the [recordState].
  ///
  /// Parameters:
  /// - [recordState]: The current state of the recording. This can be one of
  ///   the following values:
  ///   - [RecordState.pause]: The recording has been paused.
  ///   - [RecordState.record]: The recording is currently in progress.
  ///   - [RecordState.stop]: The recording has been stopped.
  void _updateRecordState(RecordState recordState) {
    setState(() => _recordState = recordState);

    switch (recordState) {
      case RecordState.pause:
        _timer?.cancel();
        break;
      case RecordState.record:
        _startTimer();
        break;
      case RecordState.stop:
        _timer?.cancel();
        _recordDuration = 0;
        break;
    }
  }

  /// Checks if the given [encoder] is supported on the current platform.
  ///
  /// This function calls the [widget.audioRecorder.isEncoderSupported] method
  /// to check if the [encoder] is supported. If it's not supported, it prints
  /// a debug message and a list of supported encoders.
  ///
  /// Parameters:
  /// - [encoder]: The [AudioEncoder] to check for support.
  ///
  /// Returns:
  /// A [Future] that resolves to a [bool] indicating whether the [encoder] is
  /// supported.
  Future<bool> _isEncoderSupported(AudioEncoder encoder) async {
    // Check if the encoder is supported
    final isSupported = await widget.audioRecorder.isEncoderSupported(
      encoder,
    );

    // If the encoder is not supported, print a debug message and list of supported encoders
    if (!isSupported) {
      debugPrint('${encoder.name} is not supported on this platform.');
      debugPrint('Supported encoders are:');

      // Iterate over all encoders and print the name of the supported ones
      for (final e in AudioEncoder.values) {
        if (await widget.audioRecorder.isEncoderSupported(e)) {
          debugPrint('- ${encoder.name}');
        }
      }
    }

    // Return whether the encoder is supported
    return isSupported;
  }

  @override

  /// Builds the widget tree for this state.
  ///
  /// The widget tree consists of a [Row] widget that centers its children
  /// horizontally. The children are the result of calling the following
  /// helper methods: [_buildRecordStopControl], [_buildPauseResumeControl], and
  /// [_buildText].
  ///
  /// Returns:
  /// A [Widget] that represents the widget tree for this state.
  Widget build(BuildContext context) {
    // Build the widget tree for this state
    return Row(
      // Center the children horizontally
      mainAxisAlignment: MainAxisAlignment.center,
      // Add the children of the Row
      children: <Widget>[
        // Build the record/stop control widget
        _buildRecordStopControl(),
        // Build the pause/resume control widget
        _buildPauseResumeControl(),
        // Build the text widget
        _buildText(),
      ],
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _recordSub?.cancel();
    // _amplitudeSub?.cancel();
    // widget.audioRecorder.stop();
    super.dispose();
  }

  Widget _buildRecordStopControl() {
    late Icon icon;
    late Color color;

    if (_recordState != RecordState.stop) {
      icon = const Icon(Icons.stop, color: AppColors.red, size: 30);
      color = AppColors.red.withOpacity(0.1);
    } else {
      icon = const Icon(
        Icons.mic,
        color: AppColors.white,
        size: 30,
      );
      color = AppColors.iconButtonColor.withOpacity(0.8);
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClipOval(
        child: Material(
          color: color,
          child: InkWell(
            child: SizedBox(width: 50, height: 50, child: icon),
            onTap: () {
              (_recordState != RecordState.stop) ? _stop() : _start();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPauseResumeControl() {
    if (_recordState == RecordState.stop) {
      return const SizedBox.shrink();
    }

    late Icon icon;
    late Color color;

    if (_recordState == RecordState.record) {
      icon = const Icon(
        Icons.pause,
        color: AppColors.white,
        size: 30,
      );
    } else {
      icon = const Icon(
        Icons.play_arrow,
        color: AppColors.white,
        size: 30,
      );
    }
    color = AppColors.iconButtonColor.withOpacity(0.8);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClipOval(
        child: Material(
          color: color,
          child: InkWell(
            child: SizedBox(width: 50, height: 50, child: icon),
            onTap: () {
              (_recordState == RecordState.pause) ? _resume() : _pause();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildText() {
    if (_recordState != RecordState.stop) {
      return _buildTimer();
    }

    return Container();
  }

  Widget _buildTimer() {
    final String minutes = _formatNumber(_recordDuration ~/ 60);
    final String seconds = _formatNumber(_recordDuration % 60);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        '$minutes : $seconds',
        style: AppFontStyle.dmSansRegular.copyWith(
          color: AppColors.listBorderColor,
          fontSize: 20.sp,
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    String numberStr = number.toString();
    if (number < 10) {
      numberStr = '0$numberStr';
    }

    return numberStr;
  }

  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() {
        _recordDuration++;
        if (_maxRecordingDuration == _recordDuration) {
          _stop();
          Fluttertoast.showToast(
              msg: 'Recording stopped: Max duration reached');
        }
      });
    });
  }
}
