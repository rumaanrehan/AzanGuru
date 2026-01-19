// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:azan_guru_mobile/bloc/course_detail_bloc/course_detail_bloc.dart';
import 'package:azan_guru_mobile/bloc/lessons_detail_bloc/lessons_detail_bloc.dart';
import 'package:azan_guru_mobile/bloc/player_bloc/player_bloc.dart' as pb;
import 'package:azan_guru_mobile/ui/app.dart';
import 'package:azan_guru_mobile/ui/common/ag_image_view.dart';
import 'package:azan_guru_mobile/ui/common/audio_recorder.dart';
import 'package:azan_guru_mobile/ui/home_module/course_detail_module/audio_player.dart';
import 'package:azan_guru_mobile/ui/model/ag_course_detail.dart';
import 'package:azan_guru_mobile/ui/model/ag_lesson_detail.dart';
import 'package:azan_guru_mobile/ui/model/audio_element.dart';
import 'package:azan_guru_mobile/ui/model/image_element.dart';
import 'package:azan_guru_mobile/ui/model/video_element.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

// import 'package:path/path.dart' as p;
// import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:azan_guru_mobile/common/custom_button.dart';
import 'package:azan_guru_mobile/common/util.dart';
import 'package:azan_guru_mobile/constant/app_assets.dart';
import 'package:azan_guru_mobile/constant/app_colors.dart';
import 'package:azan_guru_mobile/constant/font_style.dart';
import 'package:azan_guru_mobile/route/app_routes.dart';
import 'package:record/record.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart' as ap;

import 'package:azan_guru_mobile/ui/common/ads/ag_banner_ad.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class HomeWorkScreen extends StatefulWidget {
  const HomeWorkScreen({
    super.key,
  });

  @override
  State<HomeWorkScreen> createState() => _HomeWorkScreenState();
}

