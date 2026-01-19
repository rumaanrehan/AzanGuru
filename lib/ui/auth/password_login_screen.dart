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
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class PasswordLoginScreen extends StatefulWidget {
  const PasswordLoginScreen({super.key});

  @override
  State<PasswordLoginScreen> createState()
  => _PasswordLoginScreenState();
}

class _PasswordLoginScreenState extends State<PasswordLoginScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final LoginBloc loginBloc = LoginBloc();
  bool fromDeepLink = false;
  @override
  void initState() {
    super.initState();

    // Read values passed from deep link fallback:
    // Get.toNamed(Routes.login, arguments: { 'prefillEmail': ..., 'prefillPassword': ... });
    final args = Get.arguments;

    fromDeepLink = args is Map && args['fromDeepLink'] == true;

    if (args is Map) {
      final email = args['prefillEmail'] as String?;
      final pass  = args['prefillPassword'] as String?;

      if (email != null && email.isNotEmpty) {
        _nameController.text = email;
      }
      if (pass != null && pass.isNotEmpty) {
        _passwordController.text = pass;
      }

      // OPTIONAL: auto-submit if both are present
      Future.microtask(_submitLogin);
    }
  }

  void _submitLogin() {
    hideKeyboard(context);
    loginBloc.add(
      UserLoginEvent(
        mdlLoginParam: MDLLoginParam(
          userName: _nameController.text.trim(),
          password: _passwordController.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBgColor,
      body: _bodyView(context: context),
      bottomNavigationBar: _bottomContainer(context: context),
    );
  }

  Widget _bodyView({required BuildContext context}) {
    return BlocConsumer<LoginBloc, LoginState>(
      bloc: loginBloc,
      listener: (context, state) {
        if (state is LoginLoadingState) {
          if (mounted) AGLoader.show(context);
        } else if (state is LoginErrorState) {
          if (mounted) AGLoader.hide();
          showNormalDialog(context, state.errorMessage.toString());
        } else if (state is LoginSuccessState) {
          if (mounted) AGLoader.hide();

          final hasSub = StorageManager.instance.getBool(LocalStorageKeys.isUserHasSubscription);
          final hasPurchase = StorageManager.instance.getBool(LocalStorageKeys.isCoursePurchased);

          Get.offAllNamed(Routes.tabBarPage);
        }
      },
      builder: (context, state) {
        return Stack(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 56.w),
              child: _headerView(context: context),
            ),
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(right: 25.w),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top + 20,
                      ),
                      child: InkWell(
                        onTap: () {
                          hideKeyboard(context);
                          StorageManager.instance
                              .setBool(LocalStorageKeys.prefGuestLogin, true);
                          //Get.offAllNamed(Routes.tabBarPage);
                          Get.offAllNamed(Routes.selectCourse);

                        },
                        child: Text(
                          'Skip >>',
                          style: AppFontStyle.poppinsRegular.copyWith(
                            color: AppColors.white,
                          ),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        SizedBox(height: 320.w),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 56.w),
                          child: CustomTextField(
                            controller: _nameController,
                            hintTexts: LanguageKey.userNameOrEmail.tr,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 20.h, horizontal: 56.w),
                          child: CustomTextField(
                            controller: _passwordController,
                            textInputAction: TextInputAction.done,
                            hintTexts: LanguageKey.password.tr,
                            suffixIconShow: true,
                            obscureText: true,
                            onFieldSubmitted: (_) => _submitLogin(),
                          ),
                        ),
                        SizedBox(height: 5.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 56.w),
                          child: customButton(
                            onTap: _submitLogin,
                            buttonText: LanguageKey.loginNow.tr,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            top: 30.h,
                            bottom: 38.h,
                            left: 56.w,
                            right: 56.w,
                          ),
                          child: InkWell(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            onTap: () {
                              hideKeyboard(context);
                              Get.toNamed(Routes.resetPasswordPage);
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  LanguageKey.forgetPassword.tr,
                                  textAlign: TextAlign.center,
                                  style: AppFontStyle.poppinsRegular.copyWith(
                                    color: AppColors.white,
                                  ),
                                ),
                                // SizedBox(width: 5.w),
                                // SvgPicture.asset(
                                //   AssetImages.icArrowForword,
                                //   height: 12.h,
                                // ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 30.h),
                          child: InkWell(
                            onTap: () async {
                              hideKeyboard(context);
                              await StorageManager.getInstance().setBool(LocalStorageKeys.prefGuestLogin, true);
                              //Get.offAllNamed(Routes.tabBarPage);
                              Get.offAllNamed(Routes.selectCourse);
                            },
                            child: Text(
                              'Skip for now →',
                              style: AppFontStyle.poppinsBold.copyWith(
                                fontSize: 16.sp,
                                color: AppColors.greenBorderColor,
                                decoration: TextDecoration.underline,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _headerView({required BuildContext context}) {
    return Container(
      margin: EdgeInsets.only(bottom: 30.h),
      height: 400.h,
      width: Get.width,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Image.asset(
              AssetImages.icLoginBg,
              height: 400.h,
            ),
          ),
          Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 50.h, bottom: 25.h),
                alignment: Alignment.center,
                child: SvgPicture.asset(AssetImages.icLogo),
              ),
              Text(
                LanguageKey.loginToAzan.tr,
                textAlign: TextAlign.center,
                style: AppFontStyle.poppinsMedium.copyWith(
                  fontSize: 25.sp,
                  color: AppColors.tittleTextColor,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bottomContainer({required BuildContext context}) {
    return SafeArea(
      bottom: true,
      child: Container(
        height: 180.h,
        alignment: Alignment.bottomCenter,
        child: containerBoxDecoration(
          padding: EdgeInsets.only(
            left: 56.w,
            right: 56.w,
            top: 30.h,
            bottom: 30.h,
          ),
          child: Column(
            children: [
              Text(
                LanguageKey.doNotHaveAccount.tr,
                textAlign: TextAlign.center,
                style: AppFontStyle.poppinsRegular.copyWith(
                  fontSize: 18.sp,
                  color: AppColors.tittleTextColor,
                  height: 1.3,
                ),
              ),
              SizedBox(height: 20.h),
              customButton(
                onTap: () {
                  hideKeyboard(context);
                  Get.toNamed(Routes.registerPage);
                },
                boxColor: AppColors.bgColorBottom,
                borderColor: AppColors.greenBorderColor,
                showBorder: true,
                buttonText: LanguageKey.registerNow.tr.toUpperCase(),
              ),
            ],
          ),
        ),
      ),
    );
  }
  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

}
