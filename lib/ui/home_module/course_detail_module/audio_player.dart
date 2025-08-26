import 'dart:async';

import 'package:audioplayers/audioplayers.dart' as ap;
import 'package:audioplayers/audioplayers.dart';
import 'package:azan_guru_mobile/constant/app_colors.dart';
import 'package:azan_guru_mobile/constant/font_style.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AudioPlayer extends StatefulWidget {
  /// Path from where to play recorded audio
  final String source;

  /// Callback when audio file should be removed
  /// Setting this to null hides the delete button
  final VoidCallback onDelete;

  final bool? showDelete;
  final audioPlayer;
  const AudioPlayer({
    super.key,
    required this.source,
    required this.onDelete,
    required this.audioPlayer,
    this.showDelete,
  });

  @override
  AudioPlayerState createState() => AudioPlayerState();
}

class AudioPlayerState extends State<AudioPlayer> {
  static const double _controlSize = 50;
  static const double _deleteBtnSize = 24;

  // final audioPlayer = ap.AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  late StreamSubscription<void> _playerStateChangedSubscription;
  late StreamSubscription<Duration?> _durationChangedSubscription;
  late StreamSubscription<Duration> _positionChangedSubscription;
  Duration? _position;
  Duration? _duration;

  @override
  void initState() {
    _playerStateChangedSubscription =
        widget.audioPlayer.onPlayerComplete.listen((state) async {
      await stop();
    });
    _positionChangedSubscription = widget.audioPlayer.onPositionChanged.listen(
      (position) => setState(() {
        _position = position;
      }),
    );
    _durationChangedSubscription = widget.audioPlayer.onDurationChanged.listen(
      (duration) => setState(() {
        _duration = duration;
      }),
    );

    widget.audioPlayer.setSource(_source);

    super.initState();
  }

  @override
  void dispose() {
    _playerStateChangedSubscription.cancel();
    _positionChangedSubscription.cancel();
    _durationChangedSubscription.cancel();
    // widget.audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _buildControl(),
            SizedBox(width: 5.w),
            Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildSlider(constraints.maxWidth)),
                      if (widget.showDelete ?? false) ...[
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: AppColors.red,
                            size: _deleteBtnSize,
                          ),
                          onPressed: () {
                            if (widget.audioPlayer.state == ap.PlayerState.playing) {
                              stop().then((value) => widget.onDelete());
                            } else {
                              widget.onDelete();
                            }
                          },
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 5.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formatDuration(),
                        style: AppFontStyle.dmSansRegular.copyWith(
                          fontSize: 15.sp,
                          color: AppColors.lightGrey,
                        ),
                      ),
                      if ((widget.showDelete ?? false) == false) ...[
                        Text(
                          'Submitted',
                          style: AppFontStyle.dmSansRegular.copyWith(
                            fontSize: 15.sp,
                            color: AppColors.buttonGreenColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  String formatDuration() {
    final minutes = _duration?.inMinutes;
    final seconds = _duration?.inSeconds;

    final minutesstring = '$minutes'.padLeft(2, '0');
    final secondsstring = '$seconds'.padLeft(2, '0');
    return '$minutesstring:$secondsstring';
  }

  Widget _buildControl() {
    Icon icon;
    Color color;

    if (widget.audioPlayer.state == ap.PlayerState.playing) {
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

    return ClipOval(
      child: Material(
        color: color,
        child: InkWell(
          child: SizedBox(
            width: _controlSize,
            height: _controlSize,
            child: icon,
          ),
          onTap: () {
            if (widget.audioPlayer.state == ap.PlayerState.playing) {
              pause();
            } else {
              play();
            }
          },
        ),
      ),
    );
  }

  Widget _buildSlider(double widgetWidth) {
    bool canSetValue = false;
    final duration = _duration;
    final position = _position;

    if (duration != null && position != null) {
      canSetValue = position.inMilliseconds > 0;
      canSetValue &= position.inMilliseconds < duration.inMilliseconds;
    }

    double width = widgetWidth - _controlSize - _deleteBtnSize;
    width -= _deleteBtnSize;

    return SizedBox(
      width: width,
      height: 20,
      child: Slider(
        activeColor: AppColors.iconButtonColor,
        inactiveColor: AppColors.iconButtonColor.withOpacity(0.3),
        onChanged: (v) {
          if (duration != null) {
            final position = v * duration.inMilliseconds;
            widget.audioPlayer.seek(Duration(milliseconds: position.round()));
          }
        },
        value: canSetValue && duration != null && position != null
            ? position.inMilliseconds / duration.inMilliseconds
            : 0.0,
      ),
    );
  }

  Future<void> play() => widget.audioPlayer.play(_source);

  Future<void> pause() async {
    await widget.audioPlayer.pause();
    setState(() {});
  }

  Future<void> stop() async {
    await widget.audioPlayer.stop();
    setState(() {});
  }

  Source get _source =>
      kIsWeb ? ap.UrlSource(widget.source) : ap.DeviceFileSource(widget.source);
}
