// ignore_for_file: library_private_types_in_public_api

import 'package:azan_guru_mobile/bloc/video_bloc/video_bloc.dart';
import 'package:azan_guru_mobile/constant/app_colors.dart';
import 'package:azan_guru_mobile/constant/font_style.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pod_player/pod_player.dart';

class AGVideoWidget extends StatefulWidget {
  final String? url;
  final int index;
  const AGVideoWidget({
    super.key,
    required this.url,
    required this.index,
  });

  @override
  _AGVideoWidgetState createState() => _AGVideoWidgetState();
}

class _AGVideoWidgetState extends State<AGVideoWidget> {
  late VideoPlayerController _controller;
  ChewieController? _chewieController;
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url ?? ''))
      ..addListener(() {})
      ..initialize().then((value) {
        setState(() {
          _chewieController = ChewieController(
            videoPlayerController: _controller,
            autoPlay: false,
            looping: false,
            allowFullScreen: false,
            draggableProgressBar: false,
            allowMuting: false,
            allowPlaybackSpeedChanging: false,
            // additionalOptions: (context) {
            //   return <OptionItem>[];
            // },
            // optionsBuilder: (context, chewieOptions) {},
            // customControls: _buildOverlay(),
          );
          context.read<VideoBloc>().add(
                LoadVideo(
                  url: widget.url ?? '',
                  index: widget.index,
                  chewieController: _chewieController,
                ),
              );
        });
      });
  }

  @override
  void dispose() {
    context.read<VideoBloc>().add(StopVideo());
    // _controller.dispose();
    // if (_chewieController != null) {
    //   _chewieController?.videoPlayerController.dispose();
    // }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // return Container(
    //   color: AppColors.black,
    //   width: Get.width,
    //   height: 190.h,
    //   child: _chewieController != null &&
    //           _chewieController!.videoPlayerController.value.isInitialized
    //       ? Chewie(controller: _chewieController!)
    //       : loaderWidget(),
    // );
    return _chewieController != null &&
            _chewieController!.videoPlayerController.value.isInitialized
        ? Container(
            color: AppColors.black,
            width: Get.width,
            height: 190.h,
            child: BlocBuilder<VideoBloc, VideoState>(
              builder: (context, state) {
                if (state is VideoLoaded) {
                  return Chewie(controller: _chewieController!);
                  // return PodVideoPlayer(
                  //   key: Key('${DateTime.now().millisecondsSinceEpoch}'),
                  //   controller: state.controller,
                  //   alwaysShowProgressBar: false,
                  //   // overlayBuilder: (options) {
                  //   //   return _buildOverlay(context, options, widget.index);
                  //   // },
                  //   podProgressBarConfig: PodProgressBarConfig(
                  //     padding: const EdgeInsets.only(
                  //       bottom: 5,
                  //       left: 20,
                  //       right: 20,
                  //     ),
                  //     playingBarColor: AppColors.buttonGreenColor,
                  //     circleHandlerColor: AppColors.buttonGreenColor,
                  //     backgroundColor: AppColors.buttonGreenColor.withOpacity(0.4),
                  //   ),
                  //   onLoading: (context) {
                  //     return loaderWidget();
                  //   },
                  // );
                } else if (state is VideoError) {
                  return Center(
                    child: Text(
                      state.message,
                      style: AppFontStyle.poppinsMedium.copyWith(
                        fontSize: 15.sp,
                        color: AppColors.white,
                      ),
                    ),
                  );
                } else if (state is VideoInitial) {
                  return loaderWidget();
                } else if (state is VideoLoading) {
                  return loaderWidget();
                }
                return Container();
              },
            ),
          )
        : Container(
            color: AppColors.black,
            width: Get.width,
            height: 190.h,
            child: loaderWidget(),
          );
  }

  Widget loaderWidget() {
    return Center(
      child: SizedBox(
        height: 50.w,
        width: 50.w,
        child: CircularProgressIndicator(
          strokeWidth: 1.w,
          valueColor: AlwaysStoppedAnimation<Color>(
            AppColors.buttonGreenColor,
          ),
          backgroundColor: AppColors.buttonGreenColor.withOpacity(0.5),
        ),
      ),
    );
  }
}
