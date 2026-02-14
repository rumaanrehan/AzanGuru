import 'package:azan_guru_mobile/common/custom_button.dart';
import 'package:azan_guru_mobile/common/util.dart';
import 'package:azan_guru_mobile/constant/app_assets.dart';
import 'package:azan_guru_mobile/constant/app_colors.dart';
import 'package:azan_guru_mobile/constant/font_style.dart';
import 'package:azan_guru_mobile/constant/language_key.dart';
import 'package:azan_guru_mobile/route/app_routes.dart';
import 'package:azan_guru_mobile/service/local_storage/local_storage_keys.dart';
import 'package:azan_guru_mobile/service/local_storage/storage_manager.dart';
import 'package:azan_guru_mobile/ui/model/user_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:azan_guru_mobile/ui/common/ag_header_bar.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  String version = '';
  UserData? _userData;

  bool get isUserLoggedIn =>
      StorageManager.instance.getBool(LocalStorageKeys.prefUserLogin) &&
      _userData != null;

  @override
  void initState() {
    super.initState();
    _userData = StorageManager.instance.getLoginUser();
    getAppVersion();
  }

  void getAppVersion() async {
    await PackageInfo.fromPlatform().then((PackageInfo packageInfo) async {
      setState(() {
        version = packageInfo.version;
      });
      debugPrint('appVersion $version');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLightWhitColor,
      body: Column(
        children: [
          AgHeaderBar(
            onMenuTap: () {},
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.only(
                    left: 25.w, right: 25.w, top: 30.h, bottom: 150.h),
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
                      child: SvgPicture.asset(
                        AssetImages.icProfile,
                        colorFilter: ColorFilter.mode(
                          AppColors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    if (isUserLoggedIn) ...[
                      Text(
                        _displayName(),
                        style: AppFontStyle.poppinsMedium.copyWith(
                          fontSize: 22.sp,
                          color: AppColors.appBgColor,
                        ),
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        _userData?.user?.email ??
                            _userData?.user?.username ??
                            'user@email.com',
                        style: AppFontStyle.poppinsRegular.copyWith(
                          fontSize: 16.sp,
                          color: AppColors.greyColor,
                        ),
                      ),
                      if (_displayPhone() != null) ...[
                        SizedBox(height: 4.h),
                        Text(
                          _displayPhone()!,
                          style: AppFontStyle.poppinsRegular.copyWith(
                            fontSize: 14.sp,
                            color: AppColors.greyColor,
                          ),
                        ),
                      ],
                    ] else ...[
                      Text(
                        'Please login to view your profile.',
                        style: AppFontStyle.poppinsRegular.copyWith(
                          fontWeight: FontWeight.w100,
                          fontSize: 18.sp,
                          color: AppColors.appBgColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16.h),
                      customButton(
                        width: 200.w,
                        onTap: () {
                          hideKeyboard(context);
                          Get.offAllNamed(Routes.login);
                          StorageManager.instance.setBool(
                            LocalStorageKeys.prefGuestLogin,
                            false,
                          );
                          StorageManager.instance.clear();
                        },
                        buttonText: LanguageKey.loginNow.tr,
                      ),
                    ],
                    SizedBox(height: 25.h),
                    _sectionTitle('Account'),
                    if (isUserLoggedIn) ...[
                      _menuButton(
                        icon: Icons.person,
                        label: 'My Profile',
                        subtitle: 'Edit your personal information',
                        onTap: () => Get.toNamed(Routes.myProfile),
                      ),
                      _menuButton(
                        icon: Icons.settings,
                        label: 'App Settings',
                        subtitle: 'Notifications, preferences, and more',
                        onTap: () => Get.toNamed(Routes.settingPage),
                      ),
                      _menuButton(
                        icon: Icons.history,
                        label: 'Enrollment History',
                        subtitle: 'View your subscriptions',
                        onTap: () => Get.toNamed(Routes.mySubscription),
                      ),
                      _menuButton(
                        icon: Icons.delete_outline,
                        label: 'Delete Account',
                        subtitle: 'Permanently remove your account',
                        onTap: () =>
                            Get.toNamed(Routes.deleteAccountDetailPage),
                        color: AppColors.red,
                      ),
                      _menuButton(
                        icon: Icons.logout,
                        label: 'Logout',
                        subtitle: 'Sign out of your account',
                        onTap: () {
                          Get.offAllNamed(Routes.login);
                          StorageManager.instance.setBool(
                            LocalStorageKeys.prefUserLogin,
                            false,
                          );
                          StorageManager.instance.setString(
                            LocalStorageKeys.prefAuthToken,
                            '',
                          );
                          StorageManager.instance.clear();
                        },
                        color: AppColors.red,
                      ),
                    ] else ...[
                      _menuButton(
                        icon: Icons.settings,
                        label: 'App Settings',
                        subtitle: 'Notifications, preferences, and more',
                        onTap: () => Get.toNamed(Routes.settingPage),
                      ),
                    ],
                    SizedBox(height: 10.h),
                    _sectionTitle('Support'),
                    _menuButton(
                      icon: Icons.support_agent,
                      label: 'Support',
                      subtitle: 'Help center and FAQs',
                      onTap: () => Get.toNamed(Routes.helpPage),
                    ),
                    _menuButton(
                      icon: Icons.language,
                      label: 'Go to Website',
                      subtitle: 'Visit azanguru.com',
                      onTap: () => openCallingApp('https://azanguru.com/'),
                    ),
                    _menuButton(
                      icon: Icons.phone,
                      label: 'Call Us',
                      subtitle: '+91 7419223123',
                      onTap: () => openCallingApp('tel:+91 7419223123'),
                    ),
                    _menuButton(
                      icon: Icons.share,
                      label: 'Share App',
                      subtitle: 'Invite your friends',
                      onTap: () => Share.share('Welcome!'),
                    ),
                    SizedBox(height: 10.h),
                    _sectionTitle('About'),
                    _menuButton(
                      icon: Icons.info_outline,
                      label: 'About App',
                      subtitle: 'Version $version',
                      onTap: () => _showAboutDialog(context),
                    ),
                    _menuButton(
                      icon: Icons.description_outlined,
                      label: 'Terms & Conditions',
                      subtitle: 'Read the terms of service',
                      onTap: () => openCallingApp(
                        'https://azanguru.com/terms-condition/',
                      ),
                    ),
                    _menuButton(
                      icon: Icons.privacy_tip_outlined,
                      label: 'Privacy Policy',
                      subtitle: 'How we use your data',
                      onTap: () => openCallingApp(
                        'https://azanguru.com/privacy-policy/',
                      ),
                    ),
                    _menuButton(
                      icon: Icons.assignment_return_outlined,
                      label: 'Refund & Cancellation',
                      subtitle: 'Review refund policy',
                      onTap: () => openCallingApp(
                        'https://azanguru.com/refund_returns/',
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'App Version $version',
                      style: AppFontStyle.poppinsRegular.copyWith(
                        fontSize: 14.sp,
                        color: AppColors.greyColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(bottom: 10.h),
        child: Text(
          title,
          style: AppFontStyle.poppinsMedium.copyWith(
            fontSize: 16.sp,
            color: AppColors.appBgColor,
          ),
        ),
      ),
    );
  }

  Widget _menuButton({
    required IconData icon,
    required String label,
    String? subtitle,
    required VoidCallback onTap,
    Color? color,
  }) {
    final textColor = color ?? AppColors.appBgColor;
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: AppColors.dividerColor,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColor,
                blurRadius: 8.r,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                height: 36.h,
                width: 36.h,
                decoration: BoxDecoration(
                  color: AppColors.appBgColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  icon,
                  color: textColor,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppFontStyle.poppinsMedium.copyWith(
                        color: textColor,
                        fontSize: 16.sp,
                      ),
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: 2.h),
                      Text(
                        subtitle,
                        style: AppFontStyle.poppinsRegular.copyWith(
                          color: AppColors.greyColor,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppColors.greyColor,
                size: 22.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _displayName() {
    final user = _userData?.user;
    if (user == null) return 'User Name';
    final fullName = [
      if ((user.firstName ?? '').isNotEmpty) user.firstName,
      if ((user.lastName ?? '').isNotEmpty) user.lastName,
    ].join(' ');
    if (fullName.isNotEmpty) return fullName;
    return user.name ??
        user.username ??
        user.nicename ??
        user.nickname ??
        'User Name';
  }

  String? _displayPhone() {
    final user = _userData?.user;
    final phone = user?.phone;
    if (phone != null && phone.isNotEmpty) return phone;
    final number = user?.generalUserOptions?.phoneNumber;
    if (number != null && number.toString().isNotEmpty) {
      return number.toString();
    }
    return null;
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('AzanGuru'),
          content: Text('Version $version'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  openCallingApp(String uri) async {
    launchUrlInExternalBrowser(uri);
  }
}
