import 'package:azan_guru_mobile/common/util.dart';
import 'package:azan_guru_mobile/constant/app_assets.dart';
import 'package:azan_guru_mobile/constant/app_colors.dart';
import 'package:azan_guru_mobile/constant/enum.dart';
import 'package:azan_guru_mobile/constant/font_style.dart';
import 'package:azan_guru_mobile/route/app_routes.dart';
import 'package:azan_guru_mobile/ui/help_module/ask_live_teacher_dialog.dart';
import 'package:azan_guru_mobile/ui/model/mdl_help.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  List<MDLHelp> mdlHelp = [
    MDLHelp(
      title: 'Any Doubt',
      image: AssetImages.icHelp,
      type: HelpType.questionAnswer,
    ),
    MDLHelp(
      title: 'Share your Feedback/Problems',
      image: AssetImages.icMessage,
      type: HelpType.message,
    ),
    MDLHelp(
      title: 'Ask to Live Teacher',
      image: AssetImages.icChatLive,
      type: HelpType.liveTeacher,
    ),
  ];
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLightWhitColor,
      body: Column(
        children: [
          _headerView(),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                left: 32.w,
                right: 32.w,
                top: 35.h,
              ),
              itemCount: mdlHelp.length,
              itemBuilder: (BuildContext context, int index) {
                MDLHelp data = mdlHelp[index];
                if (data.type == HelpType.liveTeacher) {
                  return AskLiveTeacherDialog(
                    data: data,
                    isSupportView: true,
                    widget: askLiveTeachetTile(data),
                  );
                } else {
                  return _listTile(data);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget askLiveTeachetTile(MDLHelp? data) {
    return Container(
      width: Get.width,
      height: 110.h,
      clipBehavior: Clip.hardEdge,
      margin: EdgeInsets.only(bottom: 18.h),
      decoration: ShapeDecoration(
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        shadows: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 6.r,
            offset: const Offset(0, 9),
            spreadRadius: 0,
          )
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 25.w),
      child: Row(
        children: [
          SvgPicture.asset(data?.image ?? ""),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Text(
                data?.title ?? '',
                style: AppFontStyle.poppinsSemiBold.copyWith(
                  fontSize: 16.w,
                  color: AppColors.appBgColor,
                ),
              ),
            ),
          ),
          SvgPicture.asset(AssetImages.icArrowForwordHelp),
        ],
      ),
    );
  }

  Widget _headerView() {
    return customTopContainer(
      bgImage: AssetImages.icBgMyCourse,
      height: 280.h,
      insideChild: Column(
        children: [
          customAppBar(
            suffixIcons: [
              customIcon(
                iconColor: AppColors.white,
                onClick: () {
                  Get.toNamed(Routes.menuPage);
                },
                icon: AssetImages.icMenu,
              ),
              Padding(
                padding: EdgeInsets.only(left: 20.w, right: 20.w),
                child: customIcon(
                  onClick: () {
                    Get.toNamed(Routes.notificationPage);
                  },
                  icon: AssetImages.icNotification,
                  iconColor: AppColors.white,
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 18.h,
              bottom: 30.h,
              left: 40.w,
              right: 40.w,
            ),
            child: Text(
              'Support Desk',
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
        ],
      ),
    );
  }

  Widget _listTile(MDLHelp data) {
    return InkWell(
      focusColor: Colors.transparent,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      onTap: () {
        switch (data.type) {
          case HelpType.questionAnswer:
            Get.toNamed(Routes.questionAnswerPage);
            break;
          case HelpType.message:
            Get.toNamed(Routes.questionMessagePage);
            break;
          default:
            break;
        }
      },
      child: Container(
        width: Get.width,
        height: 110.h,
        clipBehavior: Clip.hardEdge,
        margin: EdgeInsets.only(bottom: 18.h),
        decoration: ShapeDecoration(
          color: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          shadows: [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 6.r,
              offset: const Offset(0, 9),
              spreadRadius: 0,
            )
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 25.w),
        child: Row(
          children: [
            SvgPicture.asset(
              data.image ?? "",
              width: 50.w,
              height: 50.w,
              colorFilter: const ColorFilter.mode(
                AppColors.black,
                BlendMode.srcIn,
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Text(
                  data.title ?? '',
                  style: AppFontStyle.poppinsSemiBold.copyWith(
                    fontSize: 16.w,
                    color: AppColors.appBgColor,
                  ),
                ),
              ),
            ),
            SvgPicture.asset(AssetImages.icArrowForwordHelp),
          ],
        ),
      ),
    );
  }
}
