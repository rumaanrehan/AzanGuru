import 'dart:io';

import 'package:azan_guru_mobile/bloc/home_bloc/home_bloc.dart';
import 'package:azan_guru_mobile/bloc/my_course_bloc/my_course_bloc.dart';
import 'package:azan_guru_mobile/common/custom_button.dart';
import 'package:azan_guru_mobile/common/util.dart';
import 'package:azan_guru_mobile/constant/app_colors.dart';
import 'package:azan_guru_mobile/constant/font_style.dart';
import 'package:azan_guru_mobile/route/app_routes.dart';
import 'package:azan_guru_mobile/service/local_storage/local_storage_keys.dart';
import 'package:azan_guru_mobile/service/local_storage/storage_manager.dart';
import 'package:azan_guru_mobile/ui/common/loader.dart';
import 'package:azan_guru_mobile/ui/common/ag_header_bar.dart';
//import 'package:azan_guru_mobile/ui/common/course_tile.dart';
//import 'package:azan_guru_mobile/ui/model/ag_categories_data.dart';
//import 'package:azan_guru_mobile/ui/model/mdl_course.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
//import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:azan_guru_mobile/ui/model/user.dart';
import 'package:azan_guru_mobile/common/loader_helper.dart';
import 'package:azan_guru_mobile/ui/common/ads/ag_banner_ad.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:marquee/marquee.dart';
import 'package:azan_guru_mobile/ui/course_module/course_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Silent fetch in background for HomePage
    if (user != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<MyCourseBloc>().add(GetMyCourseEvent());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 90.h),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildIntroContent(),

                  // Course Selection Tiles
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 24.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              orDivider(),
                              SizedBox(height: 28.h),
                              Text(
                                "New Here? Buy Course!",
                                textAlign: TextAlign.center,
                                style: AppFontStyle.poppinsSemiBold.copyWith(
                                  fontSize: 20.sp,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 28.h),
                              _OptionTile(
                                icon: Icons.person_rounded,
                                title: "For Me (Adult)",
                                subtitle:
                                    "Structured lessons, homework for consistent progress and Weekly Live Support.",
                                onTap: () {
                                  Get.toNamed(
                                    Routes.course,
                                    arguments: CourseScreenArgs.adults(),
                                  );
                                },
                                outlined: true,
                                primaryCtaLabel: "Take me to Adults Course",
                              ),
                              SizedBox(height: 16.h),
                              _OptionTile(
                                icon: Icons.child_care_rounded,
                                title: "For My Kids",
                                subtitle:
                                    "Fun, bite-sized lessons with badges, homework and Daily Live Classes.",
                                onTap: () {
                                  Get.toNamed(
                                    Routes.course,
                                    arguments: CourseScreenArgs.kids(),
                                  );
                                },
                                primaryCtaLabel: "Take me to Kids Course",
                              ),
                              SizedBox(height: 24.h),
                            ],
                          ),
                        ),
                        SizedBox(height: 40.h),
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

          // Header bar - pinned to top of screen
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AgHeaderBar(
              onMenuTap: () => Get.toNamed(Routes.menuPage),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccessPurchasedCourseBox() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: AppColors.headerColor, // Primary green background
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text("📖 Access Your Purchased Course",
                  style: AppFontStyle.poppinsSemiBold.copyWith(
                    fontSize: 16.sp,
                    color: Colors.white,
                  )),
              const Spacer(),
              const Icon(Icons.star_rounded,
                  color: Color(0xFFFFD700), size: 20),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            "Begin your journey! Go to 'My Courses' and start learning today.",
            style: AppFontStyle.poppinsRegular.copyWith(
              fontSize: 13.5.sp,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          SizedBox(height: 18.h),
          customButton(
            boxColor: const Color(0xFFddece7), // Reversed: light green CTA
            padding: EdgeInsets.symmetric(vertical: 12.h),
            onTap: () => Get.offAllNamed(Routes.tabBarPage, arguments: 1),
            child: Center(
              child: Text(
                "Go to My Courses →",
                style: AppFontStyle.poppinsBold.copyWith(
                  //color: AppColors.headerColor, // Dark green text in light button
                  fontSize: 14.5.sp,
                ),
              ),
            ),
          ),
        ],
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
              (user?.firstName?.trim().isNotEmpty ?? false)
                  ? "Assalamualaikum, ${user!.firstName!.trim()}!"
                  : "Assalamualaikum!",
              style: AppFontStyle.poppinsSemiBold.copyWith(fontSize: 20.5.sp),
            ),
          ),
          SizedBox(height: 20.h),

          // Micro-benefits Marquee
          Container(
            width: double.infinity,
            height: 40.h,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F8F6),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: const Color(0xFFE6EFEA)),
            ),
            child: Marquee(
              text:
                  "خَيْرُكُمْ مَنْ تَعَلَّمَ الْقُرْآنَ وَعَلَّمَهُ • The best of you is the one who learns the Quran and teaches it • ",
              style: AppFontStyle.poppinsMedium.copyWith(
                fontSize: 14.sp,
                color: Colors.black87,
              ),
              scrollAxis: Axis.horizontal,
              crossAxisAlignment: CrossAxisAlignment.center,
              blankSpace: 10.w,
              velocity: 30.0,
              pauseAfterRound: const Duration(seconds: 1),
              startPadding: 10.0,
              accelerationDuration: const Duration(seconds: 1),
              accelerationCurve: Curves.linear,
              decelerationDuration: const Duration(milliseconds: 500),
              decelerationCurve: Curves.easeOut,
            ),
          ),

          SizedBox(height: 28.h),

          // Knowledge test CTA
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
                    style:
                        AppFontStyle.poppinsSemiBold.copyWith(fontSize: 16.sp)),
                SizedBox(height: 6.h),
                Text(
                  "Get a personalized course recommendation in 60 seconds.",
                  style: AppFontStyle.poppinsRegular.copyWith(fontSize: 13.sp),
                ),
                SizedBox(height: 14.h),
                customButton(
                  boxColor: AppColors.headerColor,
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

          SizedBox(height: 20.h),

          BlocBuilder<MyCourseBloc, MyCourseState>(
            builder: (context, state) {
              if (state is GetMyCourseState &&
                  (state.nodes?.isNotEmpty ?? false)) {
                return Column(
                  children: [
                    _buildAccessPurchasedCourseBox(),
                    SizedBox(height: 20.h),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // comment out listen quran and watch qtube as per user request
          // _resourceTileWithIcon(
          //   title: "Listen Quran for Free",
          //   iconPath: 'assets/images/listen.png',
          //   onTap: () => Get.toNamed(Routes.listenQuran),
          // ),
          // SizedBox(height: 10.h),
          // _resourceTileWithIcon(
          //   title: "Watch QTube — Free Quran Videos",
          //   iconPath: 'assets/images/watch.png',
          //   onTap: () => Get.toNamed(Routes.questionAnswerPage),
          // ),
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
          boxShadow: const [
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
                    style: AppFontStyle.poppinsSemiBold
                        .copyWith(fontSize: 14.5.sp),
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
            const Icon(Icons.chevron_right_rounded,
                color: Colors.black45, size: 24),
          ],
        ),
      ),
    );
  }
}

// ===== Helpers OUTSIDE the State class =====

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.primaryCtaLabel,
    this.outlined = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final String primaryCtaLabel;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16.r);

    return Material(
      color: Colors.transparent,
      borderRadius: radius, // ripple clip
      child: InkWell(
        onTap: onTap, // whole tile is tappable
        borderRadius: radius,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: radius,
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: outlined
                  ? AppColors.appBgColor.withOpacity(0.15)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24.r,
                    backgroundColor: AppColors.appBgColor.withOpacity(0.10),
                    child: Icon(
                      icon,
                      size: 22.sp,
                      color: AppColors.appBgColor,
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Text(
                      title,
                      style: AppFontStyle.poppinsSemiBold.copyWith(
                        fontSize: 17.sp,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.black45,
                    size: 26.sp,
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Text(
                subtitle,
                style: AppFontStyle.poppinsRegular.copyWith(
                  fontSize: 13.5.sp,
                  color: Colors.black.withOpacity(0.70),
                  height: 1.35,
                ),
              ),
              SizedBox(height: 16.h),

              // Primary CTA — trigger same action
              // If your customButton ignores boxColor when showBorder=true,
              // this wrapper keeps the visual fill consistent.
              Container(
                decoration: BoxDecoration(
                  color: outlined ? Colors.white : AppColors.headerColor,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: customButton(
                  onTap: onTap, // <<< important
                  boxColor: outlined ? Colors.white : AppColors.headerColor,
                  borderColor: outlined ? AppColors.headerColor : Colors.white,
                  showBorder: outlined,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  child: Center(
                    child: Text(
                      primaryCtaLabel,
                      style: AppFontStyle.poppinsBold.copyWith(
                        color: outlined ? AppColors.headerColor : Colors.white,
                        fontSize: 15.sp,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget orDivider() {
  return Row(
    children: [
      const Expanded(child: Divider(color: Colors.black12, thickness: 1)),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        child: Text(
          "OR",
          style: AppFontStyle.poppinsMedium.copyWith(
            color: Colors.black54,
            fontSize: 13.5.sp,
          ),
        ),
      ),
      const Expanded(child: Divider(color: Colors.black12, thickness: 1)),
    ],
  );
}
