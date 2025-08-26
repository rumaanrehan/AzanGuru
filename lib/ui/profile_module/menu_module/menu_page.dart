import 'dart:developer';
import 'package:azan_guru_mobile/common/custom_button.dart';
import 'package:azan_guru_mobile/common/util.dart';
import 'package:azan_guru_mobile/constant/app_assets.dart';
import 'package:azan_guru_mobile/constant/app_colors.dart';
import 'package:azan_guru_mobile/constant/enum.dart';
import 'package:azan_guru_mobile/constant/font_style.dart';
import 'package:azan_guru_mobile/constant/language_key.dart';
import 'package:azan_guru_mobile/route/app_routes.dart';
import 'package:azan_guru_mobile/service/local_storage/local_storage_keys.dart';
import 'package:azan_guru_mobile/service/local_storage/storage_manager.dart';
import 'package:azan_guru_mobile/ui/model/mdl_setting.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  List<MDLSetting> option = [];

  bool get isUserLoggedIn => user != null;
  String version = '';

  void getAppVersion() async {
    await PackageInfo.fromPlatform().then((PackageInfo packageInfo) async {
      setState(() {
        version = packageInfo.version;
      });
      debugPrint('appVersion $version');
    });
  }

  @override
  void initState() {
    super.initState();
    getAppVersion();
    option = [
      if (isUserLoggedIn) ...[
        MDLSetting(
          title: "My Profile",
          settingOptionType: SettingOptionType.myProfile,
        ),
        // MDLSetting(
        //   title: "Enrollment History",
        //   settingOptionType: SettingOptionType.mySubscription,
        // ),
        MDLSetting(
          title: "Setting",
          showIcon: true,
          settingOptionType: SettingOptionType.setting,
        ),
      ],
      MDLSetting(
        title: "Go to Website",
        settingOptionType: SettingOptionType.aboutCompany,
      ),
      if (isUserLoggedIn) ...[
        MDLSetting(
          title: "Call Us",
          showIcon: false,
          settingOptionType: SettingOptionType.callUs,
        ),
      ],
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: customAppBar(
        showTitle: true,
        centerTitle: true,
        backgroundColor: AppColors.appBgColor,
        title: 'Menu',
        showPrefixIcon: true,
        onClick: () {
          Get.back();
        },
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 30.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 120.w,
                    width: 120.w,
                    padding: EdgeInsets.all(5.h),
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.logoColor,
                    ),
                    child: Image.asset(
                      AssetImages.agLogo,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  if (!isUserLoggedIn) ...[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Please login to view your settings.',
                          style: AppFontStyle.poppinsRegular.copyWith(
                            fontWeight: FontWeight.w100,
                            fontSize: 20.sp,
                            color: AppColors.appBgColor,
                          ),
                        ),
                        SizedBox(height: 20.h),
                        customButton(
                          width: 200.w,
                          onTap: () {
                            hideKeyboard(context);
                            Get.offAllNamed(Routes.login);
                            StorageManager.instance.setBool(
                                LocalStorageKeys.prefGuestLogin, false);
                            StorageManager.instance.clear();
                          },
                          buttonText: LanguageKey.loginNow.tr,
                        ),
                        SizedBox(height: 20.h),
                      ],
                    )
                  ],
                  Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.only(top: 15.h),
                      itemCount: option.length,
                      itemBuilder: (BuildContext context, int index) {
                        var data = option[index];
                        return InkWell(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          onTap: () {
                            switch (data.settingOptionType) {
                              case SettingOptionType.aboutCompany:
                                openCallingApp('https://azanguru.com/');
                                break;
                              case SettingOptionType.setting:
                                Get.toNamed(Routes.settingPage);
                                break;
                              case SettingOptionType.callUs:
                                openCallingApp('tel:+91 8950914110');
                                break;
                              case SettingOptionType.myProfile:
                                Get.toNamed(Routes.myProfile);
                                break;
                              case SettingOptionType.mySubscription:
                                Get.toNamed(Routes.mySubscription);
                                break;
                              case null:
                                break;
                            }
                          },
                          child: Column(
                            children: [
                              _customOptionRow(data),
                              index < (option.length - 1)
                                  ? _divider()
                                  : const SizedBox.shrink(),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10.w,
            runSpacing: 5.h,
            children: [
              InkWell(
                onTap: () {
                  openCallingApp('https://azanguru.com/terms-condition/');
                },
                child: Text(
                  'Terms & Conditions',
                  style: AppFontStyle.poppinsRegular.copyWith(
                    fontSize: 15.sp,
                    color: AppColors.lightBlue,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.lightBlue,
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              InkWell(
                onTap: () {
                  openCallingApp('https://azanguru.com/privacy-policy/');
                },
                child: Text(
                  'Privacy Policy',
                  style: AppFontStyle.poppinsRegular.copyWith(
                    fontSize: 15.sp,
                    color: AppColors.lightBlue,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.lightBlue,
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              InkWell(
                onTap: () {
                  openCallingApp('https://azanguru.com/refund_returns/');
                },
                child: Text(
                  'Refund & Cancellation',
                  style: AppFontStyle.poppinsRegular.copyWith(
                    fontSize: 15.sp,
                    color: AppColors.lightBlue,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.lightBlue,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            'App Version $version',
            style: AppFontStyle.poppinsRegular.copyWith(
              fontSize: 15.sp,
              color: AppColors.appBgColor,
            ),
          ),
          SizedBox(height: 10.h),
          if (isUserLoggedIn) ...[
            Padding(
              padding: EdgeInsets.only(
                bottom: 30.h,
                left: 50.w,
                right: 50.w,
              ),
              child: customButton(
                onTap: () {
                  Get.offAllNamed(Routes.login);
                  StorageManager.instance.setBool(
                    LocalStorageKeys.prefUserLogin,
                    false,
                  );
                  StorageManager.instance
                      .setString(LocalStorageKeys.prefAuthToken, '');
                  StorageManager.instance.clear();
                },
                boxColor: Colors.transparent,
                borderColor: AppColors.greenBorderColor,
                showBorder: true,
                child: Text(
                  'Logout',
                  style: AppFontStyle.poppinsMedium.copyWith(
                    color: AppColors.appBgColor,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _customOptionRow(MDLSetting option) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            option.title ?? "",
            style: AppFontStyle.poppinsMedium.copyWith(
              fontSize: 18.sp,
              color: AppColors.appBgColor,
            ),
            textAlign: TextAlign.start,
          ),
        ),
        Visibility(
          visible: option.showIcon,
          child: SizedBox(
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
          ),
        )
      ],
    );
  }

  Widget _divider() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: const Divider(height: 0),
    );
  }

  openCallingApp(String uri) async {
    Uri mobileNumber = Uri.parse(uri);
    if (await launchUrl(mobileNumber)) {
    } else {
      Get.toNamed(Routes.agWebViewPage, arguments: mobileNumber);
    }
  }
}
