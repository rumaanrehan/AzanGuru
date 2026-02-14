import 'dart:io';

import 'package:azan_guru_mobile/bloc/course_detail_bloc/course_detail_bloc.dart';
import 'package:azan_guru_mobile/bloc/my_course_bloc/my_course_bloc.dart';
import 'package:azan_guru_mobile/common/custom_button.dart';
import 'package:azan_guru_mobile/common/util.dart';
import 'package:azan_guru_mobile/constant/app_assets.dart';
import 'package:azan_guru_mobile/constant/app_colors.dart';
import 'package:azan_guru_mobile/constant/font_style.dart';
import 'package:azan_guru_mobile/route/app_routes.dart';
import 'package:azan_guru_mobile/ui/common/ag_image_view.dart';
import 'package:azan_guru_mobile/ui/common/secondary_ag_header_bar.dart';
import 'package:azan_guru_mobile/ui/common/loader.dart';
import 'package:azan_guru_mobile/ui/help_module/ask_live_teacher_dialog.dart';
import 'package:azan_guru_mobile/ui/model/ag_course_detail.dart';
import 'package:azan_guru_mobile/ui/model/ag_lesson_list.dart';
import 'package:azan_guru_mobile/ui/model/course_amount_response_model.dart';
import 'package:azan_guru_mobile/service/local_storage/local_storage_keys.dart';
import 'package:azan_guru_mobile/service/local_storage/storage_manager.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:pod_player/pod_player.dart';
import 'package:readmore/readmore.dart';

