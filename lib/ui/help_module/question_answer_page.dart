import 'package:azan_guru_mobile/bloc/help_desk_module/question_bloc/question_answer_bloc.dart';
import 'package:azan_guru_mobile/common/custom_text_field.dart';
import 'package:azan_guru_mobile/common/util.dart';
import 'package:azan_guru_mobile/constant/app_assets.dart';
import 'package:azan_guru_mobile/constant/app_colors.dart';
import 'package:azan_guru_mobile/constant/font_style.dart';
import 'package:azan_guru_mobile/route/app_routes.dart';
import 'package:azan_guru_mobile/ui/common/loader.dart';
import 'package:azan_guru_mobile/ui/common/no_data.dart';

import 'package:azan_guru_mobile/ui/model/mdl_question_answer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:azan_guru_mobile/ui/common/secondary_ag_header_bar.dart';
import 'package:get/get.dart';

class QuestionAnswerPage extends StatefulWidget {
  const QuestionAnswerPage({super.key});

  @override
  State<QuestionAnswerPage> createState() => _QuestionAnswerPageState();
}

class _QuestionAnswerPageState extends State<QuestionAnswerPage> {
  // List<MDLQuestionAnswer> mdlQuestionAnswer = [
  //   MDLQuestionAnswer(
  //     question: "Hom many Quranic alphabets are in Quran?",
  //     answer: "There are 29 alphabets in the holy Quraan.",
  //   ),
  //   MDLQuestionAnswer(
  //     question: "Does AzanGuru offer separate lady classes?",
  //     answer: "Yes, AzanGuru offers separate lady classes.",
  //   ),
  //   MDLQuestionAnswer(
  //     question:
  //         "I have paid the course Hadya but the course is not accessible?",
  //     answer:
  //         "Kindly, check the course in My Courses or Enrolled courses. Or There may be some technical issue. Please refresh the app.",
  //   ),
  //   MDLQuestionAnswer(
  //     question: "Does AzanGuru offer 24*7 classes?",
  //     answer: "Yes, AzanGuru offers 24*7 classes.",
  //   ),
  //   MDLQuestionAnswer(
  //     question: "How to pronounce the Arabic letters?",
  //     answer:
  //         "Each and every letter has different exits, You’ll come to know the exact pronunciation in the lesson.",
  //   ),
  // ];
  final TextEditingController _searchController = TextEditingController();
  QuestionAnswerBloc bloc = QuestionAnswerBloc();

  @override
  void initState() {
    super.initState();
    getDataFromServer();
    _searchController.addListener(() {
      bloc.add(GetQuestionSearchEvent(
          search: _searchController.text, showLoader: false));
    });
  }

  getDataFromServer() {
    bloc.add(GetQuestionSearchEvent(search: ''));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLightWhitColor,
      body: Stack(
        children: [
          customTopContainer(
            bgImage: AssetImages.icBgMyCourse,
            height: 280.h,
          ),
          Column(
            children: [
              SecondaryAgHeaderBar(
                backgroundColor: Colors.transparent,
                pageTitle: '',
              ),
              BlocConsumer<QuestionAnswerBloc, QuestionAnswerState>(
                bloc: bloc,
                listener: (context, state) {
                  if (state is QuestionAnswerLoadingState) {
                    AGLoader.show(context);
                  } else if (state is QuestionAnswerErrorState) {
                    AGLoader.hide();
                  } else if (state is QuestionAnswerSuccessState) {
                    AGLoader.hide();
                  }
                },
                builder: (context, state) {
                  if (state is QuestionAnswerErrorState) {
                    return const NoData();
                  }
                  if (state is QuestionAnswerLoadingState) {
                    const SizedBox.shrink();
                  }
                  return Expanded(
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              top: 15.h, bottom: 20.h, left: 40.w, right: 40.w),
                          child: Text(
                            'Question \nAnswers',
                            textAlign: TextAlign.center,
                            style: AppFontStyle.poppinsMedium.copyWith(
                              fontSize: 27.sp,
                              color: AppColors.white,
                              height: 1.12,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              left: 40.w, right: 40, bottom: 10.h),
                          child: CustomTextField(
                            controller: _searchController,
                            cursorColor: AppColors.appBgColor,
                            backgroundColor: AppColors.white,
                            borderColor: AppColors.white,
                            hintTexts: 'Search',
                            textInputTextStyle: AppFontStyle.dmSansRegular
                                .copyWith(
                                    fontSize: 15.sp,
                                    color: AppColors.lightGrey),
                            // suffixIconWidget: Container(
                            //   clipBehavior: Clip.hardEdge,
                            //   margin: EdgeInsets.only(right: 5.w),
                            //   height: 40.h,
                            //   width: 40.w,
                            //   decoration: BoxDecoration(
                            //       shape: BoxShape.circle, color: AppColors.iconButtonColor),
                            //   child: SvgPicture.asset(
                            //     AssetImages.icAudio,
                            //     fit: BoxFit.scaleDown,
                            //   ),
                            // ),
                            // suffixOnTap: () {},
                            prefixIconShow: true,
                            prefixIcon: AssetImages.icSearch,
                            onChanges: (val) {
                              debugPrint("val ======== $val");
                              bloc.add(GetQuestionSearchEvent(search: val));
                            },
                          ),
                        ),
                        if (state is QuestionAnswerSuccessState)
                          Expanded(
                            child: state.mdlQuestionAnswer?.nodes?.isNotEmpty ??
                                    false
                                ? ListView.builder(
                                    // shrinkWrap: true,
                                    physics: const BouncingScrollPhysics(),
                                    padding: EdgeInsets.only(
                                        top: 15.h,
                                        left: 32.w,
                                        right: 32.w,
                                        bottom: 20.h),
                                    itemCount:
                                        state.mdlQuestionAnswer?.nodes?.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return _questionTile(
                                        state.mdlQuestionAnswer?.nodes?[index],
                                        onTap: () {
                                          Get.toNamed(
                                            Routes.answerDetailPage,
                                            arguments: state.mdlQuestionAnswer
                                                ?.nodes?[index].id
                                                .toString(),
                                          );
                                        },
                                      );
                                    },
                                  )
                                : const NoData(),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _questionTile(QuestionNodes? questionNodes, {Function()? onTap}) {
    return InkWell(
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.hardEdge,
        margin: EdgeInsets.only(bottom: 20.h),
        padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 25.h),
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
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Q : ${questionNodes?.title}',
                style: AppFontStyle.poppinsMedium
                    .copyWith(fontSize: 15.sp, color: AppColors.appBgColor),
              ),
            ),
            SizedBox(width: 5.w),
            SvgPicture.asset(AssetImages.icArrowQuestion)
          ],
        ),
      ),
    );
  }
}
