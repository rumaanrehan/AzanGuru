import 'package:azan_guru_mobile/bloc/player_bloc/player_bloc.dart';
import 'package:azan_guru_mobile/constant/app_colors.dart';
import 'package:azan_guru_mobile/constant/font_style.dart';
import 'package:azan_guru_mobile/ui/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AGPlayerWidget extends StatefulWidget {
  const AGPlayerWidget({
    super.key,
    required this.path,
  });

  final String path;

  @override
  State<AGPlayerWidget> createState() => _AGPlayerWidgetState();
}

class _AGPlayerWidgetState extends State<AGPlayerWidget> {
  String extractFilename(String url) {
    List<String> segments = url.split('/');
    return segments.last;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerBloc, PlayerState>(
      builder: (context, state) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    LinearProgressIndicator(
                      borderRadius: BorderRadius.circular(10),
                      backgroundColor: Colors.grey.withOpacity(.1),
                      // color: blueBackground,
                      value: state.progress,
                    ),
                    if (state.duration?.isNotEmpty ?? false) ...[
                      Text(
                        state.duration ?? '',
                        style: AppFontStyle.dmSansRegular.copyWith(
                          color: AppColors.listBorderColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: state.isPlaying ? _pause : _play,
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(5),
                backgroundColor: AppColors.iconButtonColor,
                foregroundColor: AppColors.bgLightWhitColor,
              ),
              child: Icon(
                state.isPlaying ? Icons.pause : Icons.play_arrow,
                color: AppColors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  void _play() {
    if (widget.path.isEmpty) return;
    globalPlayerBloc.add(OnPlayEvent(file: widget.path));
  }

  void _pause() {
    globalPlayerBloc.add(PlayPauseEvent(isPlaying: false));
  }
}
