import 'dart:io';

import 'package:azan_guru_mobile/bloc/home_bloc/home_bloc.dart';
import 'package:azan_guru_mobile/common/custom_button.dart';
import 'package:azan_guru_mobile/common/util.dart';
import 'package:azan_guru_mobile/constant/app_assets.dart';
import 'package:azan_guru_mobile/constant/app_colors.dart';
import 'package:azan_guru_mobile/constant/font_style.dart';
import 'package:azan_guru_mobile/route/app_routes.dart';
import 'package:azan_guru_mobile/ui/common/loader.dart';
import 'package:azan_guru_mobile/ui/common/course_tile.dart';
import 'package:azan_guru_mobile/ui/model/ag_categories_data.dart';
import 'package:azan_guru_mobile/ui/model/mdl_course.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:azan_guru_mobile/ui/model/user.dart';
import 'package:azan_guru_mobile/common/loader_helper.dart';
import 'package:azan_guru_mobile/ui/common/ads/ag_banner_ad.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';



class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  List<MDLCourseList> adultCourses = [];
  List<MDLCourseList> kidsCourses = [];
  late TabController _tabController;
  HomeBloc homeBloc = HomeBloc();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    homeBloc.add(GetCategoriesEvent());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<HomeBloc, HomeState>(
        bloc: homeBloc,
        listener: (context, state) {
          if (state is HomeShowLoadingState) {
            if (!AGLoader.isShown) AGLoader.show(context);
          } else if (state is HomeHideLoadingState) {
            if (AGLoader.isShown) AGLoader.hide();
          } else if (state is GetCategoriesState) {
            setState(() {
              adultCourses.clear();
              kidsCourses.clear();
              (state.nodes ?? []).forEach((courseList) {
                final title = (courseList.title ?? '').toLowerCase();
                if (title.contains('kids')) {
                  kidsCourses.add(courseList);
                } else if (title.contains('adult')) {
                  adultCourses.add(courseList);
                }
              });
            });
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 90.h),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildIntroContent(),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: TabBar(
                          controller: _tabController,
                          labelColor: Colors.black,
                          unselectedLabelColor: Colors.grey,
                          indicatorColor: AppColors.buttonColor,
                          tabs: const [
                            Tab(text: 'Free Courses'),
                            Tab(text: 'Paid Courses'),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 500.h,
                        child: TabBarView(
                          controller: _tabController,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 24.w),
                              child: _courseListView(adultCourses),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 24.w),
                              child: _courseListView(kidsCourses),
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
                      SizedBox(height: 80.h),
                    ],
                  ),
                ),
              ),

              Container(
                color: const Color(0xFF4D8974),
                padding: EdgeInsets.only(
                  left: 20.w,
                  right: 20.w,
                  top: 46.h,
                  bottom: 12.h,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      'assets/images/ag_header_logo.png',
                      width: 150.w,
                    ),
                    Row(
                      children: [
                        customIcon(
                          iconColor: AppColors.white,
                          onClick: () => Get.toNamed(Routes.menuPage),
                          icon: AssetImages.icMenu,
                        ),
                        SizedBox(width: 20.w),
                        customIcon(
                          onClick: () => Get.toNamed(Routes.notificationPage),
                          icon: AssetImages.icNotification,
                          iconColor: AppColors.white,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildIntroContent() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 30.h),
          Align(
            alignment: Alignment.center,
            child: Text(
              "Assalamualaikum!",
              style: AppFontStyle.poppinsSemiBold.copyWith(fontSize: 20.5.sp),
            ),
          ),
          SizedBox(height: 20.h),
          GestureDetector(
            onTap: () async {
              showGlobalLoader();
              await Future.delayed(const Duration(milliseconds: 100));
              await Get.toNamed('/courseDetailPage', arguments: 'dGVybToxMw==');
              hideGlobalLoader();
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18.r),
              child: Image.asset(
                'assets/images/welcome.png',
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 24.h),
          _resourceTileWithIcon(
            title: "Listen Quran for Free",
            iconPath: 'assets/images/listen.png',
            onTap: () => Get.toNamed(Routes.listenQuran),
          ),
          SizedBox(height: 10.h),
          _resourceTileWithIcon(
            title: "Watch QTube — Free Quran Videos",
            iconPath: 'assets/images/watch.png',
            onTap: () => Get.toNamed(Routes.questionAnswerPage),
          ),
          SizedBox(height: 10.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
            decoration: BoxDecoration(
              color: const Color(0xFFddece7),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("🧠 Test Your Quran Knowledge",
                    style: AppFontStyle.poppinsSemiBold.copyWith(fontSize: 16.sp)),
                SizedBox(height: 6.h),
                Text(
                  "Get a personalized course recommendation in 60 seconds.",
                  style: AppFontStyle.poppinsRegular.copyWith(fontSize: 13.sp),
                ),
                SizedBox(height: 14.h),
                customButton(
                  boxColor: const Color(0xFF4D8974),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  onTap: () => Get.toNamed(Routes.chooseCoursePage),
                  child: Center(
                    child: Text(
                      "Test My Quran Knowledge →",
                      style: AppFontStyle.poppinsBold.copyWith(
                        color: Colors.white,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24.h),
              child: AGBannerAd(adSize: AdSize.mediumRectangle),
            ),
          ),
          SizedBox(height: 16.h),
          Align(
            alignment: Alignment.center,
            child: Text(
              "Recommended Courses",
              style: AppFontStyle.poppinsSemiBold.copyWith(fontSize: 18.sp),
            ),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  Widget _resourceTileWithIcon({
    required String title,
    String? subtitle,
    required String iconPath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Image.asset(iconPath, width: 32.w, height: 32.h),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppFontStyle.poppinsSemiBold.copyWith(fontSize: 14.5.sp),
                  ),
                  if (subtitle != null)
                    Padding(
                      padding: EdgeInsets.only(top: 4.h),
                      child: Text(
                        subtitle,
                        style: AppFontStyle.poppinsRegular.copyWith(
                          fontSize: 12.5.sp,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.black45, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _courseListView(List<MDLCourseList> courseGroups) {
    if (courseGroups.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.only(top: 10.h),
          child: Text(
            'No courses available',
            style: AppFontStyle.poppinsMedium.copyWith(fontSize: 16.sp),
          ),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: courseGroups.length,
      itemBuilder: (BuildContext context, int index) {
        final group = courseGroups[index];
        return Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  group.title ?? '',
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
                    borderRadius: BorderRadius.all(Radius.circular(43.r)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    group.count.toString(),
                    style: AppFontStyle.poppinsMedium.copyWith(
                      color: AppColors.white,
                      fontSize: 13.sp,
                    ),
                  ),
                ),
              ],
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.only(top: 15.h),
              itemCount: group.mdlCourse?.length ?? 0,
              itemBuilder: (BuildContext context, int subIndex) {
                final course = group.mdlCourse?[subIndex];
                return CourseTile(
                  mdlCourse: course,
                  onTap: () {
                    showErrorDialog(
                      context,
                      course?.name ?? '',
                      btnSecond: "Help me to choose a course",
                      btnFirst: 'I am sure about the course',
                      image: course?.courseTypeImage?.courseCategoryImage?.node?.mediaItemUrl ?? '',
                      handler: (index) {
                        Get.back();
                        if (index == 1) {
                          Get.toNamed(Routes.chooseCoursePage);
                        } else {
                          Get.toNamed(Routes.courseDetailPage, arguments: course?.id);
                        }
                      },
                    );
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }
}
