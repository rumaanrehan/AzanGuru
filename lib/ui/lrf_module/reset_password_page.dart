import 'package:azan_guru_mobile/bloc/lrf_module/reset_password_bloc/reset_password_bloc.dart';
import 'package:azan_guru_mobile/common/custom_button.dart';
import 'package:azan_guru_mobile/common/custom_text_field.dart';
import 'package:azan_guru_mobile/common/util.dart';
import 'package:azan_guru_mobile/constant/app_assets.dart';
import 'package:azan_guru_mobile/constant/app_colors.dart';
import 'package:azan_guru_mobile/constant/font_style.dart';
import 'package:azan_guru_mobile/constant/language_key.dart';
import 'package:azan_guru_mobile/ui/common/loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _userNameController = TextEditingController();
  final FocusNode _emailNode = FocusNode();
  final ResetPasswordBloc resetPasswordBloc = ResetPasswordBloc();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBgColor,
      body: _textFieldView(context: context),
    );
  }

  Widget _textFieldView({required BuildContext context}) {
    return BlocConsumer<ResetPasswordBloc, ResetPasswordState>(
      bloc: resetPasswordBloc,
      listener: (context, state) {
        if (state is ResetPasswordLoadingState) {
          if (!AGLoader.isShown) {
            AGLoader.show(context);
          }
        } else if (state is ResetPasswordErrorState) {
          if (AGLoader.isShown) {
            AGLoader.hide();
          }
          showNormalDialog(context, state.errorMessage.toString());
        } else if (state is ResetPasswordSuccessState) {
          if (AGLoader.isShown) {
            AGLoader.hide();
          }
          hideKeyboard(context);
          _userNameController.clear();
          showNormalDialog(
            context,
            'An email has been sent to the registered email with the instructions to reset the password.',
          );
        }
      },
      builder: (context, state) {
        return KeyboardActions(
          autoScroll: false,
          config: getKeyboardActionsConfig(
            context,
            [
              _emailNode,
            ],
          ),
          child: Stack(
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 30.h),
                height: 230.h,
                width: Get.width,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Image.asset(
                    AssetImages.icRegisterBg,
                    height: 230.h,
                  ),
                ),
              ),
              Column(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top + 20,
                        left: 25.w,
                      ),
                      child: InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        onTap: () {
                          Get.back();
                        },
                        child: Container(
                          alignment: Alignment.center,
                          height: 20.w,
                          width: 20.w,
                          child: SvgPicture.asset(
                            AssetImages.icArrowBack,
                            fit: BoxFit.scaleDown,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 56.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 230.h),
                            Text(
                              LanguageKey.forgetPassword.tr,
                              textAlign: TextAlign.center,
                              style: AppFontStyle.poppinsMedium.copyWith(
                                fontSize: 25.sp,
                                color: AppColors.tittleTextColor,
                                height: 1.3,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 20.h),
                              child: CustomTextField(
                                controller: _userNameController,
                                focusNode: _emailNode,
                                hintTexts: LanguageKey.userNameOrEmail.tr,
                                textInputAction: TextInputAction.done,
                              ),
                            ),
                            SizedBox(height: 26.h),
                            customButton(
                              onTap: () {
                                hideKeyboard(context);
                                resetPasswordBloc.add(
                                  ResetUserPasswordEvent(
                                    username: _userNameController.text,
                                  ),
                                );
                              },
                              buttonText: LanguageKey.submit.tr.toUpperCase(),
                            ),
                            SizedBox(height: 30.h),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
