import 'dart:developer';

import 'package:azan_guru_mobile/bloc/guide_choose_course_bloc/choose_course_bloc.dart';
import 'package:azan_guru_mobile/bloc/player_bloc/player_bloc.dart';
import 'package:azan_guru_mobile/common/custom_button.dart';
import 'package:azan_guru_mobile/common/util.dart';
import 'package:azan_guru_mobile/constant/app_assets.dart';
import 'package:azan_guru_mobile/constant/app_colors.dart';
import 'package:azan_guru_mobile/constant/font_style.dart';
import 'package:azan_guru_mobile/route/app_routes.dart';
import 'package:azan_guru_mobile/ui/app.dart';
import 'package:azan_guru_mobile/ui/common/loader.dart';
import 'package:azan_guru_mobile/ui/model/mdl_choose_question.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class ChooseCoursePage extends StatefulWidget {
  const ChooseCoursePage({super.key});

  @override
  State<ChooseCoursePage> createState() => _ChooseCoursePageState();
}

class _ChooseCoursePageState extends State<ChooseCoursePage> {
  List<Color> layerColor = [
    AppColors.layerColorFirst,
    AppColors.layerColorSecond,
    AppColors.layerColorThird,
  ];

  List<AgQuestionsNode> questionList = [];
  int currentIndexPage = 0;
  ChooseCourseBloc bloc = ChooseCourseBloc();
  bool? isUnder20 = false;
  int clickedIndex = -1;

  List<String>? givenAnswerList = [];

