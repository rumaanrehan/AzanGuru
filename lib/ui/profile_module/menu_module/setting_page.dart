import 'package:azan_guru_mobile/common/util.dart';
import 'package:azan_guru_mobile/constant/app_assets.dart';
import 'package:azan_guru_mobile/constant/app_colors.dart';
import 'package:azan_guru_mobile/constant/font_style.dart';
import 'package:azan_guru_mobile/route/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool turnOnOffNotification = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: customAppBar(
        showTitle: true,
        centerTitle: true,
        backgroundColor: AppColors.appBgColor,
        title: 'Setting',
        showPrefixIcon: true,
        onClick: () {
          Get.back();
        },
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 25.h, horizontal: 20.w),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    "Notification show/hide",
                    style: AppFontStyle.poppinsMedium.copyWith(
                      fontSize: 18.sp,
                      color: AppColors.black,
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),
                Switch(
                  value: turnOnOffNotification,
                  activeTrackColor: AppColors.green,
                  inactiveTrackColor: AppColors.white,
                  onChanged: (value) {
                    turnOnOffNotification = value;
                    setState(() {});
                  },
                ),
              ],
            ),
            const Divider(),
            GestureDetector(
              onTap: () {
                Get.toNamed(Routes.deleteAccountDetailPage);
              },
              child: SizedBox(
                height: 50.h,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        "Delete Account",
                        style: AppFontStyle.poppinsMedium.copyWith(
                          fontSize: 18.sp,
                          color: AppColors.appBgColor,
                        ),
                        textAlign: TextAlign.start,
                      ),
                    ),
                    SizedBox(
                      height: 18.h,
                      width: 25.w,
                      child: SvgPicture.asset(
                        AssetImages.icArrowForword,
                        colorFilter: ColorFilter.mode(
                          AppColors.appBgColor,
                          BlendMode.srcIn,
                        ),
                        height: 20.h,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
