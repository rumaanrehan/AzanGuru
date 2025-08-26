import 'dart:developer';
import 'package:azan_guru_mobile/bloc/course_detail_bloc/course_detail_bloc.dart';
import 'package:azan_guru_mobile/bloc/lessons_detail_bloc/lessons_detail_bloc.dart';
import 'package:azan_guru_mobile/bloc/player_bloc/player_bloc.dart';
import 'package:azan_guru_mobile/constant/enum.dart';
import 'package:azan_guru_mobile/ui/app.dart';
import 'package:azan_guru_mobile/ui/common/ag_image_view.dart';
import 'package:azan_guru_mobile/ui/common/loader.dart';
import 'package:azan_guru_mobile/ui/help_module/ask_live_teacher_dialog.dart';
import 'package:azan_guru_mobile/ui/model/ag_course_detail.dart';
import 'package:azan_guru_mobile/ui/model/ag_lesson_detail.dart';
import 'package:azan_guru_mobile/ui/model/audio_element.dart';
import 'package:azan_guru_mobile/ui/model/key_value_model.dart';
import 'package:azan_guru_mobile/ui/model/media_node.dart';
import 'package:azan_guru_mobile/ui/model/submit_quizz_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:azan_guru_mobile/common/custom_button.dart';
import 'package:azan_guru_mobile/common/util.dart';
import 'package:azan_guru_mobile/constant/app_assets.dart';
import 'package:azan_guru_mobile/constant/app_colors.dart';
import 'package:azan_guru_mobile/constant/font_style.dart';
import 'package:azan_guru_mobile/route/app_routes.dart';
import 'package:pod_player/pod_player.dart';
import 'package:readmore/readmore.dart';

import 'package:azan_guru_mobile/ui/common/ads/ag_banner_ad.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class LessonDetailPage extends StatefulWidget {
  const LessonDetailPage({super.key});

  @override
  State<LessonDetailPage> createState() => _LessonDetailPageState();
}