  @override
  void initState() {
    super.initState();
    bloc.add(GetChooseCourseListEvent());
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        globalPlayerBloc.add(OnResetPlayStatesEvent());
      },
      child: BlocConsumer<ChooseCourseBloc, ChooseCourseState>(
        bloc: bloc,
        listener: (context, state) {
          if (state is ChooseCourseLoadingState) {
            AGLoader.show(context);
          } else if (state is ChooseCourseErrorState) {
            AGLoader.hide();
          } else if (state is ChooseCourseSuccessState) {
            AGLoader.hide();
            globalPlayerBloc.add(OnResetPlayStatesEvent());
            questionList.clear();
            questionList.addAll(
              [
                AgQuestionsNode(
                  id: 'gender',
                  title: 'Choose your Gender?',
                  chooseYourCourse: ChooseYourCourse(
                    questionType: ["Radio"],
                    options: [
                      Option(
                        option: 'Male',
                        questionIcon: [AssetImages.icMale],
                      ),
                      Option(
                        option: 'Female',
                        questionIcon: [AssetImages.icFemale],
                      ),
                    ],
                  ),
                ),
                AgQuestionsNode(
                  id: 'ageBracket',
                  title: 'In which age bracket you are in?',
                  chooseYourCourse: ChooseYourCourse(
                    questionType: ["Radio"],
                    options: [
                      Option(
                        option: 'Under 20',
                        questionIcon: [AssetImages.icUnderMale],
                      ),
                      Option(
                        option: 'Above 20',
                        questionIcon: [AssetImages.icAboveMale],
                      ),
                    ],
                  ),
                ),
              ],
            );
            questionList.addAll((state.mdlChooseQuestion?.nodes ?? []));
          }
        },
        builder: (context, state) {
          return Scaffold(
            body: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: _backgroundView(),
                ),
                (state is ChooseCourseLoadingState)
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: EdgeInsets.only(
                          left: 45.w,
                          right: 45.w,
                          top: 50.h,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Let us Help You\nto Choose Your Course',
                              textAlign: TextAlign.center,
                              style: AppFontStyle.poppinsMedium.copyWith(
                                fontSize: 30.sp,
                                color: AppColors.white,
                              ),
                            ),
                            if (questionList.isNotEmpty) ...[
                              _cardDetail(),
                            ],
                            ...List.generate(
                              3,
                              (index) {
                                return _bottomLayer(
                                  index: index,
                                  color: layerColor[index],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _backgroundView() {
    return customTopContainer(
      bgImage: AssetImages.icSlider1,
      height: 580.h,
      radius: 25.r,
      insideChild: customAppBar(
        showPrefixIcon: true,
        onClick: () {
          globalPlayerBloc.add(OnResetPlayStatesEvent());
          Get.back();
        },
      ),
    );
  }

  Widget _cardDetail() {
    AgQuestionsNode? courseData =
        (currentIndexPage >= 0) ? questionList[currentIndexPage] : null;
    String optionType = courseData == null
        ? ''
        : ((courseData.chooseYourCourse?.questionType?.isEmpty ?? false)
            ? ''
            : (courseData.chooseYourCourse?.questionType?.first ?? ''));
    return Container(
      padding: EdgeInsets.only(top: 30.h, bottom: 20.h),
      margin: EdgeInsets.only(top: 35.h),
      height: Get.height * 0.70.h,
      width: Get.width,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.all(Radius.circular(16.r)),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadowColor,
            blurRadius: 6.r,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.only(left: 35.w, right: 35.w),
          child: Column(
            children: [
              if (courseData != null) ...[
                Text(
                  courseData.title ?? '',
                  textAlign: TextAlign.center,
                  style: AppFontStyle.dmSansMedium.copyWith(
                    fontSize: 23.sp,
                    color: AppColors.alertButtonBlackColor,
                  ),
                ),
                (optionType.isBlank ?? false)
                    ? Container()
                    : optionType == 'Radio'
                        ? radioTypeQuetion(
                            currentIndexPage,
                            courseData,
                          )
                        : optionType == 'AlphabetOrder'
                            ? correctAlphabetsOrderQuizView(
                                currentIndexPage,
                                courseData,
                              )
                            : optionType == 'AudioType'
                                ? chooseAudioQuizView(
                                    currentIndexPage,
                                    courseData,
                                  )
                                : Container(),
              ],
              if (courseData == null) ...[
                noCourse(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget noCourse() {
    return Column(
      children: [
        Text(
          'Congrats your results is awesome',
          textAlign: TextAlign.center,
          style: AppFontStyle.dmSansBold.copyWith(
            fontSize: 20.sp,
            color: AppColors.alertButtonBlackColor,
          ),
        ),
        SizedBox(height: 20.h),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(
                text:
                    "Alhamdulillah, as a Hafiz who knows all Tajweed rules, you don't need to purchase any courses. You should teach those in need. If you want to learn advanced Tajweed or join a Qirat course, you'll have to wait a bit. Our Qirat course is coming soon, and our team will update you, inshallah.\n\nAlso You can apply to become a program partner by ",
                style: AppFontStyle.dmSansRegular.copyWith(
                  fontSize: 18.sp,
                  color: AppColors.alertButtonBlackColor,
                ),
              ),
              TextSpan(
                text: 'clicking here.',
                style: AppFontStyle.dmSansRegular.copyWith(
                  fontSize: 18.sp,
                  color: AppColors.alertButtonBlackColor,
                  decoration: TextDecoration.underline,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    String url = 'https://azanguru.com/job-with-azanguru/';
                    Get.toNamed(Routes.agWebViewPage, arguments: url);
                  },
              ),
            ],
          ),
        ),
        SizedBox(height: 20.h),
        customButton(
          onTap: () {
            Get.back();
          },
          boxColor: AppColors.alertButtonColor,
          child: Text(
            'ok'.toUpperCase(),
            textAlign: TextAlign.center,
            style: AppFontStyle.dmSansBold.copyWith(
              color: AppColors.white,
              fontSize: 17.sp,
            ),
          ),
        )
      ],
    );
  }

  Widget radioTypeQuetion(int index, AgQuestionsNode courseData) {
    List<Option>? options = courseData.chooseYourCourse?.options;
    String? alphabets = courseData.chooseYourCourse?.alphabets;
    return Column(
      children: [
        if (alphabets != null && alphabets != '') ...[
          SizedBox(height: 3.h),
          Text(
            alphabets,
            textAlign: TextAlign.center,
            style: AppFontStyle.dmSansBold.copyWith(
              fontSize: 25.sp,
              color: AppColors.alertButtonBlackColor,
            ),
          ),
          SizedBox(height: 3.h),
        ],
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.only(top: 15.h),
          itemCount: options?.length,
          itemBuilder: (BuildContext context, int subIndex) {
            Option? data = options![subIndex];
            return Padding(
              padding: EdgeInsets.only(bottom: 15.h),
              child: _customButton(
                data,
                onTap: () {
                  if (options.isNotEmpty) {
                    setState(() {
                      for (int i = 0; i < options.length; i++) {
                        options[i].isSelected = false;
                      }
                      data.isSelected = true;
                      if (currentIndexPage == 1) {
                        isUnder20 = data.option == 'Under 20';
                      }
                      if (((courseData.id == 'gender') ||
                              (courseData.id == 'ageBracket')) &&
                          (currentIndexPage >= 2)) {
                        showCourse(data);
                      } else if (currentIndexPage >= 2) {
                        showCourse(data);
                      } else {
                        currentIndexPage = currentIndexPage + 1;
                      }
                    });
                  }
                },
              ),
            );
          },
        ),
      ],
    );
  }

  showCourse(Option? data) {
    if (data?.nextQuestion == null && data?.showCourse != null) {
      ShowCourseNode? courseToShow = data?.showCourse?.nodes?.firstWhere(
        (element) => (isUnder20 ?? false)
            ? kidsCourseIds.contains(element.id)
            : adultCourseIds.contains(element.id),
      );
      Get.offAndToNamed(
        Routes.courseSuggestionPage,
        arguments: courseToShow,
      );
    } else if ((data?.nextQuestion != null) &&
        (data?.nextQuestion?.nodes?.isNotEmpty ?? false)) {
      int nextQueIndex = questionList.indexWhere(
          (element) => element.id == data?.nextQuestion?.nodes?.first.id);
      currentIndexPage = nextQueIndex;
    } else {
      currentIndexPage = -1;
    }
  }

  String correctAnswer(AgQuestionsNode courseData) {
    // List<Option>? options = courseData.chooseYourCourse?.optionIndexed;
    // List<int>? correctAnswerList =
    //     (courseData.chooseYourCourse?.alphabetOrderWordOrder?.split(',') ?? [])
    //         .map(int.parse)
    //         .toList();
    List<String>? correctAnswerList =
        (courseData.chooseYourCourse?.alphabetOrderWordOrder?.split(',') ?? [])
            .map((e) => e)
            .toList();
    String correctAnswer = '';
    for (var element in correctAnswerList) {
      // correctAnswer = '$correctAnswer${options?[element - 1].option}';
      correctAnswer = '$correctAnswer$element';
    }
    return correctAnswer;
  }

  Widget correctAlphabetsOrderQuizView(int index, AgQuestionsNode courseData) {
    List<Option>? options = courseData.chooseYourCourse?.optionIndexed;
    String? alphabets = courseData.chooseYourCourse?.alphabets;
    return Column(
      children: [
        if (alphabets != null && alphabets != '') ...[
          SizedBox(height: 3.h),
          Text(
            alphabets,
            textAlign: TextAlign.center,
            style: AppFontStyle.dmSansBold.copyWith(
              fontSize: 25.sp,
              color: AppColors.alertButtonBlackColor,
            ),
          ),
          SizedBox(height: 3.h),
        ],
        Container(
          margin: EdgeInsets.all(10.h),
          child: Wrap(
            children: List.generate(
              options?.length ?? 0,
              (index) {
                Option? quizOptions = options?[index];
                bool? isSelected =
                    givenAnswerList?.contains(quizOptions?.option);
                return InkWell(
                  onTap: () {
                    // quizOptions?.isSelected = true;
                    givenAnswerList?.add(quizOptions?.option ?? '');
                    debugPrint(
                        "message>>>>>>>>>> ${givenAnswerList.toString()}");
                    setState(() {});
                  },
                  child: Container(
                    width: 50.w,
                    height: 50.w,
                    margin: EdgeInsets.all(5.h),
                    padding: EdgeInsets.symmetric(
                      vertical: 10.h,
                      horizontal: 10.w,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(11.r),
                      border: Border.all(
                        color: (isSelected ?? false)
                            ? AppColors.buttonGreenColor
                            : AppColors.audioBorderColor,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        quizOptions?.option ?? '',
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
        if (givenAnswerList?.isNotEmpty ?? false) ...[
          Container(
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
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
                  givenAnswerList?.join() ?? '',
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: AppFontStyle.dmSansBold.copyWith(
                    fontSize: 25.sp,
                    color: AppColors.alertButtonBlackColor,
                  ),
                ),
                InkWell(
                  onTap: () {
                    givenAnswerList?.clear();
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
            ),
          ),
        ],
        SizedBox(height: 8.h),
        Padding(
          padding: EdgeInsets.all(3.h),
          child: customButton(
            onTap: () {
              final String givenAnswer = givenAnswerList?.join() ?? '';
              debugPrint("message>>>>> $givenAnswer");
              debugPrint("givenAnswerList>>>>> $givenAnswerList");
              final String rightAnswer = correctAnswer(courseData);
              debugPrint("message>>>>> $rightAnswer");
              if (rightAnswer == givenAnswer) {
                debugPrint("message>>>>> $givenAnswer");
                if (courseData.chooseYourCourse?.correctAlphabetNextQuestion
                        ?.edges?.isNotEmpty ??
                    false) {
                  int nextQueIndex = questionList.indexWhere((element) =>
                      element.id ==
                      courseData.chooseYourCourse?.correctAlphabetNextQuestion
                          ?.edges?.first.node?.id);
                  currentIndexPage = nextQueIndex;
                } else {
                  currentIndexPage = -1;
                }
              } else {
                if (courseData.chooseYourCourse?.incorrectAlphabetOrder !=
                    null) {
                  ShowCourseNode? courseToShow =
                      courseData.chooseYourCourse?.incorrectAlphabetOrder?.edges
                          ?.firstWhere(
                            (element) => (isUnder20 ?? false)
                                ? kidsCourseIds.contains(element.node?.id)
                                : adultCourseIds.contains(element.node?.id),
                          )
                          .node;
                  Get.offAndToNamed(
                    Routes.courseSuggestionPage,
                    arguments: courseToShow,
                  );
                }
              }
              setState(() {});
            },
            boxColor: AppColors.buttonGreenColor,
            padding: EdgeInsets.symmetric(horizontal: 25.w),
            width: 200.w,
            child: Text(
              'SUBMIT',
              textAlign: TextAlign.center,
              style: AppFontStyle.poppinsRegular.copyWith(
                color: AppColors.white,
                fontSize: 14.sp,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ),
      ],
    );
  }

  Widget chooseAudioQuizView(int index, AgQuestionsNode courseData) {
    List<Option>? options = courseData.chooseYourCourse?.options;
    String? alphabets = courseData.chooseYourCourse?.alphabets;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (alphabets != null && alphabets != '') ...[
          SizedBox(height: 3.h),
          Text(
            alphabets,
            textAlign: TextAlign.center,
            style: AppFontStyle.dmSansBold.copyWith(
              fontSize: 25.sp,
              color: AppColors.alertButtonBlackColor,
            ),
          ),
          SizedBox(height: 3.h),
        ],
        ...List.generate(
          options?.length ?? 0,
          (index) {
            Option? audio = options?[index];
            return Container(
              width: Get.width,
              margin: EdgeInsets.only(bottom: 5.h, top: 5.h),
              padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 13.w),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(11.r),
                border: Border.all(color: AppColors.audioBorderColor),
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      for (int i = 0; i < (options!.length); i++) {
                        options[i].isSelected = false;
                      }
                      audio?.isSelected = true;
                      showCourse(audio);
                      setState(() {});
                    },
                    child: Container(
                      width: 22.w,
                      height: 22.h,
                      margin: EdgeInsets.only(right: 10.w),
                      decoration: BoxDecoration(
                        color: audio?.isSelected ?? false
                            ? AppColors.appBgColor
                            : AppColors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          width: audio?.isSelected ?? false ? 5.w : 1.w,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: player(
                      index,
                      audio?.audioOption?.node?.mediaItemUrl ?? '',
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
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

  Widget _bottomLayer({required int index, Color? color}) {
    return Container(
      height: 10.h,
      width: Get.width,
      clipBehavior: Clip.hardEdge,
      margin: EdgeInsets.symmetric(horizontal: (index + 1) * 15.w),
      decoration: BoxDecoration(
        color: color ?? AppColors.bgColorBottom,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(15.r),
          bottomRight: Radius.circular(15.r),
        ),
      ),
    );
  }

  Widget _customButton(
    Option? data, {
    Function()? onTap,
  }) {
    return customButton(
      onTap: onTap,
      managedWithPadding: true,
      boxColor: data?.isSelected ?? false
          ? AppColors.alertButtonColor
          : AppColors.layerColorFirst,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if ((data?.questionIcon?.isNotEmpty ?? false) &&
              (data?.questionIcon?.first != 'None') &&
              (data?.questionIcon?[0] != null)) ...[
            SizedBox(
              height: 30.h,
              width: 30.w,
              child: SvgPicture.asset(
                data?.questionIcon?[0] ?? "",
                colorFilter: ColorFilter.mode(
                  data?.isSelected ?? false
                      ? AppColors.white
                      : AppColors.greenTextColor,
                  BlendMode.srcIn,
                ),
              ),
            ),
            SizedBox(width: 10.w),
          ],
          Expanded(
            child: Text(
              data?.option ?? "",
              style: AppFontStyle.dmSansMedium.copyWith(
                color: data?.isSelected ?? false
                    ? AppColors.white
                    : AppColors.greenTextColor,
                fontSize: 16.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
