import 'package:azan_guru_mobile/constant/app_colors.dart';
import 'package:azan_guru_mobile/constant/font_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

Widget customButton({
  String? buttonText,
  Color? boxColor,
  Color? borderColor,
  bool showBorder = false,
  bool managedWithPadding = false,
  double? radius,
  Function()? onTap,
  double? height,
  double? width,
  Widget? child,
  EdgeInsetsGeometry? padding,
}) {
  return InkWell(
    splashColor: boxColor ?? AppColors.buttonGreenColor.withOpacity(.5),
    highlightColor: Colors.transparent,
    hoverColor: Colors.transparent,
    focusColor: Colors.transparent,
    onTap: onTap,
    child: Container(
      height: managedWithPadding ? null : height ?? 55.h,
      width: width ?? Get.width,
      padding: padding,
      alignment: Alignment.center,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: onTap == null ? AppColors.lightGreyColor : (boxColor ?? AppColors.buttonGreenColor),
        borderRadius: BorderRadius.all(Radius.circular(radius ?? 60.r)),
        border: showBorder ? Border.all(color: borderColor ?? AppColors.white) : null,
      ),
      child: child ??
          Text(
            buttonText ?? '',
            style: AppFontStyle.dmSansBold.copyWith(
              color: AppColors.white,
              fontSize: 15.sp,
            ),
          ),
    ),
  );
}

Widget containerBoxDecoration({
  EdgeInsetsGeometry? padding,
  EdgeInsetsGeometry? margin,
  Widget? child,
}) {
  return Container(
    padding: padding,
    margin: margin,
    width: Get.width,
    clipBehavior: Clip.hardEdge,
    decoration: BoxDecoration(
      color: AppColors.bgColorBottom,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(88.r),
        topRight: Radius.circular(88.r),
      ),
    ),
    child: child,
  );
}
