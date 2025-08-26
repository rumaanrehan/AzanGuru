import 'package:azan_guru_mobile/bloc/help_desk_module/question_bloc/question_answer_bloc.dart';
import 'package:azan_guru_mobile/bloc/player_bloc/player_bloc.dart';
// import 'package:azan_guru_mobile/bloc/video_bloc/video_bloc.dart';
import 'package:azan_guru_mobile/common/util.dart';
import 'package:azan_guru_mobile/constant/app_assets.dart';
import 'package:azan_guru_mobile/constant/app_colors.dart';
import 'package:azan_guru_mobile/constant/font_style.dart';
import 'package:azan_guru_mobile/route/app_routes.dart';
import 'package:azan_guru_mobile/ui/app.dart';
import 'package:azan_guru_mobile/ui/common/ag_image_view.dart';
// import 'package:azan_guru_mobile/ui/common/ag_video_widget.dart';
import 'package:azan_guru_mobile/ui/common/loader.dart';
import 'package:azan_guru_mobile/ui/common/no_data.dart';
import 'package:azan_guru_mobile/ui/model/help_desk_detail.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class AnswerDetailPage extends StatefulWidget {
  const AnswerDetailPage({super.key});

  @override
  State<AnswerDetailPage> createState() => _AnswerDetailPageState();
}

