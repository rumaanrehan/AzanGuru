import 'package:azan_guru_mobile/constant/app_assets.dart';
import 'package:azan_guru_mobile/constant/app_colors.dart';
import 'package:azan_guru_mobile/constant/font_style.dart';
import 'package:azan_guru_mobile/ui/common/ag_image_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class CustomAlert {
  static void showAlert(
    String message, {
    String? title,
    String? image,
    double? height,
    String btnFirst = 'Ok',
    String? btnSecond,
    Function? handler,
    bool showHorizontalButton = false,
  }) {
    Get.generalDialog(
      barrierDismissible: true,
      barrierLabel: 'barrierLabel',
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (
        BuildContext buildContext,
        Animation animation,
        Animation secondaryAnimation,
      ) {
        return Builder(
          builder: (context) {
            return SafeArea(
              child: Center(
                child: SizedBox(
                  width: Get.width - 40.w,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            margin: const EdgeInsets.all(8.0),
                            height: height,
                            clipBehavior: Clip.hardEdge,
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: Column(
                              children: [
                                Material(
                                  child: InkWell(
                                    splashColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    focusColor: Colors.transparent,
                                    onTap: () {
                                      Get.back();
                                    },
                                    child: Align(
                                      alignment: Alignment.topRight,
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                          top: 15.h,
                                          right: 15.w,
                                        ),
                                        child: SvgPicture.asset(
                                          AssetImages.icClose,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 50.h),
                                _messageWidget(message: message),
                                Padding(
                                  padding: EdgeInsets.only(top: 20.h),
                                  child: Center(
                                    child: Container(
                                      alignment: Alignment.bottomRight,
                                      child: _buttonWidget(
                                        ok: btnFirst,
                                        cancel: btnSecond,
                                        handler: handler,
                                        context: context,
                                        showHorizontalButton:
                                            showHorizontalButton,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        top: showHorizontalButton ? 240 : 220,
                        child: Container(
                          width: 130.w,
                          height: 120.h,
                          clipBehavior: Clip.hardEdge,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.all(
                              Radius.circular(16.r),
                            ),
                          ),
                          child: AGImageView(
                            image ?? '',
                            fit: BoxFit.cover,
                            width: 130.w,
                            height: 120.h,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
      transitionBuilder: (_, anim, __, child) {
        return ScaleTransition(
          scale: anim,
          child: child,
        );
      },
    );
  }

  static Widget _titleWidget({String? title}) {
    if (title == null || title.isEmpty) {
      return Container(height: 80.h);
    }
    return Padding(
      padding: EdgeInsets.only(left: 10.w, right: 10.w, top: 20.h),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: AppFontStyle.poppinsRegular.copyWith(
          color: AppColors.black,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }

  static Widget _messageWidget({String? message}) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: Get.height - 200),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(left: 20.w, right: 20.w),
          child: Text(
            message ?? "",
            textAlign: TextAlign.center,
            style: AppFontStyle.poppinsSemiBold.copyWith(
              fontSize: 20.sp,
              color: AppColors.appBgColor,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buttonWidget({
    String ok = "Ok",
    String? cancel,
    Function? handler,
    bool showHorizontalButton = false,
    required BuildContext context,
  }) {
    bool shouldShowSecondButton = cancel != null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: showHorizontalButton ? 10.h : 35.h,
        right: 22.w,
        left: 22.w,
      ),
      child: showHorizontalButton
          ? Row(
              children: [
                Expanded(
                  child: _customButton(
                    buttonText: ok,
                    buttonColor: AppColors.alertButtonBlackColor,
                    onPressed: () {
                      var context = Get.context;
                      if (context != null) Navigator.pop(context);
                      if (handler != null) {
                        handler(0);
                      }
                    },
                  ),
                ),
                SizedBox(width: 15.w),
                !shouldShowSecondButton ? Container() : SizedBox(height: 12.h),
                !shouldShowSecondButton
                    ? Container()
                    : Expanded(
                        child: _customButton(
                          buttonColor: AppColors.alertButtonColor,
                          buttonText: cancel,
                          onPressed: () {
                            var context = Get.context;
                            if (context != null) Navigator.pop(context);
                            if (handler != null) {
                              handler(1);
                            }
                          },
                        ),
                      ),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _customButton(
                  buttonText: ok,
                  buttonColor: AppColors.alertButtonColor,
                  onPressed: () {
                    var context = Get.context;
                    if (context != null) Navigator.pop(context);
                    if (handler != null) {
                      handler(0);
                    }
                  },
                ),
                !shouldShowSecondButton ? Container() : SizedBox(height: 12.h),
                !shouldShowSecondButton
                    ? Container()
                    : _customButton(
                        buttonColor: AppColors.alertButtonBlackColor,
                        buttonText: cancel,
                        onPressed: () {
                          var context = Get.context;
                          if (context != null) Navigator.pop(context);
                          if (handler != null) {
                            handler(1);
                          }
                        },
                      ),
              ],
            ),
    );
  }

  static Widget _customButton({
    required Function()? onPressed,
    String? buttonText,
    required Color buttonColor,
  }) {
    return SizedBox(
      height: 45.h,
      width: Get.width,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          elevation: MaterialStateProperty.all(0),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50.r),
              side: BorderSide(
                width: 1.1.w,
                color: AppColors.black.withOpacity(0.05),
                style: BorderStyle.solid,
              ),
            ),
          ),
          backgroundColor: MaterialStateProperty.all<Color>(buttonColor),
        ),
        child: Text(
          buttonText ?? '',
          style: AppFontStyle.poppinsRegular.copyWith(
            fontSize: 15.sp,
            color: AppColors.white,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }

  static void showUpdateAppDialog(
    String message, {
    String? title,
    String? btnFirst,
    Function? handler,
  }) {
    Get.generalDialog(
      barrierDismissible: false,
      barrierLabel: 'barrierLabel',
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (
        BuildContext buildContext,
        Animation animation,
        Animation secondaryAnimation,
      ) {
        return PopScope(
          canPop: false,
          child: Builder(
            builder: (context) {
              return SafeArea(
                child: Center(
                  child: SizedBox(
                    width: Get.width - 50,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0).w,
                          child: Container(
                            clipBehavior: Clip.hardEdge,
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Column(
                              children: [
                                _titleWidget(title: title),
                                _messageWidget(message: message),
                                Padding(
                                  padding: EdgeInsets.only(top: 44.h),
                                  child: Center(
                                    child: GestureDetector(
                                      onTap: () {
                                        if (handler != null) {
                                          handler(true);
                                        }
                                      },
                                      child: Container(
                                        alignment: Alignment.bottomRight,
                                        child: _buttonWidget(
                                          ok: btnFirst ?? 'Update',
                                          handler: handler,
                                          context: context,
                                        ),
                                      ),
                                    ),
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
              );
            },
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        return ScaleTransition(
          scale: anim,
          child: child,
        );
      },
    );
  }
}
