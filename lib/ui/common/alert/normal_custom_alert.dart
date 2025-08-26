import 'package:azan_guru_mobile/constant/app_assets.dart';
import 'package:azan_guru_mobile/constant/app_colors.dart';
import 'package:azan_guru_mobile/constant/font_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class NormalCustomAlert {
  static void showAlert(
    String message, {
    String? title,
    String? image,
    double? height,
    String btnFirst = 'Ok',
    String? btnSecond,
    Function? handler,
    bool showIcon = false,
    bool barrierDismissible = false,
  }) {
    Get.generalDialog(
      barrierDismissible: barrierDismissible,
      barrierLabel: 'barrierLabel',
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (BuildContext buildContext, Animation animation,
          Animation secondaryAnimation) {
        return Builder(builder: (context) {
          return SafeArea(
            child: Center(
              child: SizedBox(
                width: Get.width - 70.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.all(8.0),
                      padding: EdgeInsets.symmetric(
                          vertical: 15.h, horizontal: 25.w),
                      height: height,
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Column(
                        children: [
                          showIcon
                              ? SvgPicture.asset(AssetImages.icAlertCorrect)
                              : SizedBox(
                                  height: 60.w,
                                  width: 60.w,
                                  child:
                                      SvgPicture.asset(AssetImages.icWarning)),
                          _messageWidget(message: message),
                          Padding(
                            padding: EdgeInsets.only(top: 30.h),
                            child: Center(
                              child: GestureDetector(
                                onTap: () {
                                  if (handler != null) {
                                    handler(0);
                                  }
                                  var context = Get.context;
                                  if (context != null) {
                                    Navigator.pop(context);
                                  }
                                },
                                child: Container(
                                  alignment: Alignment.bottomRight,
                                  child: _buttonWidget(
                                      ok: btnFirst,
                                      cancel: btnSecond,
                                      handler: handler,
                                      context: context),
                                ),
                              ),
                            ),
                          ),
                          // Padding(
                          //   padding: EdgeInsets.only(top: 30.h),
                          //   child: Center(
                          //     child: _customButton(
                          //       buttonText: btnFirst,
                          //       buttonColor: AppColors.alertButtonBlackColor,
                          //       onPressed: () {
                          //         var context = Get.context;
                          //         if (context != null) Navigator.pop(context);
                          //         if (handler != null) {
                          //           handler(0);
                          //         }
                          //       },
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
      },
      transitionBuilder: (_, anim, __, child) {
        return ScaleTransition(
          scale: anim,
          child: child,
        );
      },
    );
  }

  static void showAlert2(
    String message, {
    String? title,
    String? image,
    double? height,
    String btnFirst = 'Ok',
    void Function()? onTap,
    bool barrierDismissible = false,
  }) {
    Get.generalDialog(
      barrierDismissible: barrierDismissible,
      barrierLabel: 'barrierLabel',
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (BuildContext buildContext, Animation animation,
          Animation secondaryAnimation) {
        return Builder(builder: (context) {
          return SafeArea(
            child: Center(
              child: SizedBox(
                width: Get.width - 70.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.all(8.0),
                      padding: EdgeInsets.symmetric(
                          vertical: 15.h, horizontal: 25.w),
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Column(
                        children: [
                          SvgPicture.asset(
                            AssetImages.icWarning,
                            width: 50,
                            height: 50,
                          ),
                          SingleChildScrollView(
                            child: Padding(
                              padding: EdgeInsets.only(top: 10.h),
                              child: Text(
                                message,
                                textAlign: TextAlign.center,
                                style: AppFontStyle.poppinsSemiBold.copyWith(
                                  fontSize: 16.sp,
                                  color: AppColors.appBgColor,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 30.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 50.h,
                                  child: ElevatedButton(
                                    onPressed: onTap,
                                    style: ButtonStyle(
                                      elevation: MaterialStateProperty.all(0),
                                      shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(50.r),
                                          side: BorderSide(
                                              width: 1.1.w,
                                              color: AppColors.black
                                                  .withOpacity(0.05),
                                              style: BorderStyle.solid),
                                        ),
                                      ),
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              AppColors.alertButtonBlackColor),
                                    ),
                                    child: Text(
                                      btnFirst,
                                      style:
                                          AppFontStyle.poppinsRegular.copyWith(
                                        fontSize: 15.sp,
                                        color: AppColors.white,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
      },
      transitionBuilder: (_, anim, __, child) {
        return ScaleTransition(
          scale: anim,
          child: child,
        );
      },
    );
  }

  static Widget _messageWidget({String? message}) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: Get.height - 200),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: 21.h),
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

  static Widget _buttonWidget(
      {String ok = "Ok",
      String? cancel,
      Function? handler,
      required BuildContext context}) {
    bool shouldShowSecondButton = cancel != null;

    return Padding(
      padding: EdgeInsets.only(bottom: 15.h, right: 22.w, left: 22.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: SizedBox(
              height: 50.h,
              // width: MediaQuery.of(context).size.width ,
              child: ElevatedButton(
                onPressed: () {
                  var context = Get.context;
                  if (context != null) Navigator.pop(context);
                  if (handler != null) {
                    handler(0);
                  }
                },
                style: ButtonStyle(
                  elevation: MaterialStateProperty.all(0),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.r),
                      side: BorderSide(
                          width: 1.1.w,
                          color: AppColors.black.withOpacity(0.05),
                          style: BorderStyle.solid),
                    ),
                  ),
                  backgroundColor: MaterialStateProperty.all<Color>(
                      AppColors.alertButtonBlackColor),
                ),
                child: Text(
                  ok,
                  style: AppFontStyle.poppinsRegular.copyWith(
                    fontSize: 15.sp,
                    color: AppColors.white,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ),
          ),
          !shouldShowSecondButton
              ? Container()
              : SizedBox(
                  width: MediaQuery.of(context).size.width * 0.05,
                ),
          !shouldShowSecondButton
              ? Container()
              : Expanded(
                  child: SizedBox(
                    height: 50.h,
                    // width: MediaQuery.of(context).size.width * 0.32.w,
                    child: ElevatedButton(
                      onPressed: () {
                        var context = Get.context;
                        if (context != null) Navigator.pop(context);
                        if (handler != null) {
                          handler(1);
                        }
                      },
                      style: ButtonStyle(
                        elevation: MaterialStateProperty.all(0),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50.r),
                            side: BorderSide(
                                width: 1.1.w,
                                color: AppColors.black.withOpacity(0.05),
                                style: BorderStyle.solid),
                          ),
                        ),
                        backgroundColor: MaterialStateProperty.all<Color>(
                            AppColors.progressBarActiveColor),
                      ),
                      child: Text(
                        cancel,
                        style: AppFontStyle.poppinsRegular.copyWith(
                          fontSize: 15.sp,
                          color: AppColors.white,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

// static Widget _customButton(
//     {required Function()? onPressed,
//     String? buttonText,
//     required Color buttonColor}) {
//   return SizedBox(
//     height: 45.h,
//     // width: Get.width,
//     child: ElevatedButton(
//       onPressed: onPressed,
//       style: ButtonStyle(
//         elevation: MaterialStateProperty.all(0),
//         shape: MaterialStateProperty.all<RoundedRectangleBorder>(
//           RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(50.r),
//             side: BorderSide(
//                 width: 1.1.w,
//                 color: AppColors.black.withOpacity(0.05),
//                 style: BorderStyle.solid),
//           ),
//         ),
//         backgroundColor: MaterialStateProperty.all<Color>(buttonColor),
//       ),
//       child: Text(
//         buttonText ?? '',
//         style: AppFontStyle.poppinsRegular.copyWith(
//           fontSize: 15.sp,
//           color: AppColors.white,
//           decoration: TextDecoration.none,
//         ),
//       ),
//     ),
//   );
// }
}