class _LessonDetailPageState extends State<LessonDetailPage>
    with WidgetsBindingObserver {
  final String space = 'Space';
  String? videoUrl, title, description;
  String clickedQuizzId = '';

  AgCourseDetail? agCourseDetail;
  LessonDetail? lessonDetail;
  List<KeyValueModel>? submittedAnswersList = [];
  LessonDetailBloc bloc = LessonDetailBloc();
  int clickedIndex = -1;
  bool isVideoInitialised = false;
  bool isLessonCompleted = false;
  int? notCompletedLesson;

  PodPlayerController? controller;
  SubmitQuizInput request = SubmitQuizInput(quizzes: <Quiz>[]);

  PlayerBloc get playerBloc => globalPlayerBloc;

  @override
  initState() {
    super.initState();
    Map<String, String?> parameters = Get.parameters;
    bloc.add(GetLessonDetailEvent(lessonId: parameters['id']));
    if (Get.arguments is List) {
      var list = Get.arguments as List;
      agCourseDetail = list[0] as AgCourseDetail?;
      isLessonCompleted = list[1];
      notCompletedLesson = list[2];
      title = agCourseDetail?.name ?? '';
      description = agCourseDetail?.description ?? '';
    }
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    if (controller != null) {
      controller?.dispose();
    }
    playerBloc.add(OnResetPlayStatesEvent());
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint('State --- ${state.toString()}');
    if (state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused) {
      playerBloc.add(OnResetPlayStatesEvent());
      if (controller != null) {
        controller?.pause();
      }
    }
  }

  initialiseVideoController() {
    controller = PodPlayerController(
      playVideoFrom: PlayVideoFrom.network(videoUrl ?? ''),
      podPlayerConfig: const PodPlayerConfig(
        autoPlay: false,
        isLooping: false,
        wakelockEnabled: true,
      ),
    )
      ..initialise()
      ..addListener(() {
        playerBloc.add(OnResetPlayStatesEvent());
      });
  }

  gotoNextLesson() {
    controller?.pause();
    String lessonId =
        lessonDetail?.lessonVideo?.nextLesson?.nodes?.first.id ?? '';
    // Navigate to next lesson screen
    Get.offAndToNamed(
      Routes.lessonDetailPage,
      arguments: [agCourseDetail, false, null],
      parameters: {"id": lessonId},
    );
  }

  gotoHomeWorkScreen() {
    controller?.pause();
    Get.toNamed(
      Routes.homeWork,
      arguments: [
        lessonDetail,
        agCourseDetail,
        bloc,
        title,
        isLessonCompleted,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LessonDetailBloc, LessonDetailState>(
      bloc: bloc,
      listener: (context, state) {
        if (state is ShowLessonDetailLoadingState) {
          if (!AGLoader.isShown) {
            AGLoader.show(context);
          }
        } else if (state is HideLessonDetailLoadingState) {
          if (AGLoader.isShown) {
            AGLoader.hide();
          }
        } else if (state is GetLessonDetailState) {
          lessonDetail = state.lessonDetail;
          // videoUrl = lessonDetail?.lessonVideo?.video?.node?.mediaItemUrl ?? '';
          videoUrl = lessonDetail?.lessonVideo?.videoUrl ?? '';

          playerBloc.add(OnResetPlayStatesEvent());
          bloc.add(
            GetSubmittedQuizzAnswersByLessonIdEvent(
              lessonDbId: lessonDetail?.databaseId,
            ),
          );
          initialiseVideoController();
        } else if (state is GetSubmittedQuizzAnswersByLessonIdState) {
          submittedAnswersList?.clear();
          submittedAnswersList?.addAll(state.response?.data ?? []);
          // isLessonCompleted = submittedAnswersList?.isNotEmpty ?? false;
        } else if (state is SubmitQuizState) {
          context.read<CourseDetailBloc>().add(
                UpdateCompletedLessonEvent(lessonId: state.lessonId),
              );
          // Type 1 means - Navigate to homework screen
          bloc.add(
            SubmitLessonEvent(
              lessonDbId: state.lessonDbId,
              lessonId: state.lessonId,
              type: 1,
            ),
          );
        } else if (state is LessonsDetailErrorState) {
          Fluttertoast.showToast(msg: state.message ?? '');
        } else if (state is SubmitLessonState) {
          if (state.type == 1) {
            // Navigate to homework screen
            isLessonCompleted = true;
            gotoHomeWorkScreen();
          } else if (state.type == 2) {
            // Navigate to next lesson screen
            gotoNextLesson();
          } else if (state.type == 3) {
            controller?.pause();
            // Navigate to home screen
            Get.offAndToNamed(Routes.tabBarPage);
          }
        }
      },
      buildWhen: (previous, current) {
        if (current is UpdateRequestState) return false;
        return true;
      },
      builder: (context, state) {
        return PopScope(
          canPop: true,
          onPopInvoked: (didPop) {
            playerBloc.add(OnResetPlayStatesEvent());
            controller?.dispose();
          },
          child: Scaffold(
            backgroundColor: AppColors.bgLightWhitColor,
            body: Column(
              children: [
                _headerView(),
                controller == null && !(controller?.isInitialised ?? false)
                    ? Container(
                        color: AppColors.black,
                        width: Get.width,
                        height: 270.h,
                        child: Center(
                          child: SizedBox(
                            height: 50.w,
                            width: 50.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.w,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.buttonGreenColor,
                              ),
                              backgroundColor:
                                  AppColors.buttonGreenColor.withOpacity(0.5),
                            ),
                          ),
                        ),
                      )
                    : Container(
                        color: AppColors.black,
                        width: Get.width,
                        height: 260.h,
                        child: PodVideoPlayer(
                          key: ValueKey(videoUrl),
                          controller: controller!,
                          alwaysShowProgressBar: false,
                          podProgressBarConfig: PodProgressBarConfig(
                            padding: const EdgeInsets.only(
                              bottom: 5,
                              left: 20,
                              right: 20,
                            ),
                            playingBarColor: AppColors.buttonGreenColor,
                            circleHandlerColor: AppColors.buttonGreenColor,
                            backgroundColor:
                                AppColors.buttonGreenColor.withOpacity(0.4),
                          ),
                          onLoading: (context) {
                            return Center(
                              child: SizedBox(
                                height: 50.w,
                                width: 50.w,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.w,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.buttonGreenColor,
                                  ),
                                  backgroundColor: AppColors.buttonGreenColor
                                      .withOpacity(0.5),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _upperColumn(),
                          Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 24.h),
                              child: AGBannerAd(adSize: AdSize.mediumRectangle),
                            ),
                          ),
                          _customContainer(
                            padding: EdgeInsets.zero,
                            margin: EdgeInsets.only(
                              left: 32.w,
                              right: 32.w,
                              top: 20.h,
                            ),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(14.r),
                              topRight: Radius.circular(14.r),
                            ),
                            child: Container(
                              width: Get.width,
                              clipBehavior: Clip.hardEdge,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: Image.asset(
                                    AssetImages.icBgCourseContent,
                                  ).image,
                                ),
                              ),
                              padding: EdgeInsets.symmetric(
                                vertical: 10.h,
                                horizontal: 25.w,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Introduction Exercises',
                                    style: AppFontStyle.dmSansBold.copyWith(
                                      fontSize: 21.sp,
                                      color: AppColors.white,
                                    ),
                                  ),
                                  SizedBox(height: 3.h),
                                  Text(
                                    'After watching the video please go through the exercises below',
                                    style: AppFontStyle.dmSansRegular.copyWith(
                                      color: AppColors.courseTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          quizzListView(),
                          buttonView(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buttonView() {
    if ((lessonDetail?.lessonVideo?.homeWork == null) &&
        ((lessonDetail?.lessonVideo?.quizzes == null) ||
            (lessonDetail?.lessonVideo?.quizzes?.nodes?.isEmpty ?? false))) {
      return notCompletedLesson != null && notCompletedLesson == 0
          ? const SizedBox.shrink()
          : _customContainer(
              margin: EdgeInsets.only(
                left: 32.w,
                right: 32.w,
              ),
              padding: EdgeInsets.only(
                left: 32.w,
                right: 32.w,
                bottom: 50.h,
                top: 30.h,
              ),
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(14.r),
                bottomLeft: Radius.circular(14.r),
              ),
              child: customButton(
                onTap: () {
                  if (!isLessonCompleted) {
                    // Type 2 means - Navigate to next lesson
                    bloc.add(
                      SubmitLessonEvent(
                        lessonId: lessonDetail?.id,
                        lessonDbId: lessonDetail?.databaseId,
                        type: 2,
                      ),
                    );
                  } else {
                    gotoNextLesson();
                  }
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
            );
    } else if ((lessonDetail?.lessonVideo?.quizzes?.nodes?.isNotEmpty ??
            false) &&
        (lessonDetail?.lessonVideo?.homeWork != null)) {
      return _customContainer(
        margin: EdgeInsets.only(
          left: 32.w,
          right: 32.w,
        ),
        padding: EdgeInsets.only(
          left: 32.w,
          right: 32.w,
          top: 30.h,
          bottom: 50.h,
        ),
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(14.r),
          bottomLeft: Radius.circular(14.r),
        ),
        child: customButton(
          onTap: () {
            controller?.pause();
            if (isLessonCompleted) {
              gotoHomeWorkScreen();
            } else {
              request.lessonDbId = lessonDetail?.databaseId;
              request.lessonId = lessonDetail?.id;
              request.studentId = user?.databaseId;
              bloc.add(SubmitQuizEvent(request: request));
            }
          },
          boxColor: AppColors.buttonGreenColor,
          child: Text(
            (isLessonCompleted ? 'VIEW HOMEWORK' : 'Submit Quiz').toUpperCase(),
            textAlign: TextAlign.center,
            style: AppFontStyle.poppinsRegular.copyWith(
              color: AppColors.white,
              fontSize: 14.sp,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      );
    } else if ((lessonDetail?.lessonVideo?.homeWork != null) &&
        ((lessonDetail?.lessonVideo?.quizzes == null) ||
            (lessonDetail?.lessonVideo?.quizzes?.nodes?.isEmpty ?? false))) {
      return _customContainer(
        margin: EdgeInsets.only(
          left: 32.w,
          right: 32.w,
        ),
        padding: EdgeInsets.only(
          left: 32.w,
          right: 32.w,
          bottom: 50.h,
          top: 30.h,
        ),
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(14.r),
          bottomLeft: Radius.circular(14.r),
        ),
        child: customButton(
          onTap: () {
            controller?.pause();
            // Type 1 means - Navigate to homework screen
            if (isLessonCompleted) {
              gotoHomeWorkScreen();
            } else {
              bloc.add(
                SubmitLessonEvent(
                  lessonDbId: lessonDetail?.databaseId,
                  lessonId: lessonDetail?.id,
                  type: 1,
                ),
              );
            }
          },
          boxColor: AppColors.buttonGreenColor,
          padding: EdgeInsets.symmetric(horizontal: 25.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'View Homework'.toUpperCase(),
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
      );
    } else if ((lessonDetail?.lessonVideo?.homeWork == null) &&
        (lessonDetail?.lessonVideo?.nextLesson?.nodes?.isNotEmpty ?? false)) {
      return _customContainer(
        margin: EdgeInsets.only(
          left: 32.w,
          right: 32.w,
        ),
        padding: EdgeInsets.only(
          left: 32.w,
          right: 32.w,
          bottom: 50.h,
          top: 30.h,
        ),
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(14.r),
          bottomLeft: Radius.circular(14.r),
        ),
        child: customButton(
          onTap: () {
            if (!isLessonCompleted) {
              // Type 2 means - Navigate to next lesson
              bloc.add(
                SubmitLessonEvent(
                  lessonId: lessonDetail?.id,
                  lessonDbId: lessonDetail?.databaseId,
                  type: 2,
                ),
              );
            } else {
              gotoNextLesson();
            }
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
      );
    } else if ((lessonDetail?.lessonVideo?.homeWork == null) &&
        (lessonDetail?.lessonVideo?.nextLesson?.nodes?.isEmpty ?? false)) {
      return _customContainer(
        margin: EdgeInsets.only(
          left: 32.w,
          right: 32.w,
        ),
        padding: EdgeInsets.only(
          left: 32.w,
          right: 32.w,
          bottom: 50.h,
          top: 30.h,
        ),
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(14.r),
          bottomLeft: Radius.circular(14.r),
        ),
        child: customButton(
          onTap: () {
            if (isLessonCompleted) {
              gotoHomeWorkScreen();
            } else {
              // Type 3 means - Navigate to home screen
              bloc.add(
                SubmitLessonEvent(
                  lessonDbId: lessonDetail?.databaseId,
                  lessonId: lessonDetail?.id,
                  type: 3,
                ),
              );
            }
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
      );
    } else {
      return Container();
    }
  }

  Widget quizzListView() {
    int length = lessonDetail?.lessonVideo?.quizzes?.nodes?.length ?? 0;
    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: length,
      itemBuilder: (context, index) {
        AgQuizzes? quiz =
            lessonDetail?.lessonVideo?.quizzes?.nodes?[index].agQuizzes;
        Widget v = Column(
          children: List.generate(
            quiz?.nodes?.length ?? 0,
            (qIndex) {
              AgQuizzesNode? quizzesNode = quiz?.nodes?[qIndex];
              return Column(
                children: List.generate(
                  quizzesNode?.lessonQuiz?.createYourQuiz?.length ?? 0,
                  (cqIndex) {
                    CreateYourQuiz? createYourQuiz =
                        quizzesNode?.lessonQuiz?.createYourQuiz?[cqIndex];
                    return quizListTile(
                      qIndex,
                      quizzesNode,
                      createYourQuiz,
                    );
                  },
                ),
              );
            },
          ),
        );
        return v;
      },
    );
  }

  Widget quizListTile(
    int index,
    AgQuizzesNode? quizzesNode,
    CreateYourQuiz? createYourQuiz,
  ) {
    String? quizType = createYourQuiz?.quizType;
    if (quizType == QuizType.CorrectAlphabetsOrder.name) {
      return correctAlphabetsOrderQuizView(index, quizzesNode, createYourQuiz);
    } else if (quizType == QuizType.AudioType.name) {
      return chooseAudioQuizView(index, quizzesNode, createYourQuiz);
    } else if (quizType == QuizType.TrueFalseType.name) {
      return trueFalseQuizView(index, quizzesNode, createYourQuiz);
    } else if (quizType == QuizType.TextRadioType.name) {
      return textRadioQuizView(index, quizzesNode, createYourQuiz);
    } else if (quizType == QuizType.TextCheckboxType.name) {
      return textCheckQuizView(index, quizzesNode, createYourQuiz);
    } else {
      return Container();
    }
  }

  Widget _headerView() {
    return customAppBar(
      showPrefixIcon: true,
      showTitle: true,
      // title: title ?? "",
      titleWidget: AskLiveTeacherDialog(
        onClick: () {
          playerBloc.add(OnResetPlayStatesEvent());
          controller?.pause();
        },
        widget: Container(
          height: 40.h,
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          decoration: BoxDecoration(
            color: AppColors.buttonColor,
            borderRadius: BorderRadius.circular(50.r),
          ),
          child: Row(
            children: [
              SvgPicture.asset(AssetImages.icLiveChat),
              SizedBox(width: 10.w),
              Text(
                'Ask to Live Teacher',
                style: AppFontStyle.poppinsSemiBold.copyWith(
                  color: AppColors.white,
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
        ),
      ),
      onClick: () {
        playerBloc.add(OnResetPlayStatesEvent());
        controller?.dispose();
        Get.back();
      },
      backgroundColor: AppColors.appBgColor,
      suffixIcons: [
        Padding(
          padding: EdgeInsets.only(left: 20.w),
          child: customIcon(
            onClick: () {
              controller?.pause();
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
              controller?.pause();
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
              controller?.pause();
              Get.toNamed(Routes.notificationPage);
            },
            icon: AssetImages.icNotification,
            iconColor: AppColors.white,
          ),
        ),
      ],
    );
  }

  Widget _customContainer({
    Widget? child,
    EdgeInsetsGeometry? padding,
    BorderRadiusGeometry? borderRadius,
    EdgeInsetsGeometry? margin,
  }) {
    return Container(
      width: Get.width,
      padding: padding ??
          EdgeInsets.symmetric(
            vertical: 23.h,
            horizontal: 28.w,
          ),
      margin: margin ??
          EdgeInsets.symmetric(
            vertical: 20.h,
            horizontal: 32.w,
          ),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: borderRadius ?? BorderRadius.circular(0.r),
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

  Widget _upperColumn() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lessonDetail?.title ?? "",
            style: AppFontStyle.dmSansBold.copyWith(
              color: AppColors.cardTextColor,
              fontSize: 25.sp,
            ),
          ),
          SizedBox(height: 5.h),
          if (lessonDetail?.lessonVideo?.videoDetails?.isNotEmpty ?? false) ...[
            Padding(
              padding: EdgeInsets.only(top: 15.h, bottom: 24.h),
              child: ReadMoreText(
                lessonDetail?.lessonVideo?.videoDetails ?? "",
                trimLines: 3,
                colorClickableText: Colors.transparent,
                trimMode: TrimMode.Line,
                trimCollapsedText: 'Read more  ',
                trimExpandedText: ' Show less',
                style: AppFontStyle.dmSansMedium.copyWith(
                  fontWeight: FontWeight.w400,
                  color: AppColors.alertButtonBlackColor,
                ),
                moreStyle: AppFontStyle.dmSansMedium.copyWith(
                  fontWeight: FontWeight.w400,
                  color: AppColors.lightBlue,
                ),
                lessStyle: AppFontStyle.dmSansMedium.copyWith(
                  fontWeight: FontWeight.w400,
                  color: AppColors.lightBlue,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _titleText({String? title, String? value, Color? textColor}) {
    return Padding(
      padding: EdgeInsets.only(left: 25.w, right: 25.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            title ?? "",
            style: AppFontStyle.dmSansBold.copyWith(
              fontSize: 17.sp,
              color: textColor ?? AppColors.buttonGreenColor,
            ),
          ),
          if (value?.isNotEmpty ?? false) ...[
            SizedBox(height: 5.h),
            Text(
              value ?? "",
              style: AppFontStyle.dmSansRegular.copyWith(
                fontSize: 15.sp,
                color: AppColors.lightGrey,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget correctAlphabetsOrderQuizView(
    int index,
    AgQuizzesNode? quiz,
    CreateYourQuiz? createYourQuiz,
  ) {
    List<Option>? options = createYourQuiz?.options;
    if ((options?.isNotEmpty ?? false) &&
        !(options?.map((e) => e.value ?? '').toList().contains(space) ??
            false)) {
      options?.add(Option(value: space));
    }
    String? correctAnswer = createYourQuiz?.answer;
    return Stack(
      children: [
        BlocConsumer<LessonDetailBloc, LessonDetailState>(
          bloc: bloc,
          listener: (context, state) {},
          builder: (context, state) {
            return _customContainer(
              padding: EdgeInsets.zero,
              margin: EdgeInsets.symmetric(horizontal: 32.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  quizzQuestion(quiz?.title, quiz?.id, createYourQuiz),
                  Container(
                    margin: EdgeInsets.only(top: 10.h, bottom: 20.h),
                    child: Wrap(
                      children: List.generate(
                        options?.length ?? 0,
                        (index) {
                          Option? quizOptions = options?[index];
                          return InkWell(
                            onTap: () {
                              if (quiz?.isAnswerSubmitted ?? false) {
                                return;
                              }
                              if (quizOptions?.isSelected ?? false) {
                                return;
                              }
                              if (!(quizOptions?.value == space)) {
                                quizOptions?.isSelected = true;
                              }
                              if (quiz?.givenAnswerList?.isEmpty ?? false) {
                                quiz?.givenAnswerList = [];
                              }
                              quiz?.givenAnswerList
                                  ?.add(quizOptions?.value ?? '');
                              debugPrint(
                                  "quiz?.givenAnswerList===>>>>> ${quiz?.givenAnswerList}");
                              // if (quiz?.givenAnswerListIndex?.isEmpty ??
                              //     false) {
                              //   quiz?.givenAnswerListIndex = [];
                              // }
                              // if (quizOptions?.value == space) {
                              //   quiz?.givenAnswerListIndex?.add('-1');
                              // } else {
                              //   quiz?.givenAnswerListIndex
                              //       ?.add((index + 1).toString());
                              // }
                              // quiz?.givenAnswerListIndex
                              //     ?.add(options?[index].value??"");
                              // =
                              //     quiz?.givenAnswerListIndex?.join(',') ?? '';
                              String? givenAnswer = quiz?.givenAnswerList
                                      ?.map((e) => e == space ? ' ' : e)
                                      .join() ??
                                  '';

                              debugPrint(
                                  "givenAnswerList===>>>>> ${givenAnswer.toString()}");
                              request.quizzes?.add(
                                Quiz(
                                  quizzId: quiz?.databaseId,
                                  quizAnswers: givenAnswer,
                                ),
                              );
                              setState(() {});
                            },
                            child: Container(
                              width:
                                  (quizOptions?.value == space) ? 80.w : 50.w,
                              margin: EdgeInsets.only(left: 25.w, bottom: 15.h),
                              padding: EdgeInsets.symmetric(
                                vertical: 10.h,
                                horizontal: 10.w,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(11.r),
                                border: Border.all(
                                  color: (quizOptions?.isSelected ?? false)
                                      ? AppColors.buttonGreenColor
                                      : AppColors.audioBorderColor,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  quizOptions?.value ?? '',
                                  style: AppFontStyle.dmSansBold.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15.sp,
                                    color: AppColors.black,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  if (quiz?.givenAnswerList?.isNotEmpty ?? false) ...[
                    Container(
                      margin: EdgeInsets.only(
                        left: 25.w,
                        right: 25.w,
                        bottom: 15.h,
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: 10.h,
                        horizontal: 10.w,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(11.r),
                        border: Border.all(
                          color: AppColors.audioBorderColor,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            quiz?.givenAnswerList
                                    ?.map((e) => e == space ? ' ' : e)
                                    .join() ??
                                '',
                            textAlign: TextAlign.center,
                            textDirection: TextDirection.rtl,
                            style: AppFontStyle.dmSansBold.copyWith(
                              fontSize: 25.sp,
                              color: AppColors.alertButtonBlackColor,
                            ),
                          ),
                          if (!(quiz?.isAnswerSubmitted ?? false)) ...[
                            InkWell(
                              onTap: () {
                                debugPrint(
                                    "message>>>>>> ${quiz?.givenAnswerList}");
                                options?.forEach((element) {
                                  element.isSelected = false;
                                });
                                quiz?.givenAnswerList?.clear();
                                // quiz?.givenAnswerListIndex?.clear();
                                setState(() {});
                              },
                              child: Text(
                                'Retry',
                                textAlign: TextAlign.center,
                                style: AppFontStyle.dmSansSemiBold.copyWith(
                                  fontSize: 15.sp,
                                  color: AppColors.red,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                  if (submittedAnswersList?.isNotEmpty ?? false) ...[
                    showCorrectOrderAnswers(
                      correctAnswer,
                      quiz?.databaseId,
                      options,
                    ),
                  ],
                ],
              ),
            );
          },
        ),
        answerStatusWidget(quiz?.isAnswerSubmitted ?? false, index),
      ],
    );
  }

  Widget showCorrectOrderAnswers(
    String? correctAnswer,
    int? quizzId,
    List<Option>? options,
  ) {
    debugPrint('correctAnswer -- $correctAnswer');
    String? yourAnswer;
    // List<Option>? optionsList =
    //     options?.where((element) => element.value != space).toList();
    if (submittedAnswersList?.isNotEmpty ?? false) {
      KeyValueModel? submittedAnswers = submittedAnswersList
          ?.firstWhereOrNull((element) => element.key == quizzId?.toString());
      if (submittedAnswers != null) {
        yourAnswer = submittedAnswers.value;

        /// Old logic
        // List<int> yourAnswerIntArray = yourAnswer?.split(',').map((e) {
        //       debugPrint('splited value -- $e');
        //       return int.parse(e.trim());
        //     }).toList() ??
        //     [];
        /// New logic
        // List<String> yourAnswerStringArray = yourAnswer?.split(',').map((e) {
        //   // debugPrint('splited value -- $e');
        //   // if(e ==space){
        //   //   return ' ';
        //   // }
        //   return e.trim();
        // }).toList() ??
        //     [];
        // List<String> yourAnswerStringArray = yourAnswerStringlist.where((element) => element != space).toList();
        // List<String> yourAnswerArray = [];
        /// Old code
        // for (var i = 0; i < yourAnswerIntArray.length; i++) {
        //   if (yourAnswerIntArray[i] == -1) {
        //     debugPrint('splited value -- space');
        //     yourAnswerArray.add(' ');
        //   } else {
        //      int listIndex = yourAnswerIntArray[i] - 1;
        //     yourAnswerArray.add(optionsList?[listIndex].value ?? '');
        //   }
        // }
        /// New Code
        // for (var i = 0; i < yourAnswerStringArray.length; i++) {
        //     if (yourAnswerStringArray[i] == space) {
        //       yourAnswerArray.add(yourAnswerStringArray[i] ?? '');
        //       //   debugPrint('yourAnswerStringArray -- space');
        //     //   yourAnswerArray.add(' ');
        //     //    // i--;
        //     //
        //     } else {
        //        // int listIndex = yourAnswerStringArray[i] - 1;
        //       yourAnswerArray.add(yourAnswerStringArray[i] ?? '');
        //
        //     }
        //     // yourAnswerArray.add(optionsList?[0].value ?? '');
        // }
        // debugPrint('yourAnswerArray value -- ${yourAnswerArray.toList()}');
        // yourAnswer = yourAnswerArray.map((e) => (e == space) ? ' ' : e).join();
        // debugPrint('yourAnswer value -- $yourAnswer');
        // yourAnswer = yourAnswerArray.map((e) => e).toString();
      }
    }
    // List<int> correctAnswerIntArray = [];
    // List<String> correctAnswerStringArray = [];
    //
    // // Split by commas first
    // List<String> segments = correctAnswer?.split(',') ?? [];
    //
    // // Parse each segment and add to intList
    // for (var segment in segments) {
    //   // Split by periods within each segment
    //   List<String> subSegments = segment.split('.');
    //   for (var subSegment in subSegments) {
    //     try {
    //       // int parsedInt = int.parse(subSegment.trim());
    //       correctAnswerStringArray.add(subSegment.trim());
    //     } catch (e) {
    //       debugPrint('Error parsing "$subSegment": $e');
    //     }
    //   }
    // }
    // List<String> correctAnswerArray = [];
    // for (var i = 0; i < correctAnswerStringArray.length; i++) {
    //   // if (correctAnswerIntArray[i] == -1) {
    //   //   correctAnswerArray.add(' ');
    //   // } else {
    //   //   int listIndex = correctAnswerIntArray[i] - 1;
    //     correctAnswerArray.add(optionsList?[i].value ?? '');
    //   // }
    // }
    String rightAnswer = correctAnswer ?? '';
    debugPrint('correctAnswer -- $rightAnswer Your Answer -- $yourAnswer');
    List<Widget> widgets = [];

    if (isLessonCompleted && (yourAnswer != null)) {
      widgets.add(
        Text(
          'Correct Answer: $rightAnswer',
          textAlign: TextAlign.start,
          style: AppFontStyle.poppinsRegular.copyWith(
            color: AppColors.black,
            fontSize: 14.sp,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      );

      widgets.add(
        Text(
          'Your Answer: $yourAnswer',
          textAlign: TextAlign.center,
          style: AppFontStyle.poppinsRegular.copyWith(
            color: (rightAnswer == yourAnswer)
                ? AppColors.buttonGreenColor
                : AppColors.red,
            fontSize: 14.sp,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      );
    }
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widgets,
      ),
    );
  }

  Widget quizzQuestion(
    String? quizzTitle,
    String? quizzId,
    CreateYourQuiz? createYourQuiz,
  ) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: 15.h, bottom: 10.h, right: 10.h),
          child: Row(
            children: [
              Expanded(
                child: _titleText(
                  title: quizzTitle ?? '',
                  textColor: AppColors.black,
                ),
              ),
              if ((createYourQuiz?.quizNameAudio != null) &&
                  (createYourQuiz?.quizNameAudio?.node != null) &&
                  (createYourQuiz?.quizNameAudio?.node?.mediaItemUrl !=
                      null)) ...[
                player(
                  -1,
                  createYourQuiz?.quizNameAudio?.node?.mediaItemUrl ?? '',
                  quizzId ?? '',
                  true,
                ),
              ],
            ],
          ),
        ),
        if ((createYourQuiz != null) &&
            (createYourQuiz.quizImage != null) &&
            (createYourQuiz.quizImage?.node?.mediaItemUrl != null)) ...[
          SizedBox(height: 10.h),
          AGImageView(
            height: 200.h,
            createYourQuiz.quizImage?.node?.mediaItemUrl ?? '',
          ),
          SizedBox(height: 10.h),
        ],
      ],
    );
  }

  Widget chooseAudioQuizView(
    int index,
    AgQuizzesNode? quiz,
    CreateYourQuiz? createYourQuiz,
  ) {
    List<AudioElement>? audios = createYourQuiz?.audios;
    String? correctAnswer = createYourQuiz?.answer;
    if (correctAnswer?.length == 1) {
      correctAnswer = correctAnswer?.padLeft(2, '0');
    }
    return Stack(
      children: [
        BlocConsumer<LessonDetailBloc, LessonDetailState>(
          bloc: bloc,
          listener: (context, state) {
            if (state is UpdateRequestState) {
              request = state.request;
            }
          },
          builder: (context, state) {
            return _customContainer(
              padding: EdgeInsets.zero,
              margin: EdgeInsets.symmetric(horizontal: 32.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  quizzQuestion(quiz?.title, quiz?.id, createYourQuiz),
                  ...List.generate(
                    audios?.length ?? 0,
                    (index) {
                      MediaNode? audio = audios?[index].audio?.node;
                      return Container(
                        width: Get.width,
                        margin: EdgeInsets.only(
                          left: 25.w,
                          right: 25.w,
                          bottom: 5.h,
                          top: 5.h,
                        ),
                        padding: EdgeInsets.symmetric(
                            vertical: 10.h, horizontal: 13.w),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(11.r),
                          border: Border.all(color: AppColors.audioBorderColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                InkWell(
                                  onTap: () {
                                    if (quiz?.isAnswerSubmitted ?? false) {
                                      return;
                                    }
                                    for (int i = 0; i < (audios!.length); i++) {
                                      audios[i].audio?.node?.isSelected = false;
                                    }
                                    setState(() {
                                      audio?.isSelected = true;
                                      // String answer = audio?.mediaItemUrl ?? '';
                                      request.quizzes?.add(
                                        Quiz(
                                          quizzId: quiz?.databaseId,
                                          quizAnswers: (index + 1).toString(),
                                        ),
                                      );
                                    });
                                  },
                                  child: Container(
                                    width: 22.w,
                                    height: 22.h,
                                    margin: EdgeInsets.only(right: 10.w),
                                    decoration: BoxDecoration(
                                      color: AppColors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        width: audio?.isSelected ?? false
                                            ? 5.w
                                            : 1.w,
                                        color: AppColors.black,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: player(
                                    index,
                                    audio?.mediaItemUrl ?? '',
                                    quiz?.id ?? '',
                                    false,
                                  ),
                                ),
                              ],
                            ),
                            showAudioCorrectYourAnswers(
                              index,
                              correctAnswer,
                              quiz?.databaseId,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
        answerStatusWidget(quiz?.isAnswerSubmitted ?? false, index),
      ],
    );
  }

  Widget showAudioCorrectYourAnswers(
    int index,
    String? correctAnswer,
    int? quizzId,
  ) {
    String numberString = (index + 1).toString();
    if (numberString.length == 1) {
      numberString = numberString.padLeft(2, '0');
    }
    String? yourAnswer;
    if (submittedAnswersList?.isNotEmpty ?? false) {
      KeyValueModel? submittedAnswers = submittedAnswersList
          ?.firstWhereOrNull((element) => element.key == quizzId?.toString());
      if (submittedAnswers != null) {
        yourAnswer = submittedAnswers.value;
      }
      if (yourAnswer?.length == 1) {
        yourAnswer = yourAnswer?.padLeft(2, '0');
      }
    }
    debugPrint(
        'correctAnswer -- $correctAnswer Option Value -- $numberString Your Answer -- $yourAnswer');
    List<Widget> widgets = [];
    if (isLessonCompleted &&
        (correctAnswer == numberString) &&
        (yourAnswer == numberString) &&
        (correctAnswer == yourAnswer)) {
      widgets.add(
        Text(
          'Your Answer',
          textAlign: TextAlign.center,
          style: AppFontStyle.poppinsRegular.copyWith(
            color: AppColors.buttonGreenColor,
            fontSize: 14.sp,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      );
    } else if (yourAnswer != null) {
      if (isLessonCompleted && (correctAnswer == numberString)) {
        widgets.add(
          Text(
            'Correct Answer',
            textAlign: TextAlign.center,
            style: AppFontStyle.poppinsRegular.copyWith(
              color: AppColors.buttonGreenColor,
              fontSize: 14.sp,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        );
      }

      if (isLessonCompleted && (yourAnswer == numberString)) {
        widgets.add(
          Text(
            'Your Answer',
            textAlign: TextAlign.center,
            style: AppFontStyle.poppinsRegular.copyWith(
              color: AppColors.red,
              fontSize: 14.sp,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        );
      }
    }
    return Column(children: widgets);
  }

  Widget player(int index, String path, String quizzId, bool shortPlayer) {
    return BlocBuilder<PlayerBloc, PlayerState>(
      builder: (context, state) {
        bool isLoading = (state.loading) &&
            (clickedIndex == index) &&
            (clickedQuizzId == quizzId);
        bool isPlaying = state.isPlaying &&
            (clickedIndex == index) &&
            (clickedQuizzId == quizzId);
        return Center(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!shortPlayer) ...[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: LinearProgressIndicator(
                      borderRadius: BorderRadius.circular(10),
                      backgroundColor: Colors.grey.withOpacity(.1),
                      // color: blueBackground,
                      value:
                          (clickedIndex == index) && (clickedQuizzId == quizzId)
                              ? state.progress
                              : 0,
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
                ElevatedButton(
                  onPressed: () {
                    if (isLoading) return;
                    state.isPlaying ? _pause() : _play(path);
                    setState(() {
                      clickedIndex = index;
                      clickedQuizzId = quizzId;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(5),
                    backgroundColor: AppColors.iconButtonColor,
                    foregroundColor: AppColors.bgLightWhitColor,
                  ),
                  child: (state.loading) &&
                          (clickedIndex == index) &&
                          (clickedQuizzId == quizzId)
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
              ],
              if (shortPlayer) ...[
                InkWell(
                  onTap: () {
                    if (isLoading) return;
                    state.isPlaying ? _pause() : _play(path);
                    setState(() {
                      clickedIndex = index;
                      clickedQuizzId = quizzId;
                    });
                  },
                  child: Container(
                    height: 30.w,
                    width: 30.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.buttonColor,
                    ),
                    child: (state.loading) &&
                            (clickedIndex == index) &&
                            (clickedQuizzId == quizzId)
                        ? SizedBox(
                            height: 10.w,
                            width: 10.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.w,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.white,
                              ),
                              backgroundColor: AppColors.white.withOpacity(0.5),
                            ),
                          )
                        : Icon(
                            isPlaying
                                ? Icons.volume_off_sharp
                                : Icons.volume_up_sharp,
                            color: AppColors.white,
                            size: 20.w,
                          ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget trueFalseQuizView(
    int index,
    AgQuizzesNode? quiz,
    CreateYourQuiz? createYourQuiz,
  ) {
    List<Option>? options = createYourQuiz?.options;
    String? correctAnswer = createYourQuiz?.answer;
    if (correctAnswer?.length == 1) {
      correctAnswer = correctAnswer?.padLeft(2, '0');
    }
    return Stack(
      children: [
        _customContainer(
          padding: EdgeInsets.zero,
          margin: EdgeInsets.symmetric(horizontal: 32.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              quizzQuestion(quiz?.title, quiz?.id, createYourQuiz),
              Wrap(
                direction: Axis.horizontal,
                children: List.generate(
                  options?.length ?? 0,
                  (index) {
                    Option? option = options?[index];
                    String numberString = (index + 1).toString();
                    if (numberString.length == 1) {
                      numberString = numberString.padLeft(2, '0');
                    }
                    debugPrint(
                        'correctAnswer -- $correctAnswer Option Value -- $numberString');
                    return Container(
                      width: Get.width,
                      margin: EdgeInsets.only(
                        left: 25.w,
                        right: 25.w,
                        bottom: 5.h,
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: 10.h,
                        horizontal: 13.w,
                      ),
                      child: radioSelectionRow(
                        index: index,
                        correctAnswer: correctAnswer,
                        quizzId: quiz?.databaseId,
                        onTap: () {
                          if (quiz?.isAnswerSubmitted ?? false) return;
                          for (int i = 0; i < (options?.length ?? 0); i++) {
                            options?[i].isSelected = false;
                          }
                          setState(() {
                            option?.isSelected = true;
                            // String answer = option?.value ?? '';
                            request.quizzes?.add(
                              Quiz(
                                quizzId: quiz?.databaseId,
                                quizAnswers: (index + 1).toString(),
                              ),
                            );
                          });
                        },
                        option: option,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        answerStatusWidget(quiz?.isAnswerSubmitted ?? false, index),
      ],
    );
  }

  Widget answerStatusWidget(bool? isAnswerSubmitted, int index) {
    return Positioned(
      left: 21.w,
      top: 15.h,
      child: Container(
        width: 22.w,
        height: 22.h,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: (isAnswerSubmitted ?? false) ? AppColors.green : Colors.black,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: (isAnswerSubmitted ?? false)
              ? SvgPicture.asset(
                  AssetImages.icCorrect,
                  width: 12.w,
                  height: 12.w,
                  colorFilter: const ColorFilter.mode(
                    AppColors.white,
                    BlendMode.srcIn,
                  ),
                )
              : Text(
                  '${index + 1}',
                  style: AppFontStyle.dmSansRegular.copyWith(
                    fontSize: 15.sp,
                    color: AppColors.white,
                  ),
                ),
        ),
      ),
    );
  }

  Widget textRadioQuizView(
    int index,
    AgQuizzesNode? quiz,
    CreateYourQuiz? createYourQuiz,
  ) {
    List<Option>? options = createYourQuiz?.options;
    String? correctAnswer = createYourQuiz?.answer;
    if (correctAnswer?.length == 1) {
      correctAnswer = correctAnswer?.padLeft(2, '0');
    }
    return Stack(
      children: [
        _customContainer(
          padding: EdgeInsets.zero,
          margin: EdgeInsets.symmetric(horizontal: 32.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              quizzQuestion(quiz?.title, quiz?.id, createYourQuiz),
              ...List.generate(
                options?.length ?? 0,
                (index) {
                  Option? option = options?[index];

                  String numberString = (index + 1).toString();
                  if (numberString.length == 1) {
                    numberString = numberString.padLeft(2, '0');
                  }
                  debugPrint(
                      'correctAnswer -- $correctAnswer Option Value -- $numberString');
                  return Container(
                    width: Get.width,
                    margin: EdgeInsets.only(
                      left: 25.w,
                      right: 25.w,
                      bottom: 5.h,
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: 10.h,
                      horizontal: 13.w,
                    ),
                    child: radioSelectionRow(
                      index: index,
                      correctAnswer: correctAnswer,
                      quizzId: quiz?.databaseId,
                      onTap: () {
                        if ((quiz?.isAnswerSubmitted ?? false)) return;
                        for (int i = 0; i < (options?.length ?? 0); i++) {
                          options?[i].isSelected = false;
                        }
                        setState(() {
                          option?.isSelected = true;
                          // String answer = option?.value ?? '';
                          request.quizzes?.add(
                            Quiz(
                              quizzId: quiz?.databaseId,
                              quizAnswers: (index + 1).toString(),
                            ),
                          );
                        });
                      },
                      option: option,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        answerStatusWidget(quiz?.isAnswerSubmitted ?? false, index),
      ],
    );
  }

  Widget textCheckQuizView(
    int index,
    AgQuizzesNode? quiz,
    CreateYourQuiz? createYourQuiz,
  ) {
    List<Option>? options = createYourQuiz?.options;
    String? correctAnswer = createYourQuiz?.answer;
    if (correctAnswer?.length == 1) {
      correctAnswer = correctAnswer?.padLeft(2, '0');
    }
    false;
    return Stack(
      children: [
        _customContainer(
          padding: EdgeInsets.zero,
          margin: EdgeInsets.symmetric(horizontal: 32.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              quizzQuestion(quiz?.title, quiz?.id, createYourQuiz),
              ...List.generate(
                options?.length ?? 0,
                (index) {
                  Option? option = options?[index];

                  String numberString = (index + 1).toString();
                  if (numberString.length == 1) {
                    numberString = numberString.padLeft(2, '0');
                  }
                  debugPrint(
                      'correctAnswer -- $correctAnswer Option Value -- $numberString');
                  return Container(
                    width: Get.width,
                    margin: EdgeInsets.only(
                      left: 25.w,
                      right: 25.w,
                      bottom: 5.h,
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: 10.h,
                      horizontal: 13.w,
                    ),
                    child: radioSelectionRow(
                      index: index,
                      correctAnswer: correctAnswer,
                      quizzId: quiz?.databaseId,
                      onTap: () {
                        if ((quiz?.isAnswerSubmitted ?? false)) return;
                        setState(() {
                          option?.isSelected = !(option.isSelected ?? false);
                          if (quiz?.givenAnswerListIndex?.isEmpty ?? false) {
                            quiz?.givenAnswerListIndex = [];
                          }
                          quiz?.givenAnswerListIndex
                              ?.add((index + 1).toString());
                          String? givenAnswer =
                              quiz?.givenAnswerListIndex?.join() ?? '';
                          request.quizzes?.add(
                            Quiz(
                              quizzId: quiz?.databaseId,
                              quizAnswers: givenAnswer,
                            ),
                          );
                        });
                      },
                      option: option,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        answerStatusWidget(quiz?.isAnswerSubmitted ?? false, index),
      ],
    );
  }

  Widget radioSelectionRow({
    Function()? onTap,
    Option? option,
    required int index,
    String? correctAnswer,
    int? quizzId,
  }) {
    String numberString = (index + 1).toString();
    if (numberString.length == 1) {
      numberString = numberString.padLeft(2, '0');
    }
    String? yourAnswer;
    if (submittedAnswersList?.isNotEmpty ?? false) {
      KeyValueModel? submittedAnswers = submittedAnswersList
          ?.firstWhereOrNull((element) => element.key == quizzId?.toString());
      if (submittedAnswers != null) {
        yourAnswer = submittedAnswers.value;
      }
      if (yourAnswer?.length == 1) {
        yourAnswer = yourAnswer?.padLeft(2, '0');
      }
    }
    debugPrint(
        'correctAnswer -- $correctAnswer Option Value -- $numberString Your Answer -- $yourAnswer');
    Widget widget = Text(
      option?.value ?? "",
      style: AppFontStyle.poppinsRegular,
      textAlign: TextAlign.start,
    );
    if (isLessonCompleted &&
        (correctAnswer == numberString) &&
        (yourAnswer == numberString) &&
        (correctAnswer == yourAnswer)) {
      widget = Text(
        '${option?.value ?? ""} Your Answer',
        textAlign: TextAlign.start,
        style: AppFontStyle.poppinsRegular.copyWith(
          color: AppColors.buttonGreenColor,
          fontSize: 14.sp,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      );
    } else if (yourAnswer != null) {
      if (isLessonCompleted && (correctAnswer == numberString)) {
        widget = Text(
          '${option?.value ?? ""} Correct Answer',
          textAlign: TextAlign.start,
          style: AppFontStyle.poppinsRegular.copyWith(
            color: AppColors.buttonGreenColor,
            fontSize: 14.sp,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        );
      }

      if (isLessonCompleted && (yourAnswer == numberString)) {
        widget = Text(
          '${option?.value ?? ""} Your Answer',
          textAlign: TextAlign.start,
          style: AppFontStyle.poppinsRegular.copyWith(
            color: AppColors.red,
            fontSize: 14.sp,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        );
      }
    }
    return InkWell(
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      focusColor: Colors.transparent,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 22.w,
            height: 22.h,
            margin: EdgeInsets.only(right: 10.w),
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              border: Border.all(
                width: option?.isSelected ?? false ? 5.w : 1.w,
                color: AppColors.black,
              ),
            ),
          ),
          Expanded(child: widget),
        ],
      ),
    );
  }

  _play(String path) {
    controller?.pause();
    if (mounted) {
      playerBloc.add(OnPlayEvent(file: path));
    }
  }

  _pause() {
    globalPlayerBloc.add(PlayPauseEvent(isPlaying: false, progress: 0));
  }
}
