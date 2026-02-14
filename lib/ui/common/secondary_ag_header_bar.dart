import 'package:azan_guru_mobile/constant/app_colors.dart';
import 'package:azan_guru_mobile/constant/font_style.dart';
import 'package:azan_guru_mobile/route/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

/// Secondary header bar for pages that are NOT in the main tabbar
/// Shows: Back button | Page Title | Home button | Menu button
class SecondaryAgHeaderBar extends StatelessWidget {
  const SecondaryAgHeaderBar({
    super.key,
    required this.pageTitle,
    this.showBackButton = true,
    this.showHomeButton = true,
    this.showMenuButton = false,
    this.onBackPressed,
    this.backgroundColor,
    this.extraActions,
    this.leadingActions,
  });

  final String pageTitle;
  final bool showBackButton;
  final bool showHomeButton;
  final bool showMenuButton;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;
  final List<Widget>? extraActions;
  final List<Widget>? leadingActions;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor ?? AppColors.headerColor,
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 46.h,
        bottom: 12.h,
      ),
      child: SizedBox(
        height: 48.h,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Left side: Back button and leading actions
            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (leadingActions != null) ...leadingActions!,
                  if (leadingActions != null && showBackButton)
                    SizedBox(width: 12.w),
                  if (showBackButton &&
                      (Get.key.currentState?.canPop() ?? false))
                    _headerIcon(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: () {
                        if (onBackPressed != null) {
                          onBackPressed!();
                        } else {
                          Get.back();
                        }
                      },
                    ),
                ],
              ),
            ),

            // Center: Page Title
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.w),
                child: Text(
                  pageTitle,
                  style: AppFontStyle.poppinsSemiBold.copyWith(
                    fontSize: 18.sp,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),

            // Right side: Home button and Menu button
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (extraActions != null) ...extraActions!,
                  if (extraActions != null &&
                      (showHomeButton || showMenuButton))
                    SizedBox(width: 12.w),
                  if (showHomeButton)
                    _headerIcon(
                      icon: Icons.home_rounded,
                      onTap: () => Get.offAllNamed(Routes.tabBarPage),
                    ),
                  if (showHomeButton && showMenuButton) SizedBox(width: 12.w),
                  if (showMenuButton)
                    _headerIcon(
                      icon: Icons.menu_rounded,
                      onTap: () => Get.toNamed(Routes.menuPage),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerIcon({
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
        child: Icon(icon, color: Colors.white, size: 20.sp),
      ),
    );
  }
}
