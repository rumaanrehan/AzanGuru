import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ROUTES
import 'package:azan_guru_mobile/route/app_routes.dart';

// STYLE & COMMON
import 'package:azan_guru_mobile/constant/app_colors.dart';
import 'package:azan_guru_mobile/constant/font_style.dart';
import 'package:azan_guru_mobile/common/custom_button.dart';

// TARGET SCREEN & ARGS
import 'package:azan_guru_mobile/ui/course_module/course_screen.dart';
import 'package:marquee/marquee.dart';


class CourseSelectionScreen extends StatelessWidget {
  const CourseSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          // Header bar (match HomePage)
          Container(
            color: const Color(0xFF4D8974),
            padding: EdgeInsets.only(
              left: 20.w,
              right: 20.w,
              top: 46.h,
              bottom: 12.h,
            ),
            child: SizedBox(
              height: 48.h,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Left group: Back + Home
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        _headerIcon(
                          context: context,
                          icon: Icons.arrow_back_ios_new_rounded,
                          onTap: () => Get.back(),
                        ),
                        SizedBox(width: 16.w),

                        // Home
                        _headerIcon(
                          context: context,
                          icon: Icons.home_rounded,
                          onTap: () => Get.offAllNamed(Routes.tabBarPage),
                        ),
                      ],
                    ),
                  ),

                  // Right: Menu (=) using your customIcon + asset
                  Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                        children: [

                          Text(
                            "﷽",
                            textAlign: TextAlign.right,
                            style: AppFontStyle.dmSansRegular.copyWith(
                              fontSize: 22.5.sp, // larger
                              color: Colors.white,
                            ),
                          ),

                          SizedBox(width: 16.w),

                          _headerIcon(
                            context: context,
                            icon: Icons.menu_rounded,
                            onTap: () => Get.toNamed(Routes.menuPage),
                          ),
                        ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Body below header
          Padding(
            padding: EdgeInsets.only(top: 90.h),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 26.h),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 24.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [

                          // Micro-Benefits Strip
                          Container(
                            width: double.infinity,
                            height: 40.h, // fix height for marquee
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4D8974).withOpacity(0.08),
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(
                                color: const Color(0xFF4D8974).withOpacity(0.25),
                              ),
                            ),
                            child: Marquee(
                              //text: "•   Live Tutors   •   Flexible Scheduling   •   Homework & Feedback   •   Progress Tracking",
                              text: "خَيْرُكُمْ مَنْ تَعَلَّمَ الْقُرْآنَ وَعَلَّمَهُ •  The best of you is the one who learns the Quran and teaches it • ",
                              style: AppFontStyle.poppinsMedium.copyWith(
                                fontSize: 14.sp,
                                color: Colors.black87,
                              ),
                              scrollAxis: Axis.horizontal,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              blankSpace: 10.w,
                              velocity: 30.0, // speed of scroll
                              pauseAfterRound: const Duration(seconds: 1),
                              startPadding: 10.0,
                              accelerationDuration: const Duration(seconds: 1),
                              accelerationCurve: Curves.linear,
                              decelerationDuration: const Duration(milliseconds: 500),
                              decelerationCurve: Curves.easeOut,
                            ),
                          ),

                          SizedBox(height: 18.h),
                          // Headline
                          Text(
                            "Learn Qur’an at any age.",
                            textAlign: TextAlign.left,
                            style: AppFontStyle.poppinsSemiBold.copyWith(
                              fontSize: 22.5.sp,
                              height: 1.4,
                            ),
                          ),

                        ],
                      ),
                    ),

                    // Big heading



                    // Adults tile (matches your card style)
                    _OptionTile(
                      icon: Icons.person_rounded,
                      title: "For Me (Adult)",
                      subtitle:
                      "Structured lessons, live support and homework for consistent progress.",
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

                    // Kids tile
                    _OptionTile(
                      icon: Icons.child_care_rounded,
                      title: "For My Kids",
                      subtitle:
                      "Fun, bite-sized lessons with badges, homework and live help.",
                      onTap: () {
                        Get.toNamed(
                          Routes.course,
                          arguments: CourseScreenArgs.kids(),
                        );
                      },
                      primaryCtaLabel: "Take me to Kids Course",
                    ),

                    SizedBox(height: 24.h),

                    // OR divider
                    _orDivider(),

                    SizedBox(height: 16.h),

                    // Secondary action (kept for parity with your UX)
                    TextButton(
                      onPressed: () => Get.offAllNamed(Routes.homePage),
                      child: Text(
                        "Skip for now",
                        style: AppFontStyle.poppinsMedium.copyWith(
                          color: AppColors.appBgColor,
                          fontSize: 14.5.sp,
                        ),
                      ),
                    ),

                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerIcon({
    required BuildContext context,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 38.w,
        height: 38.w,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.white, size: 20.sp),
      ),
    );
  }

  Widget _orDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.black12, thickness: 1)),
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
        Expanded(child: Divider(color: Colors.black12, thickness: 1)),
      ],
    );
  }
}

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
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
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
        children: [
          Row(
            children: [
              // Leading icon circle (similar feel to resource tiles)
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
                    fontSize: 17.sp, // larger
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
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              subtitle,
              style: AppFontStyle.poppinsRegular.copyWith(
                fontSize: 13.5.sp, // larger
                color: Colors.black.withOpacity(0.70),
                height: 1.35,
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // Primary CTA (matches your customButton usage)
          customButton(
            boxColor: outlined ? Colors.white : const Color(0xFF4D8974),
            borderColor: outlined ? const Color(0xFF4D8974) : Colors.white,
            showBorder: outlined,
            padding: EdgeInsets.symmetric(vertical: 12.h),
            onTap: onTap,
            child: Center(
              child: Text(
                primaryCtaLabel,
                style: AppFontStyle.poppinsBold.copyWith(
                  color: outlined ? const Color(0xFF4D8974) : Colors.white,
                  fontSize: 15.sp, // larger
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