class _HomeWorkScreenState extends State<HomeWorkScreen>
    with WidgetsBindingObserver {
  LessonDetail? lessonDetail;
  AgCourseDetail? agCourseDetail;
  LessonDetailBloc? bloc;
  String? title;
  late final AudioRecorder audioRecorder = AudioRecorder();
  final _audioPlayer = ap.AudioPlayer()..setReleaseMode(ap.ReleaseMode.stop);
  // int _recordDuration = 0;
  int clickedIndex = -1;

  // Timer? _timer;
  bool startStopRecording = false;
  File? recordedFile;

  // final AudioRecorder record = AudioRecorder();
  final PlayerController controller = PlayerController();
  bool isLessonCompleted = false;
  bool isRecordingSubmitted = false;
  List<VideoPlayerController> videoPlayerControllerList = [];
  List<ChewieController> chewieControllerList = [];

  @override
  void initState() {
    super.initState();
    // audioRecorder = AudioRecorder();
    videoPlayerControllerList.clear();
    chewieControllerList.clear();
    if (Get.arguments is List) {
      var list = Get.arguments as List;
      lessonDetail = list[0];
      agCourseDetail = list[1];
      bloc = list[2];
      title = lessonDetail?.title ?? list[3];
      isLessonCompleted = list[4];
      Future.delayed(const Duration(milliseconds: 500)).then((val) {
        if (lessonDetail?.lessonVideo?.homeWork?.nodes?.isNotEmpty ?? false) {
          List.generate(lessonDetail?.lessonVideo?.homeWork?.nodes?.length ?? 0,
              (index) {
            LessonDetail? homeWork =
                lessonDetail?.lessonVideo?.homeWork?.nodes?[index];
            List.generate(homeWork?.lessonHomeWork?.homeWorkType?.length ?? 0,
                (homeWorkIndex) {
              List<VideoElement>? videosNotNull =
                  homeWork?.lessonHomeWork?.homeWorkType?[homeWorkIndex].videos;
              if (videosNotNull?.isNotEmpty ?? false) {
                if ((videosNotNull?.length ?? 0) > 0) {
                  videoPlayerControllerList =
                      List.generate(videosNotNull?.length ?? 0, (videoIndex) {
                    return VideoPlayerController.networkUrl(
                        (videosNotNull?[videoIndex].videoUrl.isNotEmpty ??
                                false)
                            ? Uri.parse(
                                videosNotNull?[videoIndex].videoUrl ?? '')
                            : Uri.parse(
                                videosNotNull?[videoIndex]
                                        .video
                                        ?.node
                                        ?.mediaItemUrl ??
                                    '',
                              ));
                  });
                  videoPlayerControllerList.forEach((element) async {
                    element
                      ..addListener(() {
                        if (element.value.isPlaying) {
                          audioRecorder.pause();
                          _audioPlayer.pause();
                        }
                        debugPrint(
                            "message >>>>>>> audioRecorder $audioRecorder   >>>_audioPlayer>>>$_audioPlayer");
                        setState(() {});
                      })
                      ..initialize().then((val) {
                        // if (element.value.isPlaying) {
                        //   audioRecorder.pause();
                        //   _audioPlayer.pause();
                        // }
                        // audioRecorder.pause();
                        globalPlayerBloc.player.pause();
                        chewieControllerList.add(ChewieController(
                          videoPlayerController: element,
                          autoPlay: false,
                          looping: false,
                          allowFullScreen: false,
                          draggableProgressBar: false,
                          allowMuting: false,
                          allowPlaybackSpeedChanging: false,
                        ));
                        setState(() {});
                        //     List.generate(videoPlayerControllerList.length, (chewieIndex) {
                        //   return ChewieController(
                        //     videoPlayerController: videoPlayerControllerList[chewieIndex],
                        //     autoPlay: false,
                        //     looping: false,
                        //     allowFullScreen: false,
                        //     draggableProgressBar: false,
                        //     allowMuting: false,
                        //     allowPlaybackSpeedChanging: false,
                        //   );
                        // }).toList();
                      });
                  });
                }
              }
            });

            // chewieControllerList =
            //     List.generate(videoPlayerControllerList.length, (chewieIndex) {
            //   return ChewieController(
            //     videoPlayerController: videoPlayerControllerList[chewieIndex],
            //     autoPlay: false,
            //     looping: false,
            //     allowFullScreen: false,
            //     draggableProgressBar: false,
            //     allowMuting: false,
            //     allowPlaybackSpeedChanging: false,
            //   );
            // }).toList();
            // setState(() {});
          });
        } else {}
      });
      context.read<pb.PlayerBloc>().add(pb.OnResetPlayStatesEvent());
    }
    WidgetsBinding.instance.addObserver(this);
    _initializeRecorder();
  }

  Future<void> _initializeRecorder() async {
    await askRecorPermission();
  }

  askRecorPermission() async {
    var status = await Permission.microphone.status;
    if (status.isDenied || status.isRestricted || status.isPermanentlyDenied) {
      // We didn't ask for permission yet or the permission has been denied before but not permanently.
      if (await Permission.microphone.request().isGranted) {
        // Permission granted
        debugPrint('Microphone permission granted');
      } else {
        // Permission denied
        debugPrint('Microphone permission denied');
      }
    } else {
      // Permission already granted
      debugPrint('Microphone permission already granted');
    }
  }

  @override
  void dispose() {
    // context.read<VideoBloc>().add(StopVideo());
    // videoPlayerControllerList.map((e) => e.dispose());
    audioRecorder.dispose();
    _audioPlayer.dispose();
    for (var e in chewieControllerList) {
      e.videoPlayerController.dispose();
    }
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused) {
      audioRecorder.pause();
      _audioPlayer.pause();
      for (var e in chewieControllerList) {
        e.videoPlayerController.pause();
      }
    } else {
      debugPrint(state.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LessonDetailBloc, LessonDetailState>(
      bloc: bloc,
      listener: (context, state) {
        if (state is SubmitHomeworkState) {
          // String lessonId =
          //     lessonDetail?.lessonVideo?.nextLesson?.nodes?.first.id ?? '';
          // Get.offNamedUntil(
          //   Routes.lessonDetailPage,
          //   arguments: [agCourseDetail, false],
          //   parameters: {"id": lessonId},
          //   ModalRoute.withName(Routes.courseDetailPage),
          // );
          isRecordingSubmitted = true;
          Fluttertoast.showToast(
            msg: 'Homework audio submitted successfully',
            backgroundColor: Colors.black,
            textColor: Colors.white,
          );
        }
      },
      builder: (context, state) {
        return PopScope(
          canPop: true,
          onPopInvoked: (didPop) {
            audioRecorder.pause();
            _audioPlayer.pause();
            globalPlayerBloc.player.pause();
            if (chewieControllerList.isNotEmpty) {
              for (var e in chewieControllerList) {
                e.videoPlayerController.pause();
              }
            }
          },
          child: Scaffold(
            backgroundColor: AppColors.bgLightWhitColor,
            body: Column(
              children: [
                _headerView(),
                Expanded(child: homeworkView()),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _headerView() {
    return customAppBar(
      showPrefixIcon: true,
      showTitle: true,
      title: title ?? "",
      onClick: () {
        audioRecorder.pause();
        _audioPlayer.pause();
        globalPlayerBloc.add(pb.OnResetPlayStatesEvent());
        // context.read<VideoBloc>().add(StopVideo());
        // videoPlayerControllerList.map((e) => e.pause());
        for (var e in chewieControllerList) {
          e.videoPlayerController.dispose();
        }
        Get.back();
      },
      backgroundColor: AppColors.appBgColor,
      suffixIcons: [
        Padding(
          padding: EdgeInsets.only(left: 20.w),
          child: customIcon(
            onClick: () {
              audioRecorder.pause();
              _audioPlayer.pause();
              // context.read<VideoBloc>().add(PauseVideo());
              // videoPlayerControllerList.map((e) => e.pause());
              // chewieControllerList.map((e) => e.videoPlayerController.pause());
              if (chewieControllerList.isNotEmpty) {
                for (var e in chewieControllerList) {
                  e.videoPlayerController.pause();
                }
              }
              globalPlayerBloc.player.pause();
              Get.offAndToNamed(Routes.tabBarPage);
            },
            icon: AssetImages.icHome,
            iconColor: AppColors.white,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 20.w),
          child: customIcon(
            onClick: () {
              // context.read<VideoBloc>().add(PauseVideo());
              // videoPlayerControllerList.map((e) => e.pause());
              if (chewieControllerList.isNotEmpty) {
                for (var e in chewieControllerList) {
                  e.videoPlayerController.pause();
                }
              }
              _audioPlayer.pause();
              globalPlayerBloc.player.pause();
              Get.toNamed(Routes.menuPage);
            },
            icon: AssetImages.icMenu,
            iconColor: AppColors.white,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 20.w, right: 20.w),
          child: customIcon(
            onClick: () {
              // context.read<VideoBloc>().add(PauseVideo());
              // videoPlayerControllerList.map((e) => e.pause());
              // chewieControllerList.map((e) => e.videoPlayerController.pause());
              if (chewieControllerList.isNotEmpty) {
                for (var e in chewieControllerList) {
                  e.videoPlayerController.pause();
                }
              }
              _audioPlayer.pause();
              globalPlayerBloc.player.pause();
              Get.toNamed(Routes.notificationPage);
            },
            icon: AssetImages.icNotification,
            iconColor: AppColors.white,
          ),
        ),
      ],
    );
  }

  Widget homeworkView() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Container(
              width: Get.width,
              padding: EdgeInsets.symmetric(
                vertical: 10.h,
                horizontal: 25.w,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Home Work',
                    style: AppFontStyle.dmSansBold.copyWith(
                      fontSize: 21.sp,
                      color: AppColors.black,
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.h),
                      child: AGBannerAd(adSize: AdSize.banner),
                    ),
                  ),
                  SizedBox(height: 3.h),
                  if (lessonDetail?.lessonVideo?.homeWork?.nodes?.isNotEmpty ?? false)
                      ...List.generate(
                        lessonDetail?.lessonVideo?.homeWork?.nodes?.length ?? 0,
                        (index) {
                          LessonDetail? homeWork =
                              lessonDetail?.lessonVideo?.homeWork?.nodes?[index];
                          return _customContainer(
                            padding: EdgeInsets.all(20.h),
                            margin: EdgeInsets.only(bottom: 20.h),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${index + 1}. ${homeWork?.title ?? ""}',
                                  style: AppFontStyle.dmSansRegular.copyWith(
                                    fontSize: 15.sp,
                                    color: AppColors.lightGrey,
                                  ),
                                ),
                                if (homeWork?.lessonHomeWork?.homeWorkType
                                        ?.isNotEmpty ??
                                    false) ...[
                                  SizedBox(height: 10.h),
                                  ...List.generate(
                                    homeWork?.lessonHomeWork?.homeWorkType
                                            ?.length ??
                                        0,
                                    (index) {
                                      List<ImageElement>? images = homeWork
                                          ?.lessonHomeWork
                                          ?.homeWorkType?[index]
                                          .images;
                                      List<AudioElement>? audios = homeWork
                                          ?.lessonHomeWork
                                          ?.homeWorkType?[index]
                                          .audios;
                                      List<VideoElement>? videos = homeWork
                                          ?.lessonHomeWork
                                          ?.homeWorkType?[index]
                                          .videos;
                                      if (images?.isNotEmpty ?? false) {
                                        return Column(
                                          children: List.generate(
                                            images?.length ?? 0,
                                            (imageIndex) =>
                                                images?[imageIndex].image == null
                                                    ? Container()
                                                    : AGImageView(
                                                        height: 200.h,
                                                        images?[imageIndex]
                                                                .image
                                                                ?.node
                                                                ?.mediaItemUrl ??
                                                            '',
                                                      ),
                                          ),
                                        );
                                      }
                                      if (audios?.isNotEmpty ?? false) {
                                        return Column(
                                          children: List.generate(
                                            audios?.length ?? 0,
                                            (audioIndex) =>
                                                audios?[audioIndex].audio == null
                                                    ? Container()
                                                    : player(
                                                        audioIndex,
                                                        audios?[audioIndex]
                                                                .audio
                                                                ?.node
                                                                ?.mediaItemUrl ??
                                                            '',
                                                      ),
                                          ),
                                        );
                                      }
                                      if (videos?.isNotEmpty ?? false) {
                                        // return Column(
                                        //   children: List.generate(
                                        //       videos?.length ?? 0, (videoIndex) {
                                        //     return videos?[videoIndex].video == null
                                        //         ? Container()
                                        //         : Column(
                                        //             children: [
                                        //               Container(
                                        //                 color: AppColors.black,
                                        //                 width: Get.width,
                                        //                 height: 190.h,
                                        //                 child: Chewie(
                                        //                     controller:
                                        //                         chewieControllerList[
                                        //                             index]),
                                        //               ),
                                        //               // AGVideoWidget(
                                        //               //   key: Key(
                                        //               //       '${DateTime.now().millisecondsSinceEpoch}'),
                                        //               //   url: videos?[videoIndex]
                                        //               //           .video
                                        //               //           ?.node
                                        //               //           ?.mediaItemUrl ??
                                        //               //       '',
                                        //               //   index: videoIndex,
                                        //               // ),
                                        //               SizedBox(height: 20.h),
                                        //             ],
                                        //           );
                                        //   }),
                                        // );

                                        return chewieControllerList.isNotEmpty
                                            ? ListView.builder(
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                padding:
                                                    EdgeInsets.only(top: 20.h),
                                                shrinkWrap: true,
                                                itemCount:
                                                    chewieControllerList.length,
                                                itemBuilder:
                                                    (BuildContext context,
                                                        int index) {
                                                  return videos?[index].video !=
                                                          null
                                                      ? Container(
                                                          margin: EdgeInsets.only(
                                                              bottom: index <
                                                                      (videos?.length ??
                                                                              0) -
                                                                          1
                                                                  ? 20
                                                                  : 0),
                                                          color: AppColors.black,
                                                          width: Get.width,
                                                          height: 190.h,
                                                          child: chewieControllerList[
                                                                      index]
                                                                  .videoPlayerController
                                                                  .value
                                                                  .isInitialized
                                                              ? Chewie(
                                                                  controller:
                                                                      chewieControllerList[
                                                                          index],
                                                                )
                                                              : loaderWidget(),
                                                        )
                                                      : Container();
                                                },
                                              )
                                            : loaderWidget();
                                      }
                                      return Container();
                                    },
                                  ),
                                ],
                                if ((homeWork?.lessonHomeWork
                                        ?.audioRecordingFromStudent ??
                                    false)) ...[
                                  recordHomeworkAudioView(homeWork),
                                ],
                              ],
                            ),
                          );
                        },
                      ),

                    Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.h),
                        child: AGBannerAd(adSize: AdSize.mediumRectangle),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        // if (isLessonCompleted&&((notCompletedLesson??0)>0)) ...[
        if (isLessonCompleted &&
            (lessonDetail?.lessonVideo?.nextLesson?.nodes?.first.id ?? '')
                .isNotEmpty) ...[
          Padding(
            padding: EdgeInsets.all(10.h),
            child: customButton(
              onTap: () {
                // videoPlayerControllerList.map((e) => e.pause());
                if (chewieControllerList.isNotEmpty) {
                  for (var e in chewieControllerList) {
                    e.videoPlayerController.pause();
                  }
                }
                context.read<CourseDetailBloc>().add(
                      UpdateCompletedLessonEvent(lessonId: lessonDetail?.id),
                    );
                // context.read<VideoBloc>().add(PauseVideo());
                // if ((recordedFile != null) &&
                //     (recordedFile?.path ?? '') != '') {
                //   bloc?.add(
                //     SubmitHomeworkEvent(
                //       lessonId: lessonDetail?.databaseId,
                //       studentId: user?.databaseId,
                //       file: recordedFile?.path,
                //       homeworkId: lessonDetail
                //           ?.lessonVideo?.homeWork?.nodes?.first.databaseId,
                //     ),
                //   );
                // } else {
                String lessonId =
                    lessonDetail?.lessonVideo?.nextLesson?.nodes?.first.id ??
                        '';
                debugPrint("lessonId??>>>>>>>> $lessonId");
                Get.offNamedUntil(
                  Routes.lessonDetailPage,
                  arguments: [agCourseDetail, false, null],
                  parameters: {"id": lessonId},
                  ModalRoute.withName(Routes.courseDetailPage),
                );
                // }
              },
              boxColor: AppColors.buttonGreenColor,
              padding: EdgeInsets.symmetric(horizontal: 25.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'NEXT LESSON',
                    textAlign: TextAlign.center,
                    style: AppFontStyle.poppinsRegular.copyWith(
                      color: AppColors.white,
                      fontSize: 14.sp,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 10.w),
                    child: SvgPicture.asset(
                      AssetImages.icArrowForword,
                      height: 15.h,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
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

  Widget recordHomeworkAudioView(LessonDetail? homeWork) {
    return Column(
      children: [
        // Center(
        //   child: Text(
        //     formatDuration(_recordDuration),
        //     style: AppFontStyle.dmSansRegular.copyWith(
        //       color: AppColors.listBorderColor,
        //       fontSize: 40.sp,
        //     ),
        //   ),
        // ),
        if (recordedFile == null) ...[
          Recorder(
            audioRecorder: audioRecorder,
            pause: () {
              debugPrint("pause>>>>>>>>> pause");
              if (chewieControllerList.isNotEmpty) {
                for (var e in chewieControllerList) {
                  e.videoPlayerController.pause();
                }
              }
              audioRecorder.pause();
            },
            resume: () {
              debugPrint("resume>>>>>>>>> resume");
              if (chewieControllerList.isNotEmpty) {
                for (var e in chewieControllerList) {
                  e.videoPlayerController.pause();
                }
              }
              audioRecorder.resume();
            },
            onStart: () async {
              debugPrint("onStart>>>>>>>>> onStart");
              if (chewieControllerList.isNotEmpty) {
                for (var e in chewieControllerList) {
                  e.videoPlayerController.pause();
                }
              }
              globalPlayerBloc.add(pb.OnResetPlayStatesEvent());
              // context.read<pb.PlayerBloc>().add(pb.OnResetPlayStatesEvent());
            },
            onStop: (path) {
              debugPrint("onStop>>>>>>>>> onStop");
              debugPrint('Path $path');
              recordedFile = File(path);
              debugPrint('FIle length --- ${recordedFile?.lengthSync()}');
              // audioRecorder.stop();
              // globalPlayerBloc.add(pb.OnResetPlayStatesEvent());
              setState(() {});
            },
          ),
          // Padding(
          //   padding: EdgeInsets.only(
          //     bottom: 8.h,
          //   ),
          //   child: GestureDetector(
          //     onLongPress: () async {
          //       // await _videoController?.pause();
          //       startRecoding();
          //       debugPrint("object === #Start");
          //     },
          //     onLongPressUp: () {
          //       stopRecoding();
          //       debugPrint("object === #Stop");
          //     },
          //     child: customButton(
          //       boxColor: AppColors.white,
          //       showBorder: true,
          //       borderColor: AppColors.buttonGreenColor,
          //       padding: EdgeInsets.symmetric(horizontal: 25.w),
          //       child: Row(
          //         mainAxisAlignment: MainAxisAlignment.center,
          //         children: [
          //           SvgPicture.asset(
          //             AssetImages.icHold,
          //             fit: BoxFit.scaleDown,
          //           ),
          //           SizedBox(width: 12.w),
          //           Text(
          //             'Hold and Record',
          //             textAlign: TextAlign.center,
          //             style: AppFontStyle.poppinsRegular.copyWith(
          //               color: AppColors.alertButtonBlackColor,
          //               fontSize: 14.sp,
          //             ),
          //             overflow: TextOverflow.ellipsis,
          //             maxLines: 1,
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),
          Center(
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "Record your voice ",
                    style: AppFontStyle.dmSansRegular.copyWith(
                      color: AppColors.listBorderColor,
                    ),
                  ),
                  TextSpan(
                    text: "(Click Button Above)",
                    style: AppFontStyle.dmSansRegular.copyWith(
                      color: AppColors.clickTextColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        if ((recordedFile != null) && (recordedFile?.path ?? '') != '') ...[
          Container(
            width: Get.width,
            margin: EdgeInsets.only(bottom: 5.h, top: 15.h),
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(11.r),
              border: Border.all(color: AppColors.audioBorderColor),
            ),
            child: AudioPlayer(
              audioPlayer: _audioPlayer,
              source: recordedFile?.path ?? '',
              showDelete: !isRecordingSubmitted,
              onDelete: () {
                _audioPlayer.stop();
                audioRecorder.stop();
                recordedFile = null;
                globalPlayerBloc.add(pb.OnResetPlayStatesEvent());
                // audioRecorder = AudioRecorder();
                // await audioRecorder.;
                setState(() {});
              },
            ),
            // child: Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     Padding(
            //       padding: EdgeInsets.zero,
            //       child: ElevatedButton(
            //         onPressed: controller.playerState.isPlaying
            //             ? () async {
            //                 await controller.pausePlayer();
            //               }
            //             : () async {
            //                 // controller.playerState.isPlaying;
            //                 controller.stopPlayer();
            //                 await controller
            //                     .preparePlayer(
            //                   path: recordedFile?.path ?? '',
            //                   shouldExtractWaveform: true,
            //                 )
            //                     .then(
            //                   (value) {
            //                     if (mounted) {
            //                       context
            //                           .read<pb.PlayerBloc>()
            //                           .add(pb.OnResetPlayStatesEvent());
            //                     }
            //                     controller.startPlayer().then(
            //                       (value) {
            //                         debugPrint("player state ${controller.playerState}");
            //                       },
            //                     );
            //                   },
            //                 );
            //               },
            //         style: ElevatedButton.styleFrom(
            //           shape: const CircleBorder(),
            //           padding: EdgeInsets.zero,
            //           backgroundColor: AppColors.iconButtonColor,
            //           foregroundColor: AppColors.bgLightWhitColor,
            //         ),
            //         child: Icon(
            //           controller.playerState.isPlaying
            //               ? Icons.pause
            //               : Icons.play_arrow,
            //           color: AppColors.white,
            //         ),
            //       ),
            //     ),
            //     // Expanded(
            //     //   child: AudioFileWaveforms(
            //     //     size: Size(Get.width, 50.0),
            //     //     playerController: controller,
            //     //     enableSeekGesture: true,
            //     //     waveformType: WaveformType.long,
            //     //     // waveformData: [],
            //     //     playerWaveStyle: const PlayerWaveStyle(
            //     //       fixedWaveColor: Colors.black,
            //     //       liveWaveColor: Colors.blueAccent,
            //     //       // seekLineColor: Colors.red,
            //     //       spacing: 6,
            //     //     ),
            //     //   ),
            //     // ),
            //     Padding(
            //       padding: EdgeInsets.only(right: 12.w, left: 12.w),
            //       child: Text(
            //         formatDuration(_recordDuration),
            //         style: AppFontStyle.dmSansRegular.copyWith(
            //           color: AppColors.listBorderColor,
            //         ),
            //       ),
            //     ),
            //     SvgPicture.asset(AssetImages.icUnMute),
            //     if (!isRecordingSubmitted) ...[
            //       SizedBox(width: 3.w),
            //       InkWell(
            //         onTap: () {
            //           controller.stopPlayer();
            //           recordedFile = null;
            //           _recordDuration = 0;
            //           setState(() {});
            //         },
            //         child: const Icon(
            //           Icons.delete,
            //           color: Colors.red,
            //         ),
            //       ),
            //     ],
            //   ],
            // ),
          ),
        ],
        if (!isRecordingSubmitted &&
            (recordedFile != null) &&
            (recordedFile?.path ?? '') != '') ...[
          SizedBox(height: 8.h),
          customButton(
            onTap: () {
              if ((recordedFile != null) && (recordedFile?.path ?? '') != '') {
                bloc?.add(
                  SubmitHomeworkEvent(
                    lessonId: lessonDetail?.databaseId,
                    studentId: user?.databaseId,
                    file: recordedFile?.path,
                    homeworkId: homeWork?.databaseId,
                  ),
                );
              }
            },
            boxColor: AppColors.buttonGreenColor,
            showBorder: true,
            borderColor: AppColors.buttonGreenColor,
            padding: EdgeInsets.symmetric(horizontal: 25.w),
            child: Text(
              'Send',
              textAlign: TextAlign.center,
              style: AppFontStyle.poppinsRegular.copyWith(
                color: AppColors.white,
                fontSize: 16.sp,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
        SizedBox(height: 8.h),
        customButton(
          onTap: () {
            _audioPlayer.pause();
            if (chewieControllerList.isNotEmpty) {
              for (var e in chewieControllerList) {
                e.videoPlayerController.pause();
              }
            }
            globalPlayerBloc.player.pause();
            // context.read<VideoBloc>().add(PauseVideo());
            // videoPlayerControllerList.map((e) => e.pause());
            // chewieControllerList.map((e) => e.videoPlayerController.pause());
            String url =
                '${baseUrl}student-rec/?student_id=${user?.databaseId.toString()}';
            launchUrlInExternalBrowser(url);
          },
          boxColor: AppColors.buttonColor,
          showBorder: true,
          borderColor: AppColors.buttonColor,
          padding: EdgeInsets.symmetric(horizontal: 25.w),
          child: Text(
            'Prev HomeWork Teacher Replies',
            textAlign: TextAlign.center,
            style: AppFontStyle.poppinsRegular.copyWith(
              color: AppColors.white,
              fontSize: 16.sp,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        // if (lesionDetail?.lessonVideo?.nextLesson?.nodes?.isNotEmpty ??
        //     false) ...[
        //   SizedBox(height: 10.h),
        //   customButton(
        //     onTap: () {
        //       if ((recordedFile != null) && (recordedFile?.path ?? '') != '') {
        //         bloc?.add(
        //           SubmitHomeworkEvent(
        //             lesionId: lesionDetail?.databaseId,
        //             studentId: user?.databaseId,
        //             file: recordedFile?.path,
        //             homeworkId: lesionDetail
        //                 ?.lessonVideo?.homeWork?.nodes?.first.databaseId,
        //           ),
        //         );
        //       } else {
        //         String lessionId =
        //             lesionDetail?.lessonVideo?.nextLesson?.nodes?.first.id ??
        //                 '';
        //         Get.offNamedUntil(
        //           Routes.lesionDetailPage,
        //           arguments: [agCourseDetail, false],
        //           parameters: {"id": lessionId},
        //           ModalRoute.withName(Routes.courseDetailPage),
        //         );
        //       }
        //     },
        //     boxColor: AppColors.buttonGreenColor,
        //     padding: EdgeInsets.symmetric(horizontal: 25.w),
        //     child: Row(
        //       mainAxisAlignment: MainAxisAlignment.center,
        //       children: [
        //         Text(
        //           'NEXT LESSON',
        //           textAlign: TextAlign.center,
        //           style: AppFontStyle.poppinsRegular.copyWith(
        //             color: AppColors.white,
        //             fontSize: 14.sp,
        //           ),
        //           overflow: TextOverflow.ellipsis,
        //           maxLines: 1,
        //         ),
        //         Container(
        //           margin: EdgeInsets.only(left: 10.w),
        //           child: SvgPicture.asset(
        //             AssetImages.icArrowForword,
        //             height: 15.h,
        //           ),
        //         ),
        //       ],
        //     ),
        //   ),
        // ],
        if ((lessonDetail?.lessonVideo?.nextLesson?.nodes?.isEmpty ??
            false)) ...[
          SizedBox(height: 10.h),
          customButton(
            onTap: () {
              // context.read<VideoBloc>().add(PauseVideo());
              videoPlayerControllerList.map((e) => e.pause());
              chewieControllerList.map((e) => e.videoPlayerController.pause());
              Get.offAndToNamed(Routes.tabBarPage);
            },
            boxColor: AppColors.buttonGreenColor,
            padding: EdgeInsets.symmetric(horizontal: 25.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'SUBMIT',
                  textAlign: TextAlign.center,
                  style: AppFontStyle.poppinsRegular.copyWith(
                    color: AppColors.white,
                    fontSize: 14.sp,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                Container(
                  margin: EdgeInsets.only(left: 10.w),
                  child: SvgPicture.asset(
                    AssetImages.icArrowForword,
                    height: 15.h,
                  ),
                ),
              ],
            ),
          ),
        ]
      ],
    );
  }

  Widget player(int index, String path) {
    return BlocBuilder<pb.PlayerBloc, pb.PlayerState>(
      builder: (context, state) {
        bool isLoading = (state.loading) && (clickedIndex == index);
        bool isPlaying = state.isPlaying && (clickedIndex == index);
        return Container(
          width: Get.width,
          margin: EdgeInsets.only(
            bottom: 5.h,
            top: 5.h,
          ),
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(11.r),
            border: Border.all(color: AppColors.audioBorderColor),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  if (isLoading) return;
                  state.isPlaying ? _pause() : _play(path);
                  setState(() {
                    clickedIndex = index;
                  });
                },
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(5),
                  backgroundColor: AppColors.iconButtonColor,
                  foregroundColor: AppColors.bgLightWhitColor,
                ),
                child: (state.loading) && (clickedIndex == index)
                    ? SizedBox(
                        height: 30.w,
                        width: 30.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.w,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.white,
                          ),
                          backgroundColor: AppColors.white.withOpacity(0.5),
                        ),
                      )
                    : Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow,
                        color: AppColors.white,
                      ),
              ),
              Expanded(
                child: LinearProgressIndicator(
                  borderRadius: BorderRadius.circular(10),
                  backgroundColor: Colors.grey.withOpacity(.1),
                  // color: blueBackground,
                  value: (clickedIndex == index) ? state.progress : 0,
                ),
              ),
              if (isPlaying) ...[
                Text(
                  state.duration ?? '',
                  style: AppFontStyle.dmSansRegular.copyWith(
                    color: AppColors.listBorderColor,
                  ),
                ),
              ],
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.volume_up_rounded),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _play(String path) async {
    context.read<pb.PlayerBloc>().add(pb.OnPlayEvent(file: path));
  }

  void _pause() {
    context
        .read<pb.PlayerBloc>()
        .add(pb.PlayPauseEvent(isPlaying: false, progress: 0));
  }

  Widget _customContainer({
    Widget? child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    return Container(
      width: Get.width,
      padding: padding,
      margin: margin,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 6.r,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: child,
    );
  }

// String formatDuration(int totalSeconds) {
//   final duration = Duration(seconds: totalSeconds);
//   final minutes = duration.inMinutes;
//   final seconds = totalSeconds % 60;

//   final minutesstring = '$minutes'.padLeft(2, '0');
//   final secondsstring = '$seconds'.padLeft(2, '0');
//   return '$minutesstring:$secondsstring';
// }

// void _startTimer() {
//   _timer?.cancel();

//   _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
//     setState(() => _recordDuration++);
//   });
// }

// String? _filePath;
// startRecoding() async {
// if (await record.hasPermission()) {
//   final path = await _getPath();
//   await record.start(
//     const RecordConfig(encoder: AudioEncoder.aacLc),
//     path: path,
//   );
//   recordedFile = null;
//   _startTimer();
//   _recordDuration = 0;
//   startStopRecording = !startStopRecording;
//   setState(() {});
// }
//   if (mounted) {
//     context.read<pb.PlayerBloc>().add(pb.OnResetPlayStatesEvent());
//   }
// }

// stopRecoding() async {
// if (_filePath != null) {
//   await _recorder.stopRecorder();
//   startStopRecording = !startStopRecording;
//   recordedFile = File(_filePath!)..createSync(recursive: true);
//   setState(() {});
//   _timer?.cancel();
// }
// if (path != null) {
//   var file = File(path)..createSync(recursive: true);
//   recordedFile = file;
//   startStopRecording = !startStopRecording;
//   setState(() {});
//   _timer?.cancel();
// }
// }

// Future<String> _getPath() async {
//   final dir = await getApplicationDocumentsDirectory();
//   // waveFile = p.join(
//   //   dir.path,
//   //   'audio_${DateTime.now().millisecondsSinceEpoch}.wave',
//   // );
//   return p.join(
//     dir.path,
//     'audio_${DateTime.now().millisecondsSinceEpoch}.mp3',
//   );
// }
}
