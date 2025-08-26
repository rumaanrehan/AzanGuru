import 'package:azan_guru_mobile/common/custom_button.dart';
import 'package:azan_guru_mobile/common/util.dart';
import 'package:azan_guru_mobile/constant/app_assets.dart';
import 'package:azan_guru_mobile/constant/app_colors.dart';
import 'package:azan_guru_mobile/constant/font_style.dart';
import 'package:azan_guru_mobile/route/app_routes.dart';
import 'package:azan_guru_mobile/ui/model/mdl_choose_question.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class CourseSuggestionTile extends StatefulWidget {
  const CourseSuggestionTile({super.key});

  @override
  State<CourseSuggestionTile> createState() => _CourseSuggestionTileState();
}

class _CourseSuggestionTileState extends State<CourseSuggestionTile> {
  ShowCourseNode? course;
  // List<String> options = [
  //   'Understanding of Arabic Alphabets',
  //   'Avoid Common Mistakes',
  //   'Proper pronunciation of Arabic letters and words'
  // ];

  @override
  void initState() {
    if (Get.arguments is ShowCourseNode?) {
      course = Get.arguments as ShowCourseNode?;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: _backgroundView(),
          ),
          Padding(
            padding: EdgeInsets.only(left: 45.w, right: 45.w, top: 110.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Congratulations!',
                  textAlign: TextAlign.center,
                  style: AppFontStyle.poppinsMedium.copyWith(
                    fontSize: 30.sp,
                    color: AppColors.white,
                  ),
                ),
                Expanded(
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Container(
                        padding: EdgeInsets.only(
                          top: 60.h,
                          bottom: 25.h,
                          left: 32.w,
                          right: 32.w,
                        ),
                        margin: EdgeInsets.only(top: 70.h),
                        height: Get.height * 0.88.h,
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
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5.w),
                          child: Column(
                            children: [
                              Expanded(
                                child: SingleChildScrollView(
                                  physics: const BouncingScrollPhysics(),
                                  child: Column(
                                    children: [
                                      Text(
                                        course?.courseTypeImage
                                                ?.chooseCourseInfo ??
                                            'We have found a perfect course for you!',
                                        textAlign: TextAlign.center,
                                        style:
                                            AppFontStyle.dmSansMedium.copyWith(
                                          fontSize: 16.sp,
                                          color: AppColors.cardTextColor,
                                        ),
                                      ),
                                      Container(
                                        width: 85.w,
                                        height: 85.h,
                                        clipBehavior: Clip.hardEdge,
                                        margin: EdgeInsets.only(
                                          top: 15.h,
                                          bottom: 15.h,
                                        ),
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                        ),
                                        child: Image.network(
                                          course
                                                  ?.courseTypeImage
                                                  ?.courseCategoryImage
                                                  ?.node
                                                  ?.mediaItemUrl ??
                                              '',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Text(
                                        course?.name ?? '',
                                        textAlign: TextAlign.center,
                                        style: AppFontStyle.dmSansBold.copyWith(
                                          color: AppColors.cardTextColor,
                                          fontSize: 20.sp,
                                        ),
                                      ),
                                      SizedBox(height: 5.h),
                                      Text(
                                        course?.description ?? '',
                                        textAlign: TextAlign.left,
                                        style: AppFontStyle.poppinsRegular
                                            .copyWith(
                                          color: AppColors.appBgColor,
                                          fontSize: 16.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              customButton(
                                onTap: () {
                                  Get.offAndToNamed(
                                    Routes.courseDetailPage,
                                    arguments: course?.id,
                                  );
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
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 25,
                        child: Container(
                          width: 100.w,
                          height: 95.h,
                          clipBehavior: Clip.hardEdge,
                          decoration: BoxDecoration(
                            color: AppColors.congratCardColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        child: SizedBox(
                          width: 100.w,
                          height: 100.h,
                          child: Image.asset(
                            AssetImages.icBook,
                            fit: BoxFit.scaleDown,
                          ),
                        ),
                      ),
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

  Future<void> launchUrlInBrowser(String url) async {
    var isValidUrl = await canLaunchUrl(Uri.parse(url));
    if (isValidUrl) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      Get.toNamed(Routes.agWebViewPage, arguments: url);
    }
  }

  Widget _backgroundView() {
    return customTopContainer(
      bgImage: AssetImages.icBgCongratulation,
      height: 580.h,
      radius: 25.r,
      insideChild: customAppBar(
        showPrefixIcon: true,
        onClick: () {
          Get.back();
        },
      ),
    );
  }
}
