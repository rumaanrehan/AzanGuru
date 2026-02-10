import 'package:azan_guru_mobile/common/custom_button.dart';
import 'package:azan_guru_mobile/common/util.dart';
import 'package:azan_guru_mobile/constant/app_assets.dart';
import 'package:azan_guru_mobile/constant/app_colors.dart';
import 'package:azan_guru_mobile/constant/font_style.dart';
import 'package:azan_guru_mobile/route/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class CourseCompleteSuccessPage extends StatefulWidget {
  const CourseCompleteSuccessPage({super.key});

  @override
  State<CourseCompleteSuccessPage> createState() =>
      _CourseCompleteSuccessState();
}

class _CourseCompleteSuccessState extends State<CourseCompleteSuccessPage> {
  String url =
      "${baseUrl}certificate-request?student_id=${user?.databaseId.toString()}'";

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
                  'Alhamdu Lillah',
                  textAlign: TextAlign.center,
                  style: AppFontStyle.poppinsMedium.copyWith(
                    fontSize: 30.sp,
                    color: AppColors.white,
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.only(
                        top: 60.h, bottom: 25.h, left: 20.w, right: 20.w),
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
                              child: noCourse(),
                            ),
                          ),
                          customButton(
                            onTap: () {
                              // Get.toNamed(Routes.agWebViewPage, arguments: url);
                              launchUrlInExternalBrowser(url);
                            },
                            boxColor: AppColors.alertButtonColor,
                            child: Text(
                              ("Get Certificate").toUpperCase(),
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
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

  Widget noCourse() {
    return Column(
      children: [
        Text(
          'Congratulations on completing your Quran course!',
          textAlign: TextAlign.center,
          style: AppFontStyle.dmSansBold.copyWith(
              fontSize: 18.sp,
              color: AppColors.alertButtonBlackColor,
              fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10.h),
        Text(
          "This achievement is a testament to your dedication and commitment to learning. Remember, knowledge is a journey that never ends.",
          style: AppFontStyle.dmSansRegular.copyWith(
            fontSize: 18.sp,
            color: AppColors.alertButtonBlackColor,
          ),
        ),
        SizedBox(height: 10.h),
        Text(
          "Keep continue reciting in your own Mushaf (Physical copy). If you miss recitation you may loose access to Quran and this won't be better for both world",
          style: AppFontStyle.dmSansRegular.copyWith(
            fontSize: 18.sp,
            color: AppColors.alertButtonBlackColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10.h),
        RichText(
          textAlign: TextAlign.start,
          text: TextSpan(
            children: [
              TextSpan(
                text: "Note ",
                style: AppFontStyle.dmSansRegular.copyWith(
                  fontSize: 18.sp,
                  color: AppColors.alertButtonBlackColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text:
                    ": Your Certificate will be delivered to you after Teacher assessment.",
                style: AppFontStyle.dmSansRegular.copyWith(
                  fontSize: 18.sp,
                  color: AppColors.alertButtonBlackColor,
                ),
                // recognizer: TapGestureRecognizer()
                //   ..onTap = () {
                //     Get.toNamed(Routes.agWebViewPage, arguments: url);
                //   },
              ),
            ],
          ),
        ),
        SizedBox(height: 10.h),
        Text(
          "Kindly, Fill this form to get your certificate.",
          style: AppFontStyle.dmSansRegular.copyWith(
            fontSize: 18.sp,
            color: AppColors.alertButtonBlackColor,
          ),
        ),
        SizedBox(height: 20.h),
      ],
    );
  }
}
