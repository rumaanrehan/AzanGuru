import 'dart:developer';
import 'dart:io';

import 'package:azan_guru_mobile/bloc/live_class_bloc/live_class_bloc.dart';
import 'package:azan_guru_mobile/ui/common/loader.dart';
import 'package:azan_guru_mobile/ui/model/key_value_model.dart';
import 'package:azan_guru_mobile/ui/model/live_classes_data.dart';
import 'package:flutter/material.dart';
import 'package:azan_guru_mobile/common/util.dart';
import 'package:azan_guru_mobile/constant/app_assets.dart';
import 'package:azan_guru_mobile/constant/app_colors.dart';
import 'package:azan_guru_mobile/constant/font_style.dart';
import 'package:azan_guru_mobile/route/app_routes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:azan_guru_mobile/ui/common/ads/ag_banner_ad.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:azan_guru_mobile/service/local_storage/local_storage_keys.dart';
import 'package:azan_guru_mobile/service/local_storage/storage_manager.dart';

class LiveClassTab extends StatefulWidget {
  const LiveClassTab({super.key});

  @override
  State<LiveClassTab> createState() => _LiveClassTabState();
 }

class _LiveClassTabState extends State<LiveClassTab> {
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
  LiveClassBloc bloc = LiveClassBloc();
  LiveClassesData? liveClassesData;

  bool get isUserLoggedIn => user != null;
  bool isCoursePurchased = false;
  bool isUserHasSubscription = false;

  String get token =>
      StorageManager.instance.getString(LocalStorageKeys.prefAuthToken);

  @override
  void initState() {
    super.initState();
    bloc.add(GetLiveClassDataEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LiveClassBloc, LiveClassState>(
      bloc: bloc,
      listener: (context, state) {
        if (state is ShowLiveClassLoadingState) {
          if (!AGLoader.isShown) {
            AGLoader.show(context);
          }
        } else if (state is HideLiveClassLoadingState) {
          if (AGLoader.isShown) {
            AGLoader.hide();
          }
        } else if (state is GetLiveClassDataState) {
          liveClassesData = state.liveClassesData;
          if (isUserLoggedIn) {
            bloc.add(GetSubscriptionStatusEvent());
          }
        } else if (state is GetSubscriptionStatusState) {
          final orderList = state.order.orders;

          KeyValueModel? subData = orderList?.firstWhereOrNull((e) => e.key == 'subscription');
          KeyValueModel? orderStatusData = orderList?.firstWhereOrNull((e) => e.key == 'status');

          if (subData != null) {
            final val = subData.value?.toLowerCase();
            isUserHasSubscription = val == 'true' || val == 'active';
          }

          if (orderStatusData != null) {
            isCoursePurchased = orderStatusData.value?.toLowerCase() == 'completed';
          }
        }
      },
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _headerView(),
            Expanded(
              child: SingleChildScrollView(
                child: liveClassesData == null
                    ? Container()
                    : Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            // Html(
                            //   data: liveClassesData
                            //           ?.generalOptionsFields?.liveClassInfo ??
                            //       '',
                            // ),
                            InkWell(
                              onTap: onJoinClassClick,
                              child: Center(
                                child: Image.asset(AssetImages.liveClass),
                              ),
                            ),
                            SizedBox(height: 10.h),
                            _customButton(
                              buttonColor: AppColors.buttonColor,
                              buttonText: 'Join class',
                              onPressed: onJoinClassClick,
                            ),
                            SizedBox(height: 10.h),
                            Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 24.h),
                                child: AGBannerAd(adSize: AdSize.mediumRectangle),
                              ),
                            ),
                            SizedBox(height: 70.h),
                          ],
                        ),
                      ),
              ),
            ),
          ],
        );
      },
    );
  }

  onJoinClassClick() async {
    if (isUserLoggedIn && isUserHasSubscription) {
      String url = '${baseUrl}student-live-class/${user != null ? '?student_id=${user?.databaseId.toString()}&agUserAuthKey=${user?.generalUserOptions?.agUserAuthKey.toString()}' : ''}';
      debugPrint('url===> $url');
      launchUrlInExternalBrowser(url);
    } else if (isUserLoggedIn && isCoursePurchased && DateTime.now().weekday == DateTime.monday) {
      String url = '${baseUrl}student-live-class/${user != null ? '?student_id=${user?.databaseId.toString()}&agUserAuthKey=${user?.generalUserOptions?.agUserAuthKey.toString()}' : ''}';
      launchUrlInExternalBrowser(url);
    } else {
      showAlertDialog();
    }
  }

  showAlertDialog() {
    Widget dialogWidget = Material(
      color: Colors.transparent,
      child: SafeArea(
        child: Center(
          child: Container(
            width: Get.width - 50,
            height: Get.height * 0.4,
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
                  padding: EdgeInsets.symmetric(horizontal: 40.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isUserLoggedIn
                            ? "Access Required\nSubscribe to join live classes with teacher assistance."
                            : "You're not logged in\nPlease login to join the live class.",
                        textAlign: TextAlign.center,
                        style: AppFontStyle.poppinsMedium.copyWith(
                          color: AppColors.black,
                          fontSize: 15.sp,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      _customButton(
                        buttonColor: isUserLoggedIn
                            ? AppColors.alertButtonBlackColor
                            : AppColors.alertButtonColor,
                        buttonText:
                        isUserLoggedIn ? 'Subscribe & Join Class' : 'Login',
                        onPressed: () {
                          Navigator.pop(context);
                          if (!isUserLoggedIn) {
                            Get.offAllNamed(Routes.login);
                          } else {
                            if (Platform.isIOS) {
                              Get.toNamed(
                                Routes.planPage,
                                arguments: ['', true],
                              );
                            } else {
                              String url =
                                  '${baseUrl}checkout/?add-to-cart=28543&variation_id=45891&attribute_pa_subscription-pricing=monthly&ag_wv_token=${Uri.encodeQueryComponent(token)}&utm_source=AppWebView&ag_course_dropdown=10${user != null ? '&student_id=${user?.databaseId}' : ''}';
                                launchUrlInExternalBrowser(url);
                            }
                          }
                        },
                      ),
                      SizedBox(height: 15.h),
                      _customButton(
                        buttonColor: AppColors.buttonColor,
                        buttonText: 'Ask a Question',
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
    launchUrlInExternalBrowser(url);
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

  Widget _headerView() {
    return Container(
      color: const Color(0xFF4D8974),
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 46.h,
        bottom: 12.h,
      ),
      child: SizedBox(
        height: 48.h,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left: AzanGuru logo
            SizedBox(
              width: 150.w,
              height: 100.w,
              child: Image.asset(
                'assets/images/ag_header_logo.png',
                fit: BoxFit.contain,
              ),
            ),
            // Right: Bismillah text and menu button
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "﷽",
                      style: AppFontStyle.dmSansRegular.copyWith(
                        fontSize: 22.5.sp,
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
            ),
          ],
        ),
      ),
    );
  }
}
