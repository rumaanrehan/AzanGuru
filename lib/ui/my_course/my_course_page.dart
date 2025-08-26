import 'dart:io';

import 'package:azan_guru_mobile/bloc/my_course_bloc/my_course_bloc.dart';
import 'package:azan_guru_mobile/common/custom_button.dart';
import 'package:azan_guru_mobile/common/util.dart';
import 'package:azan_guru_mobile/constant/app_assets.dart';
import 'package:azan_guru_mobile/constant/app_colors.dart';
import 'package:azan_guru_mobile/constant/font_style.dart';
import 'package:azan_guru_mobile/constant/language_key.dart';
import 'package:azan_guru_mobile/route/app_routes.dart';
import 'package:azan_guru_mobile/service/local_storage/local_storage_keys.dart';
import 'package:azan_guru_mobile/service/local_storage/storage_manager.dart';
import 'package:azan_guru_mobile/ui/common/course_tile.dart';
import 'package:azan_guru_mobile/ui/common/loader.dart';
import 'package:azan_guru_mobile/ui/model/ag_categories_data.dart';
import 'package:azan_guru_mobile/ui/model/lesson_progress_update.dart';
import 'package:azan_guru_mobile/ui/model/mdl_course.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:azan_guru_mobile/ui/common/ads/ag_banner_ad.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class MyCoursePage extends StatefulWidget {
  const MyCoursePage({super.key});

  @override
  State<MyCoursePage> createState() => _MyCoursePageState();
}

class _MyCoursePageState extends State<MyCoursePage> {
  List<MDLCourseList>? mdlCourseList = [];
  MDLLessonProgress? mdlLessonProgress;

  bool get isUserLoggedIn => user != null;

  MyCourseBloc get bloc => context.read<MyCourseBloc>();

  @override
  void initState() {
    if (isUserLoggedIn) {
      bloc.add(GetMyCourseEvent());
      bloc.add(LessonProgressUpdateEvent());
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MyCourseBloc, MyCourseState>(
      listener: (context, state) {
        if (state is MCShowLoadingState) {
          if (!AGLoader.isShown) {
            AGLoader.show(context);
          }
        } else if (state is MCHideLoadingState) {
          if (AGLoader.isShown) {
            AGLoader.hide();
          }
        } else if (state is GetMyCourseState) {
          mdlCourseList?.clear();
          mdlCourseList?.addAll(state.nodes ?? []);
        } else if (state is UpdateMyCourseCompletedState) {
          // mdlCourseList?.forEach((element) {
          //   element.studentCompletedLessons?.nodes =
          //       state.studentCompletedLessons ?? [];
          // });
        } else if (state is LessonProgressUpdateState) {
          mdlLessonProgress = state.mdlLessonProgress;
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: Column(
            children: [
              _headerView(),
              Expanded(
                child: isUserLoggedIn
                    ? ((mdlCourseList?.length ?? 0) == 0)
                        ? state is MCShowLoadingState
                            ? const SizedBox.shrink()
                            : Center(
                                child: Text(
                                  'No data found',
                                  style: AppFontStyle.poppinsRegular.copyWith(
                                    fontWeight: FontWeight.w100,
                                    fontSize: 20.sp,
                                    color: AppColors.appBgColor,
                                  ),
                                ),
                              )
                        : SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: 30.w,
                                right: 30.w,
                                top: 22.h,
                              ),
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.only(top: 15.h),
                                itemCount: mdlCourseList?.length,
                                itemBuilder: (BuildContext context, int index) {
                                  MDLCourseList? mdlCourseData =
                                      mdlCourseList?[index];
                                  if (mdlCourseData?.count == null) {
                                    return const SizedBox.shrink();
                                  }
                                  return Column(
                                    children: [
                                      _countRow(mdlCourseData),
                                      ListView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        padding: EdgeInsets.only(top: 15.h),
                                        itemCount:
                                            mdlCourseData?.mdlCourse?.length ??
                                                0,
                                        itemBuilder: (BuildContext context,
                                            int subIndex) {
                                          AgCategoriesNode? data = mdlCourseData
                                              ?.mdlCourse?[subIndex];
                                          return CourseTile(
                                            isMyCourse: true,
                                            mdlCourse: data,
                                            studentProgress: mdlCourseData
                                                    ?.studentProgress ??
                                                0,
                                            onTap: () {
                                              Get.toNamed(
                                                Routes.courseDetailPage,
                                                arguments: [
                                                  mdlCourseList![index]
                                                      .mdlCourse![subIndex]
                                                      .id
                                                      .toString(),
                                                  mdlCourseList![index]
                                                      .studentProgress,
                                                  mdlCourseList![index]
                                                      .studentCompletedLessons
                                                      ?.nodes
                                                      ?.toList(),
                                                  true,
                                                ],
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Please login to view your courses.',
                            style: AppFontStyle.poppinsRegular.copyWith(
                              fontWeight: FontWeight.w100,
                              fontSize: 20.sp,
                              color: AppColors.appBgColor,
                            ),
                          ),
                          SizedBox(height: 20.w),
                          customButton(
                            width: 200.w,
                            onTap: () {
                              hideKeyboard(context);
                              Get.offAllNamed(Routes.login);
                              StorageManager.instance.setBool(
                                  LocalStorageKeys.prefGuestLogin, false);
                              StorageManager.instance.clear();
                            },
                            buttonText: LanguageKey.loginNow.tr,
                          ),
                        ],
                      ),
              ),
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.h),
                  child: AGBannerAd(adSize: AdSize.mediumRectangle),
                ),
              ),
              SizedBox(height: 80.h)
            ],
          ),
        );
      },
    );
  }
  Widget _headerView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        customHeader(),
        Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 24.h),
            child: AGBannerAd(adSize: AdSize.banner),
          ),
        ),
      ],
    );
  }

  Widget _countRow(MDLCourseList? mdlCourseList) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          mdlCourseList?.title ?? '',
          textAlign: TextAlign.start,
          style: AppFontStyle.poppinsMedium.copyWith(
            color: AppColors.appBgColor,
          ),
        ),
        Container(
          width: 28.w,
          height: 20.h,
          margin: EdgeInsets.only(left: 5.w),
          decoration: BoxDecoration(
            color: AppColors.countBoxColor,
            borderRadius: BorderRadius.all(
              Radius.circular(43.r),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            mdlCourseList?.count.toString() ?? "",
            style: AppFontStyle.poppinsMedium.copyWith(
              color: AppColors.white,
              fontSize: 13.sp,
            ),
          ),
        ),
      ],
    );
  }
}
