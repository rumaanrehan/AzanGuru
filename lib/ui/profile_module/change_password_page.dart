import 'package:azan_guru_mobile/bloc/profile_module/change_password_module/change_password_bloc.dart';
import 'package:azan_guru_mobile/common/custom_button.dart';
import 'package:azan_guru_mobile/common/custom_text_field.dart';
import 'package:azan_guru_mobile/common/util.dart';
import 'package:azan_guru_mobile/constant/app_colors.dart';
import 'package:azan_guru_mobile/constant/font_style.dart';
import 'package:azan_guru_mobile/route/app_routes.dart';
import 'package:azan_guru_mobile/ui/model/mdl_login_param.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../constant/app_assets.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final ChangePasswordBloc changePasswordBloc = ChangePasswordBloc();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<ChangePasswordBloc, ChangePasswordState>(
        bloc: changePasswordBloc,
        listener: (context, state) {
          if (state is ChangePasswordErrorState) {
            showNormalDialog(context, state.errorMessage.toString());
          }
          if (state is ChangePasswordSuccessState) {
            showNormalDialog(
              context,
              'Password changed Successfully',
              btnFirst: "Back to home",
              handler: (index) {
                Get.back();
              },
              showIcon: true,
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.topCenter,
                      child: _backgroundView(),
                    ),
                    Column(
                      children: [
                        SizedBox(height: 230.h),
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.only(left: 31.w, right: 31.w),
                            padding: EdgeInsets.only(
                                top: 90.h, left: 22.w, right: 22.w),
                            height: Get.height,
                            width: Get.width,
                            clipBehavior: Clip.hardEdge,
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(16.r)),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.shadowColor,
                                  blurRadius: 6.r,
                                  offset: const Offset(0, 9),
                                )
                              ],
                            ),
                            child: Column(
                              children: [
                                Expanded(
                                  child: SingleChildScrollView(
                                    physics: const BouncingScrollPhysics(),
                                    child: Column(
                                      children: [
                                        _textField(
                                          controller:
                                              _currentPasswordController,
                                          hintText: 'Current Password',
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 17.h),
                                          child: _textField(
                                            controller: _newPasswordController,
                                            hintText: 'New Password',
                                          ),
                                        ),
                                        _textField(
                                          controller:
                                              _confirmPasswordController,
                                          hintText: 'Confirm New Password',
                                          textInputAction: TextInputAction.done,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.only(top: 10.h, bottom: 30.h),
                                  child: customButton(
                                    onTap: () {
                                      changePasswordBloc.add(
                                        PasswordChangeEvent(
                                          mdlChangePasswordParam:
                                              MDLChangePasswordParam(
                                            currentPassword:
                                                _currentPasswordController.text
                                                    .trim(),
                                            newPassword: _newPasswordController
                                                .text
                                                .trim(),
                                            confirmPassword:
                                                _confirmPasswordController.text
                                                    .trim(),
                                          ),
                                        ),
                                      );
                                    },
                                    boxColor: AppColors.alertButtonColor,
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 25.w),
                                    child: Text(
                                      ("Save new password").toUpperCase(),
                                      textAlign: TextAlign.center,
                                      style: AppFontStyle.dmSansMedium.copyWith(
                                          color: AppColors.white,
                                          fontSize: 15.sp),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                    _profileView(),
                  ],
                ),
              ),
              SizedBox(height: 100.h)
            ],
          );
        },
      ),
    );
  }

  Widget _backgroundView() {
    return customTopContainer(
      bgImage: AssetImages.icBgProfile,
      height: 260.h,
      insideChild: customAppBar(
        showTitle: true,
        centerTitle: true,
        title: 'Change Password',
        showPrefixIcon: true,
        onClick: () {
          Get.back();
        },
        suffixIcons: [
          customIcon(
            iconColor: AppColors.white,
              onClick: () {
                Get.toNamed(Routes.menuPage);
              },
              icon: AssetImages.icMenu,),
          Padding(
            padding: EdgeInsets.only(left: 25.w, right: 23.w),
            child: customIcon(
                onClick: () {
                  Get.toNamed(Routes.notificationPage);
                },
                icon: AssetImages.icNotification,
                iconColor: AppColors.white,),
          ),
        ],
      ),
    );
  }

  Widget _textField(
      {required TextEditingController controller,
      required String hintText,
      TextInputAction? textInputAction}) {
    return CustomTextField(
      controller: controller,
      borderColor: AppColors.textFieldBorderColor,
      backgroundColor: Colors.transparent,
      hintTexts: hintText,
      textInputAction: textInputAction ?? TextInputAction.next,
      textInputTextStyle: AppFontStyle.dmSansMedium.copyWith(
        color: AppColors.alertButtonBlackColor,
        fontSize: 15.sp,
        overflow: TextOverflow.clip,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _profileView() {
    return Positioned(
      top: 135,
      child: Container(
        alignment: Alignment.center,
        width: 145.h,
        height: 145.h,
        decoration: ShapeDecoration(
          color: AppColors.white,
          shape: OvalBorder(
            side: BorderSide(width: 1.w, color: AppColors.profileBorderColor),
          ),
        ),
        child: profileText(),
      ),
    );
  }
}