class _AnswerDetailPageState extends State<AnswerDetailPage>
    with WidgetsBindingObserver {
  QuestionAnswerBloc bloc = QuestionAnswerBloc();
  String? questionId;
  HelpDeskDetail? helpDeskDetail;
  int clickedIndex = -1;
  List<VideoPlayerController> videoPlayerControllerList = [];
  List<ChewieController> chewieControllerList = [];

  @override
  void initState() {
    super.initState();
    if (Get.arguments is String) {
      var data = Get.arguments as String;
      questionId = data;
      bloc.add(GetAnswerDetailEvent(id: questionId));
    }
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // if (state == AppLifecycleState.hidden ||
    //     state == AppLifecycleState.paused) {
    // context.read<VideoBloc>().add(StopVideo());
    if (chewieControllerList.isNotEmpty) {
      for (var e in chewieControllerList) {
        e.videoPlayerController.pause();
      }
    }
    // if (context.read<VideoBloc>().controllers.isNotEmpty) {
    //   context.read<VideoBloc>().controllers.forEach((index, ctrl) {
    //     ctrl?.videoPlayerController.pause();
    //   });
    //   // }
    // } else {
    //   debugPrint(state.toString());
    // }
  }

  @override
  void dispose() {
    // if (context.read<VideoBloc>().controllers.isNotEmpty) {
    //   context.read<VideoBloc>().controllers.forEach((index, ctrl) {
    //     ctrl?.videoPlayerController.dispose();
    //   });
    // }
    if (chewieControllerList.isNotEmpty) {
      for (var e in chewieControllerList) {
        e.videoPlayerController.pause();
      }
    }
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<QuestionAnswerBloc, QuestionAnswerState>(
      bloc: bloc,
      listener: (context, state) {
        if (state is QuestionAnswerLoadingState) {
          AGLoader.show(context);
        } else if (state is QuestionAnswerErrorState) {
          AGLoader.hide();
        } else if (state is AnswerDetailSuccessState) {
          AGLoader.hide();
          helpDeskDetail = state.helpDeskDetail;
          Future.delayed(const Duration(milliseconds: 500)).then(
            (val) {
              if (helpDeskDetail?.helpDesk?.helpDeskVideoSection?.isNotEmpty ??
                  false) {
                videoPlayerControllerList = List.generate(
                    helpDeskDetail?.helpDesk?.helpDeskVideoSection?.length ?? 0,
                    (index) {
                  HelpDeskVideoSection? helpDeskVideoSection =
                      helpDeskDetail?.helpDesk?.helpDeskVideoSection?[index];
                  return VideoPlayerController.networkUrl(Uri.parse(
                    helpDeskVideoSection?.videoUrl ?? '',
                  ));
                }).toList();
                videoPlayerControllerList.forEach((element) async {
                  element
                    ..addListener(() {})
                    ..initialize().then((val) {
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
                    });
                });
              }
            },
          );
        }
      },
      builder: (context, state) {
        return PopScope(
          canPop: true,
          onPopInvoked: (didPop) {
            // context.read<VideoBloc>().add(StopVideo());
            if (chewieControllerList.isNotEmpty) {
              for (var e in chewieControllerList) {
                e.videoPlayerController.pause();
              }
            }
          },
          child: Scaffold(
            backgroundColor: AppColors.bgLightWhitColor,
            body: Stack(
              children: [
                customTopContainer(
                  bgImage: AssetImages.icBgMyCourse,
                  height: 180.h,
                  radius: 18.r,
                ),
                if (state is QuestionAnswerErrorState) ...[
                  const NoData(),
                ],
                if (state is QuestionAnswerLoadingState) ...[
                  const SizedBox.shrink()
                ],
                SingleChildScrollView(
                  child: Column(
                    children: [
                      _headerView(),
                      _detailTile(),
                    ],
                  ),
                ),
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
      onClick: () {
        // context.read<VideoBloc>().add(StopVideo());
        if (chewieControllerList.isNotEmpty) {
          for (var e in chewieControllerList) {
            e.videoPlayerController.pause();
          }
        }
        Get.back();
      },
      showTitle: true,
      title: 'Answer',
      suffixIcons: [
        customIcon(
          iconColor: AppColors.white,
          onClick: () {
            // context.read<VideoBloc>().add(PauseVideo());
            if (chewieControllerList.isNotEmpty) {
              for (var e in chewieControllerList) {
                e.videoPlayerController.pause();
              }
            }
            Get.toNamed(Routes.menuPage);
          },
          icon: AssetImages.icMenu,
        ),
        Padding(
          padding: EdgeInsets.only(left: 20.w, right: 20.w),
          child: customIcon(
            onClick: () {
              // context.read<VideoBloc>().add(PauseVideo());
              if (chewieControllerList.isNotEmpty) {
                for (var e in chewieControllerList) {
                  e.videoPlayerController.pause();
                }
              }
              Get.toNamed(Routes.notificationPage);
            },
            icon: AssetImages.icNotification,
            iconColor: AppColors.white,
          ),
        ),
      ],
    );
  }

  Widget _detailTile() {
    return Container(
      clipBehavior: Clip.hardEdge,
      width: Get.width,
      margin: EdgeInsets.only(bottom: 30.h, left: 32.w, right: 32.w, top: 15.h),
      padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 20.h),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        shadows: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 6.r,
            offset: const Offset(0, 9),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _titleText(title: 'QUESTION'),
          SizedBox(height: 5.w),
          Text(
            helpDeskDetail?.title ?? "",
            style: AppFontStyle.poppinsMedium.copyWith(
              fontSize: 15.sp,
              color: AppColors.appBgColor,
            ),
          ),
          _divider(),
          _titleText(title: 'ANSWER'),
          if (helpDeskDetail?.helpDesk?.helpDeskText?.isNotEmpty ?? false) ...[
            Text(
              helpDeskDetail?.helpDesk?.helpDeskText ?? '',
              style: AppFontStyle.poppinsRegular.copyWith(
                color: AppColors.appBgColor,
              ),
            ),
          ],
          if (helpDeskDetail?.helpDesk?.helpDeskImageSection != null &&
              (helpDeskDetail?.helpDesk?.helpDeskImageSection?.isNotEmpty ??
                  false)) ...[
            SizedBox(height: 10.h),
            ...List.generate(
              helpDeskDetail?.helpDesk?.helpDeskImageSection?.length ?? 0,
              (index) => AGImageView(
                height: 200.h,
                helpDeskDetail?.helpDesk?.helpDeskImageSection?[index]
                        .helpDeskImage?.node?.mediaItemUrl ??
                    '',
              ),
            ),
          ],
          if (helpDeskDetail?.helpDesk?.helpDeskVideoSection != null &&
              (helpDeskDetail?.helpDesk?.helpDeskVideoSection?.isNotEmpty ??
                  false)) ...[
            SizedBox(height: 10.h),
            chewieControllerList.isNotEmpty
                ? ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.only(top: 20.h),
                    shrinkWrap: true,
                    itemCount: chewieControllerList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return helpDeskDetail?.helpDesk
                                  ?.helpDeskVideoSection?[index].videoFile !=
                              null
                          ? Container(
                              margin: EdgeInsets.only(
                                  bottom: index <
                                          (helpDeskDetail
                                                      ?.helpDesk
                                                      ?.helpDeskVideoSection
                                                      ?.length ??
                                                  0) -
                                              1
                                      ? 20
                                      : 0),
                              color: AppColors.black,
                              width: Get.width,
                              height: 190.h,
                              child: chewieControllerList[index]
                                      .videoPlayerController
                                      .value
                                      .isInitialized
                                  ? Chewie(
                                      controller: chewieControllerList[index],
                                    )
                                  : loaderWidget(),
                            )
                          : Container();
                    },
                  )
                : loaderWidget(),
            // ...List.generate(
            //   helpDeskDetail?.helpDesk?.helpDeskVideoSection?.length ?? 0,
            //   (index) => AGVideoWidget(
            //     url: helpDeskDetail?.helpDesk?.helpDeskVideoSection?[index]
            //             .videoFile?.node?.mediaItemUrl ??
            //         '',
            //     index: index,
            //   ),
            // ),
          ],
          if (helpDeskDetail?.helpDesk?.helpDeskAudioSection != null &&
              (helpDeskDetail?.helpDesk?.helpDeskAudioSection?.isNotEmpty ??
                  false)) ...[
            SizedBox(height: 10.h),
            ...List.generate(
              helpDeskDetail?.helpDesk?.helpDeskAudioSection?.length ?? 0,
              (index) {
                HelpDeskAudioSection? helpDeskAudio =
                    helpDeskDetail?.helpDesk?.helpDeskAudioSection?[index];
                if (helpDeskAudio?.helpDeskAudio == null) {
                  return Container();
                } else {
                  return player(
                    index,
                    helpDeskAudio?.helpDeskAudio?.node?.mediaItemUrl ?? '',
                  );
                }
              },
            ),
          ],
        ],
      ),
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

  Widget player(int index, String path) {
    return BlocBuilder<PlayerBloc, PlayerState>(
      builder: (context, state) {
        bool isLoading = (state.loading) && (clickedIndex == index);
        bool isPlaying = state.isPlaying && (clickedIndex == index);
        return Center(
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
                child: isLoading
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
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: LinearProgressIndicator(
                    borderRadius: BorderRadius.circular(10),
                    backgroundColor: Colors.grey.withOpacity(.1),
                    // color: blueBackground,
                    value: (clickedIndex == index) ? state.progress : 0,
                  ),
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

  void _play(String path) {
    globalPlayerBloc.add(OnPlayEvent(file: path));
  }

  void _pause() {
    globalPlayerBloc.add(PlayPauseEvent(isPlaying: false, progress: 0));
  }

  Widget _divider() {
    return Padding(
      padding: EdgeInsets.only(top: 18.h, bottom: 13.h),
      child: Divider(height: 0, color: AppColors.questionDividerColor),
    );
  }

  Widget _titleText({required String title}) {
    return Text(
      title,
      style: AppFontStyle.poppinsMedium
          .copyWith(fontSize: 14.sp, color: AppColors.questionColor),
    );
  }
}
