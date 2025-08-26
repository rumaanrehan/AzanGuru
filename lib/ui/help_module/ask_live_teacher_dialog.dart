import 'dart:developer';
import 'dart:io';

import 'package:azan_guru_mobile/bloc/help_bloc/help_bloc.dart';
import 'package:azan_guru_mobile/common/util.dart';
import 'package:azan_guru_mobile/constant/app_colors.dart';
import 'package:azan_guru_mobile/constant/font_style.dart';
import 'package:azan_guru_mobile/route/app_routes.dart';
import 'package:azan_guru_mobile/ui/model/key_value_model.dart';
import 'package:azan_guru_mobile/ui/model/mdl_help.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';


import 'package:azan_guru_mobile/service/local_storage/storage_manager.dart';

class AskLiveTeacherDialog extends StatefulWidget {
  final MDLHelp? data;
  final Widget? widget;
  final bool isSupportView;
  final Function? onClick;
  const AskLiveTeacherDialog({
    super.key,
    this.data,
    this.isSupportView = false,
    required this.widget,
    this.onClick,
  });

  @override
  State<AskLiveTeacherDialog> createState() => _AskLiveTeacherDialogState();
}

class _AskLiveTeacherDialogState extends State<AskLiveTeacherDialog> {
  final HelpBloc bloc = HelpBloc();
  bool get isUserLoggedIn => user != null;
  bool isCoursePurchased = false;
  bool isUserHasSubscription = false;
  bool loading = false;
  String phoneNumber = '+91 8950914110';
  @override
  void initState() {
    if (isUserLoggedIn) {
      bloc.add(GetOrderStatusEvent());
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HelpBloc, HelpState>(
      bloc: bloc,
      listener: (context, state) {
        if (state is ShowLoaderState) {
          loading = true;
        } else if (state is HideLoaderState) {
          loading = false;
        } else if (state is GetOrderStatusState) {
          KeyValueModel? orderStatusData = (state.order.orders
              ?.firstWhereOrNull((element) => element.key == 'status'));
          if (orderStatusData != null) {
            isCoursePurchased = (orderStatusData.value != null) &&
                (orderStatusData.value == 'completed');
          }

          KeyValueModel? subscriptionStatusData = (state.order.orders
              ?.firstWhereOrNull((element) => element.key == 'subcription'));
          if (subscriptionStatusData != null) {
            isUserHasSubscription = (subscriptionStatusData.value != null) &&
                    (subscriptionStatusData.value == 'active') ||
                (subscriptionStatusData.value == 'true');
          }

          if (state.order.number?.isNotEmpty ?? false) {
            phoneNumber = state.order.number ?? '';
          }
        }
      },
      builder: (context, state) {
        return InkWell(
          splashColor: Colors.transparent,
          focusColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          onTap: showAlertDialog,
          child: loading
              ? Center(
                  child: CircularProgressIndicator(
                    color: AppColors.appBgColor,
                  ),
                )
              : widget.widget ?? Container(),
        );
      },
    );
  }

  launchWhatsAppUri() async {
    final WhatsAppUnilink link = WhatsAppUnilink(
      phoneNumber: phoneNumber,
      text: "Connect to my teacher",
    );
    await launchUrl(link.asUri());
  }

  showAlertDialog() {
    if (widget.onClick != null) {
      widget.onClick!();
    }
    if (isUserLoggedIn && isCoursePurchased && isUserHasSubscription) {
      launchWhatsAppUri();
      return;
    }
    Widget dialogWidget = Material(
      color: Colors.transparent,
      child: SafeArea(
        child: Center(
          child: Container(
            width: Get.width - 50,
            height: Get.height * (isUserLoggedIn ? 0.45 : 0.55),
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Stack(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Icon(Icons.close),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: 40.w,
                    right: 40.w,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!isUserLoggedIn) ...[
                        Text(
                          "Oho! You've not logged in yet. Please login to continue.",
                          style: AppFontStyle.poppinsMedium.copyWith(
                            color: AppColors.black,
                            fontSize: 14.sp,
                          ),
                        ),
                        SizedBox(height: 5.h),
                        _customButton(
                          buttonColor: AppColors.alertButtonColor,
                          buttonText: 'Login',
                          onPressed: () {
                            Navigator.pop(context);
                            Get.offAllNamed(Routes.login);
                          },
                        ),
                        SizedBox(height: 20.h),
                      ],
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  "Contribute a nominal hadya for live teacher support and cutting-edge technology, supporting our ",
                              style: AppFontStyle.poppinsMedium.copyWith(
                                fontSize: 14.sp,
                                color: AppColors.black,
                              ),
                            ),
                            TextSpan(
                              text: "Quran-learning mission. ",
                              style: AppFontStyle.poppinsBold.copyWith(
                                fontSize: 14.sp,
                                color: AppColors.black,
                              ),
                            ),
                            TextSpan(
                              text:
                                  "Boost your Quranic journey at home with our ",
                              style: AppFontStyle.poppinsMedium.copyWith(
                                fontSize: 14.sp,
                                color: AppColors.black,
                              ),
                            ),
                            TextSpan(
                              text: "top-notch solutions.",
                              style: AppFontStyle.poppinsBold.copyWith(
                                fontSize: 14.sp,
                                color: AppColors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 5.h),
                      _customButton(
                        buttonColor: AppColors.alertButtonBlackColor,
                        buttonText: 'Get Live Teacher Assistance',
                        onPressed: () {
                          Navigator.pop(context);

                          if (Platform.isIOS) {
                            Get.toNamed(
                              Routes.planPage,
                              arguments: ['', true],
                            );
                          } else {
                            final user = StorageManager.instance.getLoginUser();
                            final url =
                                '${baseUrl}checkout/?add-to-cart=28543&variation_id=45891&attribute_pa_subscription-pricing=monthly&ag_course_dropdown=10'
                                '${user != null ? '&student_id=${user.databaseId}' : ''}';
                            debugPrint('Ask Live Teach \n $url');
                            Get.toNamed(Routes.agWebViewPage, arguments: url);
                          }
                        },
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        "Do you have any question?\nKindly ping your question here, team will respond you shortly.",
                        style: AppFontStyle.poppinsMedium.copyWith(
                          color: AppColors.black,
                          fontSize: 14.sp,
                        ),
                      ),
                      SizedBox(height: 5.h),
                      _customButton(
                        buttonColor: AppColors.buttonColor,
                        buttonText: 'Ask question',
                        onPressed: () {
                          Navigator.pop(context);
                          Get.toNamed(Routes.questionMessagePage);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Get.dialog(dialogWidget);
  }

  Future<void> launchUrlInBrowser(String url) async {
    var isValidUrl = await canLaunchUrl(Uri.parse(url));
    if (isValidUrl) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      Get.toNamed(Routes.agWebViewPage, arguments: url);
    }
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
}
