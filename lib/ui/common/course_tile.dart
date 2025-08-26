import 'package:azan_guru_mobile/constant/app_assets.dart';
import 'package:azan_guru_mobile/constant/app_colors.dart';
import 'package:azan_guru_mobile/constant/font_style.dart';
import 'package:azan_guru_mobile/ui/common/ag_image_view.dart';
import 'package:azan_guru_mobile/ui/model/ag_categories_data.dart';
// import 'package:azan_guru_mobile/ui/model/lesson_progress_update.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class CourseTile extends StatelessWidget {
  final AgCategoriesNode? mdlCourse;
  final double? studentProgress;
  // final StudentsOptions? studentsOptions;
  final Function()? onTapClick;
  final Function()? onTap;
  final bool? isMyCourse;

  const CourseTile({
    super.key,
    this.mdlCourse,
    this.studentProgress,
    this.isMyCourse,
    this.onTapClick,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      onTap: onTap,
      child: Container(
        width: Get.width,
        height: 108.h,
        margin: EdgeInsets.only(bottom: 20.h),
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.all(Radius.circular(16.r)),
          border: isMyCourse ?? false
              ? Border(
                  top: BorderSide(color: AppColors.listBorderColor),
                  bottom: BorderSide(color: AppColors.listBorderColor),
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 6.r,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: Row(
          children: [
            InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              onTap: onTapClick,
              child: Container(
                width: 110.w,
                height: 108.h,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  color: AppColors.black,
                  borderRadius: BorderRadius.all(Radius.circular(16.r)),
                ),
                child: Stack(
                  children: [
                    AGImageView(
                      mdlCourse?.courseTypeImage?.courseCategoryImage?.node
                              ?.mediaItemUrl ??
                          '',
                      fit: BoxFit.cover,
                      height: 108.h,
                      width: 110.w,
                    ),
                    if (isMyCourse ?? false) ...[
                      Positioned(
                        bottom: 12.h,
                        left: 12.w,
                        child: SvgPicture.asset(AssetImages.icPlay),
                      ),
                    ],
                    Positioned(
                      bottom: 10.h,
                      right: 10.w,
                      child: Container(
                        clipBehavior: Clip.hardEdge,
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(
                          vertical: 3.h,
                          horizontal: 8.w,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.all(
                            Radius.circular(5.r),
                          ),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              height: 10.h,
                              width: 10.w,
                              child: SvgPicture.asset(
                                AssetImages.icStar,
                                // ignore: deprecated_member_use
                                color: AppColors.starColor,
                              ),
                            ),
                            Text(
                              '-',
                              textAlign: TextAlign.center,
                              style: AppFontStyle.poppinsRegular.copyWith(
                                fontSize: 11.sp,
                                color: AppColors.countBoxColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 108.h,
                clipBehavior: Clip.hardEdge,
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                decoration: const BoxDecoration(border: null),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      mdlCourse?.name ?? "",
                      style: AppFontStyle.poppinsSemiBold.copyWith(
                        color: AppColors.appBgColor,
                        fontSize: 16.sp,
                      ),
                    ),
                    Visibility(
                      visible: mdlCourse?.description?.isNotEmpty ?? false
                          ? true
                          : false,
                      child: Text(
                        mdlCourse?.description ?? "",
                        style: AppFontStyle.poppinsRegular.copyWith(
                          color: AppColors.appBgColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(
                      height: studentProgress != null ? 5.h : 10.h,
                    ),
                    studentProgress != null
                        ? Container(
                            height: 6.h,
                            margin: EdgeInsets.only(bottom: 4.h),
                            clipBehavior: Clip.hardEdge,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(30.r),
                              ),
                            ),
                            child: LinearProgressIndicator(
                              value: (studentProgress! / 100),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.progressBarActiveColor,
                              ),
                              backgroundColor: AppColors.progressBarColor,
                            ),
                          )
                        : const SizedBox.shrink(),
                    if (!(isMyCourse ?? false) && studentProgress == null) ...[
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SvgPicture.asset(AssetImages.icMen),
                                SizedBox(width: 5.w),
                                _textWidget(text: '-'),
                              ],
                            ),
                            _divider(),
                            _textWidget(text: '${mdlCourse?.count} Lessons'),
                            _divider(),
                            _textWidget(
                                text:
                                    '${mdlCourse?.courseTypeImage?.courseHours ?? '-'} hours'),
                          ],
                        ),
                      ),
                    ],
                    (isMyCourse ?? false)
                        ? _textWidget(text: '$studentProgress% Completed')
                        : const SizedBox.shrink(),
                  ],
                ),
              ),
            ),
            (isMyCourse ?? false)
                ? Container(
                    height: 108.h,
                    width: 21.w,
                    decoration: BoxDecoration(color: AppColors.listBorderColor),
                    alignment: Alignment.center,
                    child: RotatedBox(
                      quarterTurns: 3,
                      child: Text(
                        'ENROLLED',
                        style: AppFontStyle.dmSansRegular.copyWith(
                          color: AppColors.white,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Widget _textWidget({required String text}) {
    return Text(
      text,
      style: AppFontStyle.dmSansRegular
          .copyWith(color: AppColors.lightGrey, fontSize: 11.sp),
    );
  }

  Widget _divider() {
    return SizedBox(
      height: 15.h,
      child: VerticalDivider(
        color: AppColors.dividerColor,
        width: 20.w,
      ),
    );
  }
}
