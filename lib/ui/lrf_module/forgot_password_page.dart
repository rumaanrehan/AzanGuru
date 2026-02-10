import 'package:azan_guru_mobile/bloc/lrf_module/forgot_password_bloc/forgot_password_bloc.dart';
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

enum ForgotPasswordStep { email, otp, newPassword }

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final FocusNode _emailNode = FocusNode();
  final FocusNode _otpNode = FocusNode();
  final FocusNode _passwordNode = FocusNode();
  final FocusNode _confirmPasswordNode = FocusNode();

  final ForgotPasswordBloc forgotPasswordBloc = ForgotPasswordBloc();

  ForgotPasswordStep _currentStep = ForgotPasswordStep.email;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  String _otpToken = '';

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailNode.dispose();
    _otpNode.dispose();
    _passwordNode.dispose();
    _confirmPasswordNode.dispose();
    forgotPasswordBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBgColor,
      body: _buildMainView(context),
    );
  }

  Widget _buildMainView(BuildContext context) {
    return BlocConsumer<ForgotPasswordBloc, ForgotPasswordState>(
      bloc: forgotPasswordBloc,
      listener: (context, state) {
        if (state is ForgotPasswordLoadingState) {
          if (!AGLoader.isShown) {
            AGLoader.show(context);
          }
        } else if (state is ForgotPasswordErrorState) {
          if (AGLoader.isShown) {
            AGLoader.hide();
          }
          showNormalDialog(context, state.errorMessage.toString());
        } else if (state is ForgotPasswordOtpSentState) {
          if (AGLoader.isShown) {
            AGLoader.hide();
          }
          setState(() {
            _currentStep = ForgotPasswordStep.otp;
          });
          showNormalDialog(
            context,
            'OTP has been sent to your email. Please check your inbox.',
          );
        } else if (state is ForgotPasswordOtpVerifiedState) {
          if (AGLoader.isShown) {
            AGLoader.hide();
          }
          _otpToken = state.otpToken;
          setState(() {
            _currentStep = ForgotPasswordStep.newPassword;
          });
          showNormalDialog(
            context,
            'OTP verified successfully! Please enter your new password.',
          );
        } else if (state is ForgotPasswordSuccessState) {
          if (AGLoader.isShown) {
            AGLoader.hide();
          }
          hideKeyboard(context);
          _emailController.clear();
          _otpController.clear();
          _passwordController.clear();
          _confirmPasswordController.clear();
          showNormalDialog(
            context,
            state.message,
          );
          // Navigate back after a short delay
          Future.delayed(const Duration(seconds: 1), () {
            Get.back();
          });
        }
      },
      builder: (context, state) {
        return KeyboardActions(
          autoScroll: false,
          config: getKeyboardActionsConfig(
            context,
            [
              _emailNode,
              _otpNode,
              _passwordNode,
              _confirmPasswordNode,
            ],
          ),
          child: Stack(
            children: [
              /// Background image
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
              /// Main content
              Column(
                children: [
                  /// Back button
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
                  /// Scrollable content
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 56.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 230.h),
                            _buildStepIndicator(),
                            SizedBox(height: 30.h),
                            if (_currentStep == ForgotPasswordStep.email)
                              _buildEmailStep(context)
                            else if (_currentStep == ForgotPasswordStep.otp)
                              _buildOtpStep(context)
                            else if (_currentStep == ForgotPasswordStep.newPassword)
                              _buildNewPasswordStep(context),
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

  Widget _buildStepIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LanguageKey.forgetPassword.tr,
          style: AppFontStyle.poppinsMedium.copyWith(
            fontSize: 25.sp,
            color: AppColors.tittleTextColor,
            height: 1.3,
          ),
        ),
        SizedBox(height: 10.h),
        Text(
          _getStepDescription(),
          style: AppFontStyle.poppinsRegular.copyWith(
            fontSize: 13.sp,
            color: AppColors.lightGrey,
          ),
        ),
      ],
    );
  }

  String _getStepDescription() {
    switch (_currentStep) {
      case ForgotPasswordStep.email:
        return 'Step 1 of 3: Enter your email address';
      case ForgotPasswordStep.otp:
        return 'Step 2 of 3: Verify the OTP sent to your email';
      case ForgotPasswordStep.newPassword:
        return 'Step 3 of 3: Set your new password';
    }
  }

  Widget _buildEmailStep(BuildContext context) {
    return Column(
      children: [
        CustomTextField(
          controller: _emailController,
          focusNode: _emailNode,
          hintTexts: LanguageKey.emailAddress.tr,
          textInputAction: TextInputAction.done,
          keyBordType: TextInputType.emailAddress,
        ),
        SizedBox(height: 26.h),
        customButton(
          onTap: () {
            hideKeyboard(context);
            forgotPasswordBloc.add(
              SendForgotPasswordOtpEvent(
                email: _emailController.text.trim(),
              ),
            );
          },
          buttonText: 'SEND OTP',
        ),
      ],
    );
  }

  Widget _buildOtpStep(BuildContext context) {
    return Column(
      children: [
        Text(
          'Enter the OTP sent to ${_emailController.text}',
          style: AppFontStyle.poppinsRegular.copyWith(
            fontSize: 12.sp,
            color: AppColors.lightGrey,
          ),
        ),
        SizedBox(height: 15.h),
        CustomTextField(
          controller: _otpController,
          focusNode: _otpNode,
          hintTexts: 'OTP',
          textInputAction: TextInputAction.done,
          keyBordType: TextInputType.number,
        ),
        SizedBox(height: 20.h),
        Row(
          children: [
            Expanded(
              child: customButton(
                onTap: () {
                  setState(() {
                    _currentStep = ForgotPasswordStep.email;
                  });
                },
                buttonText: 'BACK',
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: customButton(
                onTap: () {
                  hideKeyboard(context);
                  forgotPasswordBloc.add(
                    VerifyForgotPasswordOtpEvent(
                      email: _emailController.text.trim(),
                      otp: _otpController.text.trim(),
                    ),
                  );
                },
                buttonText: 'VERIFY',
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Center(
          child: GestureDetector(
            onTap: () {
              forgotPasswordBloc.add(
                SendForgotPasswordOtpEvent(
                  email: _emailController.text.trim(),
                ),
              );
            },
            child: Text(
              'Resend OTP',
              style: AppFontStyle.poppinsRegular.copyWith(
                fontSize: 12.sp,
                color: AppColors.primaryColor,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNewPasswordStep(BuildContext context) {
    return Column(
      children: [
        CustomTextField(
          controller: _passwordController,
          focusNode: _passwordNode,
          hintTexts: LanguageKey.password.tr,
          textInputAction: TextInputAction.next,
          obscureText: !_passwordVisible,
          suffixIconWidget: GestureDetector(
            onTap: () {
              setState(() {
                _passwordVisible = !_passwordVisible;
              });
            },
            child: Padding(
              padding: EdgeInsets.only(right: 15.w),
              child: Icon(
                _passwordVisible ? Icons.visibility : Icons.visibility_off,
                color: AppColors.lightGrey,
              ),
            ),
          ),
        ),
        SizedBox(height: 16.h),
        CustomTextField(
          controller: _confirmPasswordController,
          focusNode: _confirmPasswordNode,
          hintTexts: LanguageKey.confirmPassword.tr,
          textInputAction: TextInputAction.done,
          obscureText: !_confirmPasswordVisible,
          suffixIconWidget: GestureDetector(
            onTap: () {
              setState(() {
                _confirmPasswordVisible = !_confirmPasswordVisible;
              });
            },
            child: Padding(
              padding: EdgeInsets.only(right: 15.w),
              child: Icon(
                _confirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: AppColors.lightGrey,
              ),
            ),
          ),
        ),
        SizedBox(height: 16.h),
        if (_passwordController.text != _confirmPasswordController.text &&
            _confirmPasswordController.text.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: Text(
              'Passwords do not match',
              style: AppFontStyle.poppinsRegular.copyWith(
                fontSize: 12.sp,
                color: Colors.red,
              ),
            ),
          ),
        SizedBox(height: 26.h),
        Row(
          children: [
            Expanded(
              child: customButton(
                onTap: () {
                  setState(() {
                    _currentStep = ForgotPasswordStep.otp;
                  });
                },
                buttonText: 'BACK',
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: customButton(
                onTap: () {
                  if (_passwordController.text !=
                      _confirmPasswordController.text) {
                    showNormalDialog(context, 'Passwords do not match');
                    return;
                  }
                  hideKeyboard(context);
                  forgotPasswordBloc.add(
                    UpdateForgotPasswordEvent(
                      email: _emailController.text.trim(),
                      newPassword: _passwordController.text,
                      otpToken: _otpToken,
                    ),
                  );
                },
                buttonText: 'RESET PASSWORD',
              ),
            ),
          ],
        ),
      ],
    );
  }
}
