import 'dart:async';
import 'package:azan_guru_mobile/bloc/lrf_module/login_module/login_bloc.dart';
import 'package:azan_guru_mobile/common/custom_button.dart';
import 'package:azan_guru_mobile/common/custom_text_field.dart';
import 'package:azan_guru_mobile/common/util.dart';
import 'package:azan_guru_mobile/constant/app_assets.dart';
import 'package:azan_guru_mobile/constant/app_colors.dart';
import 'package:azan_guru_mobile/constant/font_style.dart';
import 'package:azan_guru_mobile/constant/language_key.dart';
import 'package:azan_guru_mobile/route/app_routes.dart';
import 'package:azan_guru_mobile/service/local_storage/local_storage_keys.dart';
import 'package:azan_guru_mobile/service/local_storage/storage_manager.dart';
import 'package:azan_guru_mobile/ui/common/loader.dart';
import 'package:azan_guru_mobile/ui/model/mdl_login_param.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

enum LoginMode { otp, password }

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Blocs and Controllers
  final LoginBloc loginBloc = LoginBloc();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  // State
  LoginMode _mode = LoginMode.otp;
  bool otpSent = false;
  bool fromDeepLink = false;
  Timer? _resendTimer;
  int _resendCooldown = 30;

  @override
  void initState() {
    super.initState();
    final lastMode = StorageManager.instance.getString('last_login_mode');
    _mode = (lastMode == LoginMode.password.name) ? LoginMode.password : LoginMode.otp;

    final args = Get.arguments;
    fromDeepLink = args is Map && args['fromDeepLink'] == true;
    if (args is Map) {
      _emailController.text = args['prefillEmail'] ?? '';
      _passwordController.text = args['prefillPassword'] ?? '';
    }
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    AGLoader.hide();
    super.dispose();
  }

  void _startResendTimer() {
    _resendCooldown = 30;
    _resendTimer?.cancel(); // Cancel any existing timer
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCooldown > 0) {
        setState(() => _resendCooldown--);
      } else {
        timer.cancel();
      }
    });
  }

  void _sendOtp() {
    if (_phoneController.text.length != 10) {
      showNormalDialog(context, 'Enter a valid 10-digit mobile number');
      return;
    }
    hideKeyboard(context);
    if (AGLoader.isShown) {
      AGLoader.hide();
    }
    AGLoader.show(context);
    loginBloc.add(SendOtpEvent(mobile: _phoneController.text.trim()));
    _startResendTimer();
  }

  void _verifyOtp() {
    hideKeyboard(context);
    if (AGLoader.isShown) {
      AGLoader.hide();
    }
    AGLoader.show(context);
    loginBloc.add(
      LoginWithOtpEvent(
        mobile: _phoneController.text.trim(),
        otp: _otpController.text.trim(),
      ),
    );
  }

  void _submitPasswordLogin() {
    hideKeyboard(context);
    if (AGLoader.isShown) {
      AGLoader.hide();
    }
    AGLoader.show(context);
    loginBloc.add(
      UserLoginEvent(
        mdlLoginParam: MDLLoginParam(
          userName: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBgColor,
      resizeToAvoidBottomInset: true,
      body: BlocConsumer<LoginBloc, LoginState>(
        bloc: loginBloc,
        listener: (context, state) {
          if (state is LoginLoadingState) {
            if (!AGLoader.isShown) {
              AGLoader.show(context);
            }
          } else if (state is LoginErrorState) {
            if (AGLoader.isShown) {
              AGLoader.hide();
            }
            showNormalDialog(context, state.errorMessage.toString());
          } else if (state is LoginOtpSentState) {
            if (AGLoader.isShown) {
              AGLoader.hide();
            }
            setState(() => otpSent = true);
          } else if (state is LoginSuccessState) {
            if (AGLoader.isShown) {
              AGLoader.hide();
            }
            
            // Use state data directly instead of StorageManager to avoid sync issues
            Get.offAllNamed(Routes.tabBarPage);
          }
        },
        builder: (_, __) => _body(),
      ),
    );
  }

  Widget _body() {
    return Stack(
      children: [
        Positioned.fill(
          child: Align(
            alignment: Alignment.topCenter,
            child: Image.asset(AssetImages.icLoginBg, fit: BoxFit.fitWidth),
          ),
        ),
        Column(
          children: [
            _skipButton(),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 56.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(AssetImages.icLogo),
                        SizedBox(height: 20.h),
                        Text(
                          "Login/Register with:",
                          textAlign: TextAlign.center,
                          style: AppFontStyle.poppinsMedium.copyWith(
                            fontSize: 25.sp,
                            color: AppColors.tittleTextColor,
                          ),
                        ),
                        SizedBox(height: 20.h),
                        _modeToggle(),
                        SizedBox(height: 30.h),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: _mode == LoginMode.password ? _passwordForm() : _otpForm(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _modeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _tab('OTP', LoginMode.otp),
          _tab('Password', LoginMode.password),
        ],
      ),
    );
  }

  Widget _tab(String title, LoginMode mode) {
    final active = _mode == mode;
    return GestureDetector(
      onTap: () {
        setState(() {
          _mode = mode;
          otpSent = false;
        });
        StorageManager.instance.setString('last_login_mode', mode.name);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: active ? AppColors.greenBorderColor : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Text(
          title,
          style: AppFontStyle.poppinsMedium.copyWith(
            color: active ? Colors.white : Colors.white70,
          ),
        ),
      ),
    );
  }

  Widget _passwordForm() {
    return Column(
      key: const ValueKey('password'),
      children: [
        CustomTextField(
          controller: _emailController,
          hintTexts: LanguageKey.userNameOrEmail.tr,
        ),
        SizedBox(height: 20.h),
        CustomTextField(
          controller: _passwordController,
          obscureText: true,
          hintTexts: LanguageKey.password.tr,
        ),
        SizedBox(height: 20.h),
        customButton(
          onTap: _submitPasswordLogin,
          buttonText: LanguageKey.loginNow.tr,
        ),
      ],
    );
  }

  Widget _otpForm() {
    const inputStyle = TextStyle(color: Colors.white, fontSize: 16);
    const hintStyle = TextStyle(color: Colors.white70);
    const border = OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white38),
      borderRadius: BorderRadius.all(Radius.circular(8)),
    );

    return Column(
      key: const ValueKey('otp'),
      children: [
        if (!otpSent) ...[
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.number,
            cursorColor: Colors.white,
            style: inputStyle,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            decoration: const InputDecoration(
              hintText: 'Mobile Number',
              hintStyle: hintStyle,
              enabledBorder: border,
              focusedBorder: border,
            ),
          ),
          SizedBox(height: 20.h),
          customButton(onTap: _sendOtp, buttonText: 'Send OTP'),
        ] else ...[
          Text(
            'OTP sent to +91 ${_phoneController.text}',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          SizedBox(height: 10.h),
          GestureDetector(
            onTap: () => setState(() => otpSent = false),
            child: const Text(
              'Edit Details',
              style: TextStyle(color: Colors.white, decoration: TextDecoration.underline),
            ),
          ),
          SizedBox(height: 20.h),
          TextField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            cursorColor: Colors.white,
            style: inputStyle,
            textAlign: TextAlign.center,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            decoration: const InputDecoration(
              hintText: 'Enter OTP',
              hintStyle: hintStyle,
              enabledBorder: border,
              focusedBorder: border,
            ),
          ),
          SizedBox(height: 20.h),
          customButton(onTap: _verifyOtp, buttonText: 'Verify & Login/Register'),
          SizedBox(height: 20.h),
          _resendButton(),
        ],
      ],
    );
  }

  Widget _resendButton() {
    bool canResend = _resendCooldown == 0;
    return TextButton(
      onPressed: canResend ? _sendOtp : null,
      child: Text(
        canResend ? 'Resend OTP' : 'Resend OTP in $_resendCooldown seconds',
        style: TextStyle(color: canResend ? Colors.white : Colors.grey),
      ),
    );
  }

  Widget _skipButton() {
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        right: 25.w,
      ),
      child: Align(
        alignment: Alignment.topRight,
        child: InkWell(
          onTap: () {
            StorageManager.instance.setBool(LocalStorageKeys.prefGuestLogin, true);
            Get.offAllNamed(Routes.selectCourse);
          },
          child: Text(
            'Skip >>',
            style: AppFontStyle.poppinsRegular.copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