import 'package:azan_guru_mobile/ui/common/ads/ag_banner_ad.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class CourseDetailPage extends StatefulWidget {
  const CourseDetailPage({super.key});

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage>
    with WidgetsBindingObserver {
  AgCourseDetail? courseData;
  AgCourseLessonList? agCourseLessonList;
  CourseAmountResponseModel? courseAmountResponseModel;

  bool get isMonthlyCourse {
    final name = courseData?.name?.toLowerCase() ?? '';
    return name.contains('primary') ||
        name.contains('race') ||
        name.contains('advanced');
  }

  CourseDetailBloc get bloc => context.read<CourseDetailBloc>();
  String? courseId;
  int? databaseId;
  double studentProgress = 0;

  // List<LessonNodes>? studentCompletedLessons;
  // int initialExpandedIndex = -1;
  Lesson? currentSelectedLesson;
  VideoPlayerController? _controller;
  ChewieController? _chewieController;
  int notCompletedLesson = 0;

  bool get isUserLoggedIn => user != null;
  bool isCoursePurchased = false;
  final ScrollController _scrollController = ScrollController();

  String get token =>
      StorageManager.instance.getString(LocalStorageKeys.prefAuthToken);

  Future<void> launchUrlInBrowser(String url) async {
    launchUrlInExternalBrowser(url);
  }

  @override
  void initState() {
    super.initState();
    if (Get.arguments is String) {
      courseId = Get.arguments as String;
    } else if (Get.arguments is List) {
      var list = Get.arguments as List;
      courseId = list[0].toString();
      // Optional: keep these for immediate UI update, but bloc will override if needed
      studentProgress = list[1].toDouble();
      isCoursePurchased = list[3];
    }

    if (courseId != null) {
      bloc.add(GetCourseDetailEvent(courseId: courseId));
    }

    // Trigger refresh of course list if logged in to ensure status is up to date
    if (isUserLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<MyCourseBloc>().add(GetMyCourseEvent());
      });
    }

    WidgetsBinding.instance.addObserver(this);
  }

  void _checkPurchaseStatus(MyCourseState state) {
    if (state is GetMyCourseState && state.nodes != null) {
      bool found = false;
      double progress = 0;
      for (var courseList in state.nodes!) {
        if (courseList.mdlCourse != null) {
          for (var course in courseList.mdlCourse!) {
            if (course.id == courseId) {
              found = true;
              progress = courseList.studentProgress ?? 0;
              break;
            }
          }
        }
        if (found) break;
      }

      if (isCoursePurchased != found || studentProgress != progress) {
        setState(() {
          isCoursePurchased = found;
          studentProgress = progress;
        });

        // If status changed to purchased, ensure lessons are updated
        if (isCoursePurchased && agCourseLessonList != null) {
          updateCurrentSelectedLesson();
        }
      }
    }
  }

  @override
  void dispose() {
    // context.read<VideoBloc>().add(StopVideo());
    _controller?.dispose();
    if (_chewieController != null) {
      _chewieController?.videoPlayerController.dispose();
      // _chewieController?.dispose();
    }
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused) {
      if (_chewieController != null) {
        _chewieController?.videoPlayerController.pause();
      }
    } else {
      debugPrint(state.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<MyCourseBloc, MyCourseState>(
          listener: (context, state) {
            _checkPurchaseStatus(state);
          },
        ),
      ],
      child: BlocConsumer<CourseDetailBloc, CourseDetailState>(
        listener: (context, state) {
          if (state is ShowCourseDetailLoadingState) {
            if (!AGLoader.isShown) {
              AGLoader.show(context);
            }
          } else if (state is HideCourseDetailLoadingState) {
            if (AGLoader.isShown) {
              AGLoader.hide();
            }
          } else if (state is GetCourseDetailState) {
            courseData = state.agCourseDetail;
            databaseId = courseData?.databaseId;

            // studentCompletedLessons =
            //     courseData?.courseTypeImage?.completedLessons?.nodes ?? [];
            bloc.add(GetCourseAmountEvent(courseId: courseId));
            bloc.add(GetCourseLessonsEvent(courseId: courseId));
            _controller = VideoPlayerController.networkUrl(
              Uri.parse(courseData?.courseTypeImage?.videoUrl ?? ''),
            )
              ..addListener(() {})
              ..initialize().then((value) {
                setState(() {
                  _chewieController = ChewieController(
                    videoPlayerController: _controller!,
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
                });
              });
          } else if (state is GetCourseAmountState) {
            courseAmountResponseModel = state.courseAmountResponseModel;
          } else if (state is UpdateCompletedLessonState) {
            Lesson? lesson = agCourseLessonList?.agCourses?.nodes
                ?.firstWhereOrNull((element) => element.id == state.lessonId);
            if (lesson != null) {
              lesson.completed = true;
            }
            // studentCompletedLessons?.add(LessonNodes(id: state.lessonId));
            // context.read<MyCourseBloc>().add(
            //       UpdateMyCourseCompletedEvent(
            //         courseId: courseId,
            //         lessonId: state.lessonId,
            //       ),
            //     );
            updateCurrentSelectedLesson();
          } else if (state is GetCourseLessonsState) {
            agCourseLessonList = state.agCourseLessonList;
            if (isCoursePurchased) {
              updateCurrentSelectedLesson();
              _scrollController.animateTo(
                MediaQuery.of(context).size.height / 1.7,
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeIn,
              );
            }
            if (agCourseLessonList?.agCourses?.nodes?.isNotEmpty ?? false) {
              agCourseLessonList?.agCourses?.nodes?.forEach(
                (element) {
                  if (element.completed.toString() == "false") {
                    // notCompleteLesson?.add(element);
                    notCompletedLesson = notCompletedLesson + 1;
                  }
                },
              );
              debugPrint("message?>>>>>>>> $notCompletedLesson");
            }
          }
        },
        builder: (context, state) {
          return PopScope(
            canPop: true,
            onPopInvoked: (didPop) {
              // context.read<VideoBloc>().add(StopVideo());
              _controller?.pause();
              if (_chewieController != null) {
                _chewieController?.pause();
              }
            },
            child: Scaffold(
              backgroundColor: AppColors.bgLightWhitColor,
              bottomNavigationBar: SafeArea(
                bottom: true,
                child: Padding(
                  padding:
                      EdgeInsets.only(left: 20.w, right: 20.w, bottom: 20.h),
                  child: isCoursePurchased
                      ? customButton(
                          onTap: ((agCourseLessonList?.agCourses?.nodes ?? [])
                                      .isNotEmpty &&
                                  currentSelectedLesson != null)
                              ? () {
                                  // context.read<VideoBloc>().add(PauseVideo());
                                  _controller?.pause();
                                  if (_chewieController != null) {
                                    _chewieController?.pause();
                                  }
                                  List<Lesson>? lessonList =
                                      agCourseLessonList?.agCourses?.nodes ??
                                          [];
                                  if (lessonList.isNotEmpty &&
                                      currentSelectedLesson != null) {
                                    Lesson? lesson = currentSelectedLesson;
                                    Get.toNamed(
                                      Routes.lessonDetailPage,
                                      arguments: [
                                        courseData,
                                        lesson?.completed ?? false,
                                        notCompletedLesson
                                      ],
                                      parameters: {
                                        "id": lesson?.id ?? '',
                                      },
                                    );
                                  }
                                }
                              : notCompletedLesson == 0 &&
                                      (agCourseLessonList?.agCourses?.nodes ??
                                              [])
                                          .isNotEmpty
                                  ? () {
                                      Get.toNamed(
                                          Routes.courseCompleteSuccessPage);
                                    }
                                  : null,
                          boxColor: AppColors.headerColor,
                          child: Text(
                            notCompletedLesson == 0 && isCoursePurchased
                                ? "Certificate"
                                : 'Start Lesson',
                            textAlign: TextAlign.center,
                            style: AppFontStyle.dmSansBold.copyWith(
                              color: AppColors.white,
                              fontSize: 17.sp,
                            ),
                          ),
                        )
                      : null,
                ),
              ),
              body: Column(
                children: [
                  SecondaryAgHeaderBar(
                    pageTitle: courseData?.name ?? '',
                    showBackButton: true,
                    showHomeButton: true,
                    showMenuButton: false,
                    backgroundColor: AppColors.headerColor,
                    onBackPressed: () {
                      if (_controller != null) {
                        _controller?.dispose();
                      }
                      if (_chewieController != null) {
                        _chewieController?.dispose();
                      }
                      Get.back();
                    },
                  ),
                  courseData == null
                      ? Container()
                      : Expanded(child: bodyView()),
                ],
              ),
            ),
          );
        },
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

  updateCurrentSelectedLesson() {
    try {
      List<Lesson>? completedLessonList = agCourseLessonList?.agCourses?.nodes
              ?.where((element) => element.completed ?? false)
              .toList() ??
          [];

      if (completedLessonList.isNotEmpty) {
        Lesson? lastCompletedLesson = completedLessonList.last;
        String? nextLessonId =
            lastCompletedLesson.lessonVideo?.nextLesson?.edges?.first.node?.id;
        currentSelectedLesson = agCourseLessonList?.agCourses?.nodes
            ?.firstWhereOrNull((element) => element.id == nextLessonId);
      } else {
        currentSelectedLesson = agCourseLessonList?.agCourses?.nodes?.first;
      }
    } on Exception catch (_) {
      currentSelectedLesson = agCourseLessonList?.agCourses?.nodes?.first;
    }
  }

  Widget courseDetailHelp() {
    return Container(
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
    );
  }

  Widget bodyView() {
    return SingleChildScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      child: Stack(
        children: [
          customTopContainer(
            bgImage: '',
            backgroundColor: AppColors.headerColor,
            height: 200.h,
            radius: 30.r,
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 32.w,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AskLiveTeacherDialog(
                      widget: courseDetailHelp(),
                      isSupportView: false,
                      onClick: () {
                        // context.read<VideoBloc>().add(PauseVideo());
                        _controller?.pause();
                        if (_chewieController != null) {
                          _chewieController?.pause();
                        }
                      },
                    ),
                    const Spacer(),
                  ],
                ),
                InkWell(
                  splashColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  onTap: () {},
                  child: Container(
                    width: Get.width,
                    height: 230.h,
                    margin: EdgeInsets.only(top: 8.h, bottom: 10.h),
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      color: AppColors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: (courseData?.courseTypeImage?.coursePreview !=
                                null) &&
                            (courseData?.courseTypeImage?.coursePreview?.node
                                    ?.mediaItemUrl?.isNotEmpty ??
                                false) &&
                            _chewieController != null &&
                            _chewieController!
                                .videoPlayerController.value.isInitialized
                        ? Container(
                            color: AppColors.black,
                            width: Get.width,
                            height: 190.h,
                            child: Chewie(controller: _chewieController!),
                          )
                        : Stack(
                            children: [
                              AGImageView(
                                courseData?.courseTypeImage?.courseCategoryImage
                                        ?.node?.mediaItemUrl ??
                                    '',
                                fit: BoxFit.cover,
                                width: Get.width,
                                height: 230.h,
                              ),
                              Positioned(
                                bottom: 18,
                                left: 18,
                                right: 18,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      AssetImages.icPlay,
                                      height: 40.h,
                                      width: 40.w,
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 25.w,
                                      ),
                                      height: 30.h,
                                      alignment: Alignment.center,
                                      clipBehavior: Clip.hardEdge,
                                      decoration: BoxDecoration(
                                        color:
                                            AppColors.black.withOpacity(0.25),
                                        borderRadius: BorderRadius.circular(21),
                                      ),
                                      child: Text(
                                        'Preview course',
                                        style:
                                            AppFontStyle.dmSansRegular.copyWith(
                                          color: AppColors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.h),
                    child: AGBannerAd(adSize: AdSize.mediumRectangle),
                  ),
                ),
                Text(
                  courseData?.name ?? "",
                  style: AppFontStyle.dmSansBold.copyWith(
                    color: AppColors.cardTextColor,
                    fontSize: 25.sp,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: _customRowWithIcon(
                          icon: AssetImages.icStar,
                          title: "-",
                          subTitle: ' (- ratings)',
                        ),
                      ),
                      SizedBox(width: 15.w),
                      Expanded(
                        child: _customRowWithIcon(
                          icon: AssetImages.icStudent,
                          title: "-",
                          subTitle: ' (- students)',
                        ),
                      ),
                    ],
                  ),
                ),
                if (isCoursePurchased) ...[
                  Container(
                    height: 6.h,
                    margin: EdgeInsets.only(bottom: 8.h, top: 5.h),
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(30.r),
                      ),
                    ),
                    child: LinearProgressIndicator(
                      value: (studentProgress / 100),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.progressBarActiveColor,
                      ),
                      backgroundColor: AppColors.progressBarColor,
                    ),
                  ),
                  Text(
                    '$studentProgress% Completed',
                    style: AppFontStyle.dmSansRegular.copyWith(
                      color: AppColors.lightGrey,
                      fontSize: 15.sp,
                    ),
                  ),
                  SizedBox(height: (isCoursePurchased) ? 15.h : 0),
                ],
                ReadMoreText(
                  courseData?.description ?? '',
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
                _customContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'This Course Includes',
                        textAlign: TextAlign.center,
                        style: AppFontStyle.dmSansBold.copyWith(
                          fontSize: 18.sp,
                          color: AppColors.cardTextColor,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 10.h,
                        ),
                        child: _customCardRow(
                          icon: AssetImages.icClock,
                          value:
                              '${courseData?.courseTypeImage?.courseHours} hours on demand video',
                        ),
                      ),
                      _customCardRow(
                        icon: AssetImages.icMobile,
                        value: 'Access on Mobile, Tab, PC and laptop ',
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 10.h,
                        ),
                        child: _customCardRow(
                          icon: AssetImages.icCertificate,
                          value: 'Certificate of completion',
                        ),
                      ),
                      _customCardRow(
                        icon: AssetImages.icWorkshop,
                        value: 'Workshops under each project',
                      ),
                      if ((courseAmountResponseModel != null) &&
                          !isCoursePurchased) ...[
                        Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 15.h,
                          ),
                          child: Divider(
                            height: 0,
                            color: AppColors.questionDividerColor,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              isMonthlyCourse ? '999' : '999',
                              style: AppFontStyle.poppinsBold.copyWith(
                                fontSize: 22.sp,
                                color: AppColors.cardTextColor,
                              ),
                            ),
                            SizedBox(width: 5.w),
                            Text(
                              isMonthlyCourse ? '' : '2499',
                              style: AppFontStyle.poppinsRegular.copyWith(
                                fontSize: 22.sp,
                                decoration: TextDecoration.lineThrough,
                                color: AppColors.priceColor,
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Text(
                              isMonthlyCourse ? 'Monthly' : 'For 6 Months',
                              style: AppFontStyle.poppinsRegular.copyWith(
                                fontSize: 12.sp,
                                color: AppColors.cardTextColor,
                              ),
                            ),
                            SizedBox(width: 5.w),
                            Text(
                              isMonthlyCourse ? '' : 'Monthly',
                              style: AppFontStyle.poppinsRegular.copyWith(
                                fontSize: 12.sp,
                                decoration: TextDecoration.lineThrough,
                                color: AppColors.priceColor,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20.h),
                      ],
                      Visibility(
                        visible: !isCoursePurchased,
                        child: customButton(
                          onTap: () {
                            /// 🔹 CHECK LOGIN
                            final isUserLoggedIn = user != null;

                            if (!isUserLoggedIn) {
                              Get.toNamed(Routes.login);
                              StorageManager.instance.setBool(
                                  LocalStorageKeys.prefGuestLogin, false);
                              StorageManager.instance.clear();
                              return;
                            }

                            if (Platform.isIOS) {
                              Get.toNamed(
                                Routes.planPage,
                                arguments: [courseId, false],
                              );
                            } else {
                              String url;

                              if (isMonthlyCourse) {
                                url =
                                    '${baseUrl}checkout/?add-to-cart=28543&variation_id=45891&attribute_pa_subscription-pricing=monthly&ag_wv_token=${Uri.encodeQueryComponent(token)}&utm_source=AppWebView&ag_course_dropdown=$databaseId&student_id=${user?.databaseId}';
                              } else {
                                url =
                                    '${baseUrl}checkout/?add-to-cart=475&ag_course_dropdown=$databaseId&student_id=${user?.databaseId.toString()}&ag_wv_token=${Uri.encodeQueryComponent(token)}&utm_source=AppWebView';
                              }
                              debugPrint('url===> $url');
                              debugPrint('url===> $url');
                              launchUrlInExternalBrowser(url);
                            }
                          },
                          boxColor: AppColors.alertButtonColor,
                          child: Text(
                            ("Get Started").toUpperCase(),
                            textAlign: TextAlign.center,
                            style: AppFontStyle.dmSansBold.copyWith(
                              color: AppColors.white,
                              fontSize: 17.sp,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                AGBannerAd(adSize: AdSize.mediumRectangle),
                _customContainer(
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 110.h,
                        width: Get.width,
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          color: AppColors.tabBarColor,
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: 23.h,
                          horizontal: 28.w,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Course Content',
                              style: AppFontStyle.dmSansBold.copyWith(
                                fontSize: 21.sp,
                                color: AppColors.white,
                              ),
                            ),
                            SizedBox(height: 5.h),
                            Row(
                              children: [
                                _contentText(
                                  value: '${courseData?.count ?? 0} Lessons',
                                ),
                                SizedBox(
                                  height: 18.h,
                                  child: VerticalDivider(
                                    color: AppColors.greyColor9595,
                                    width: 20.w,
                                  ),
                                ),
                                _contentText(
                                  value:
                                      '${courseData?.courseTypeImage?.courseHours ?? "0"} hours',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      courseContentView(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget courseContentView() {
    List<Lesson>? courseContent = agCourseLessonList?.agCourses?.nodes ?? [];
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 28.w),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: courseContent.length,
      itemBuilder: (BuildContext context, int index) {
        Lesson lesson = courseContent[index];
        // bool isLessonInProgress = lesson.id == currentSelectedLesson?.id;
        return Column(
          children: [
            Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
              ),
              child: ExpansionTile(
                initiallyExpanded: false,
                childrenPadding: EdgeInsets.zero,
                tilePadding: EdgeInsets.zero,
                clipBehavior: Clip.hardEdge,
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                expandedAlignment: Alignment.topLeft,
                iconColor: AppColors.cardTextColor,
                collapsedIconColor: AppColors.cardTextColor,
                title: Row(
                  children: [
                    if (isCoursePurchased && (lesson.completed ?? false)) ...[
                      Container(
                        width: 20.w,
                        height: 20.h,
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          color: (lesson.completed ?? false)
                              ? AppColors.green
                              : Colors.black,
                          shape: BoxShape.circle,
                        ),
                        padding: EdgeInsets.all(5.w),
                        child: SvgPicture.asset(
                          AssetImages.icCorrect,
                          width: 5.w,
                          height: 5.w,
                          colorFilter: const ColorFilter.mode(
                            AppColors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                    ],
                    Expanded(
                      child: Text(
                        lesson.title ?? '',
                        style: AppFontStyle.dmSansMedium.copyWith(
                          fontSize: 18.sp,
                          color: AppColors.cardTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
                subtitle: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      height: 15.h,
                      width: 15.w,
                      margin: EdgeInsets.only(right: 10.w),
                      child: SvgPicture.asset(
                        AssetImages.icClock,
                        height: 15.h,
                        fit: BoxFit.scaleDown,
                      ),
                    ),
                    Text(
                      '- min',
                      style: AppFontStyle.dmSansRegular.copyWith(
                        fontSize: 15.sp,
                        color: AppColors.lightGrey,
                      ),
                    ),
                  ],
                ),
                children: [
                  if (lesson.lessonVideo != null &&
                      (lesson.lessonVideo?.videoDetails?.isNotEmpty ??
                          false)) ...[
                    Text(
                      lesson.lessonVideo?.videoDetails ?? '',
                      style: AppFontStyle.dmSansRegular.copyWith(
                        fontSize: 15.sp,
                        color: AppColors.lightGrey,
                      ),
                    ),
                    SizedBox(height: 2.h),
                  ],
                  if (lesson.completed ?? false) ...[
                    Visibility(
                      visible: isCoursePurchased,
                      child: customButton(
                        onTap: () {
                          // context.read<VideoBloc>().add(PauseVideo());
                          _controller?.pause();
                          if (_chewieController != null) {
                            _chewieController?.pause();
                          }
                          Get.toNamed(
                            Routes.lessonDetailPage,
                            arguments: [
                              courseData,
                              lesson.completed ?? false,
                              notCompletedLesson
                            ],
                            parameters: {"id": lesson.id ?? ''},
                          );
                        },
                        boxColor: AppColors.buttonColor,
                        child: Text(
                          'Review',
                          textAlign: TextAlign.center,
                          style: AppFontStyle.dmSansBold.copyWith(
                            color: AppColors.white,
                            fontSize: 17.sp,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),
                  ],
                ],
              ),
            ),
            if (index != (courseContent.length - 1)) ...[
              SizedBox(height: 1.h),
              _divider(),
            ],
          ],
        );
      },
    );
  }

  Widget _customRowWithIcon(
      {required String icon, String? title, String? subTitle}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SvgPicture.asset(icon),
        SizedBox(width: 5.w),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: title ?? "",
                  style: AppFontStyle.dmSansRegular.copyWith(
                    fontSize: 14.sp,
                    color: AppColors.alertButtonBlackColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(
                  text: subTitle ?? "",
                  style: AppFontStyle.dmSansRegular.copyWith(
                    fontSize: 14.sp,
                    color: AppColors.lightGrey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _customCardRow({required String icon, String? value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 20.h,
          width: 20.w,
          child: SvgPicture.asset(icon),
        ),
        SizedBox(
          width: 10.w,
        ),
        Expanded(
          child: Text(
            value ?? '',
            style: AppFontStyle.dmSansRegular
                .copyWith(fontSize: 15.sp, color: AppColors.lightGrey),
          ),
        ),
      ],
    );
  }

  Widget _customContainer({
    Key? key,
    Widget? child,
    EdgeInsetsGeometry? padding,
  }) {
    return Container(
      key: key,
      width: Get.width,
      padding:
          padding ?? EdgeInsets.symmetric(vertical: 23.h, horizontal: 28.w),
      margin: EdgeInsets.symmetric(vertical: 20.h),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 6.r,
            offset: const Offset(0, 9),
          )
        ],
      ),
      child: child,
    );
  }

  Widget _contentText({String? value}) {
    return Text(
      value ?? "",
      style: AppFontStyle.dmSansRegular.copyWith(
        fontSize: 15.sp,
        color: AppColors.lightGreyColor,
      ),
    );
  }

  Widget _divider() {
    return Divider(height: 0, color: AppColors.questionDividerColor);
  }
}
