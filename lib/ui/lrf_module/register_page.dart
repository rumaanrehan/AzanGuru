import 'dart:developer';

import 'package:azan_guru_mobile/bloc/lrf_module/register_module/user_register_bloc.dart';
import 'package:azan_guru_mobile/common/custom_button.dart';
import 'package:azan_guru_mobile/common/custom_text_field.dart';
import 'package:azan_guru_mobile/common/util.dart';
import 'package:azan_guru_mobile/constant/app_assets.dart';
import 'package:azan_guru_mobile/constant/app_colors.dart';
import 'package:azan_guru_mobile/constant/font_style.dart';
import 'package:azan_guru_mobile/constant/language_key.dart';
import 'package:azan_guru_mobile/route/app_routes.dart';
import 'package:azan_guru_mobile/ui/common/bottom_sheets/country_bottom_sheet.dart';
import 'package:azan_guru_mobile/ui/common/loader.dart';
// import 'package:azan_guru_mobile/ui/model/mdl_gender.dart';
import 'package:azan_guru_mobile/ui/model/mdl_login_param.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

import '../../bloc/lrf_module/login_module/login_bloc.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _firstNameController = TextEditingController();
  // final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  // final TextEditingController _passwordController = TextEditingController();
  // final TextEditingController _confirmPasswordController = TextEditingController();
  // final TextEditingController _ageController = TextEditingController();

  // final TextEditingController _countryController = TextEditingController();
  // final TextEditingController _cityController = TextEditingController();
  // final TextEditingController _pinCodeController = TextEditingController();
  // final TextEditingController _stateController = TextEditingController();
  final FocusNode _firstNamedNode = FocusNode();
  final FocusNode _lastNamedNode = FocusNode();
  final FocusNode _emailNode = FocusNode();
  final FocusNode _phoneNode = FocusNode();
  final FocusNode _passwordNode = FocusNode();
  final FocusNode _confirmPasswordNode = FocusNode();
  // final FocusNode _ageNode = FocusNode();

  // final FocusNode _cityNode = FocusNode();
  // final FocusNode _pinCodeNode = FocusNode();
  // List<String> mdlCountry = [
  //   'India',
  //   'US',
  //   'Canada',
  //   'Nepal',
  // ];
  // List<String> mdlState = [
  //   'MP',
  //   'UP',
  //   'GJ',
  //   'RJ',
  // ];
  // List<MDLGender> mdlGender = [
  //   MDLGender(tittle: 'Male'),
  //   MDLGender(tittle: 'Female'),
  // ];
  final UserRegisterBloc userRegisterBloc = UserRegisterBloc();
  // String? selectedGender;

  @override
  void initState() {
    super.initState();
    _phoneNumberController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    debugPrint("Text field value: ${_phoneNumberController.text}");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBgColor,
      body: _textFieldView(context: context),
      bottomNavigationBar: _bottomContainer(context: context),
    );
  }

  final LoginBloc loginBloc = LoginBloc();

  Widget _textFieldView({required BuildContext context}) {
    return BlocConsumer<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state is LoginLoadingState) {
            AGLoader.show(context);
          } else if (state is LoginErrorState) {
            AGLoader.hide();
            showNormalDialog(context, state.errorMessage.toString());
          } else if (state is LoginSuccessState) {
            AGLoader.hide();
            Get.offAllNamed(Routes.tabBarPage);
          }
        },
        bloc: loginBloc,
        builder: (context, snapshot) {
          return BlocConsumer<UserRegisterBloc, UserRegisterState>(
            bloc: userRegisterBloc,
            listener: (context, state) {
              if (state is UserRegisterLoadingState) {
                if (!AGLoader.isShown) {
                  AGLoader.show(context);
                }
              } else if (state is UserRegisterErrorState) {
                if (AGLoader.isShown) {
                  AGLoader.hide();
                }
                showNormalDialog(context, state.errorMessage.toString());
              } else if (state is UserRegisterSuccessState) {
                loginBloc.add(
                  UserLoginEvent(
                    mdlLoginParam: MDLLoginParam(
                      userName: state.email,
                      password: state.password,
                    ),
                  ),
                );
              }
            },
            builder: (context, state) {
              return KeyboardActions(
                autoScroll: false,
                config: getKeyboardActionsConfig(
                  context,
                  [
                    _firstNamedNode,
                    _lastNamedNode,
                    _emailNode,
                    _passwordNode,
                    _confirmPasswordNode,
                    // _ageNode,
                    _phoneNode,
                    // _cityNode,
                    // _pinCodeNode,
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
                    SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 56.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: 230.h),
                            Text(
                              LanguageKey.registerNow.tr,
                              // AppUtils.getLocaleText(
                              //     context, LanguageKey.registerNow),
                              textAlign: TextAlign.center,
                              style: AppFontStyle.poppinsMedium.copyWith(
                                fontSize: 25.sp,
                                color: AppColors.tittleTextColor,
                                height: 1.3,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 31.h, bottom: 18.h),
                              child: CustomTextField(
                                controller: _firstNameController,
                                hintTexts: "Full Name",
                                focusNode: _firstNamedNode,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                // AppUtils.getLocaleText(context, LanguageKey.fullName),
                              ),
                            ),
                            // CustomTextField(
                            //   controller: _lastNameController,
                            //   hintTexts: 'Last Name',
                            //   focusNode: _lastNamedNode,
                            //   textCapitalization: TextCapitalization.sentences,
                            //   // AppUtils.getLocaleText(context, LanguageKey.phoneNumber),
                            // ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 18.h),
                              child: CustomTextField(
                                keyBordType: TextInputType.emailAddress,
                                controller: _emailController,
                                focusNode: _emailNode,
                                hintTexts: LanguageKey.emailAddress.tr,
                              ),
                            ),
                            CustomTextField(
                              keyBordType: TextInputType.number,
                              controller: _phoneNumberController,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                              ],
                              focusNode: _phoneNode,
                              hintTexts: LanguageKey.phoneNumber.tr,
                            ),
                            SizedBox(height: 18.h),
                            if (_phoneNumberController.text.isNotEmpty) ...[
                              Text(
                                'Phone number - will be your password too (Changeable)',
                                style: AppFontStyle.poppinsRegular.copyWith(
                                  fontSize: 14.sp,
                                  color: AppColors.white,
                                  height: 1.3,
                                ),
                              ),
                              SizedBox(height: 18.h),
                            ],
                            // CustomTextField(
                            //   controller: _passwordController,
                            //   focusNode: _passwordNode,
                            //   hintTexts: LanguageKey.password.tr,
                            //   suffixIconShow: true,
                            //   obscureText: true,
                            //   onFieldSubmitted: (p0) {
                            //     _confirmPasswordNode.requestFocus();
                            //   },
                            // ),
                            // Padding(
                            //   padding: EdgeInsets.symmetric(vertical: 18.h),
                            //   child: CustomTextField(
                            //     controller: _confirmPasswordController,
                            //     focusNode: _confirmPasswordNode,
                            //     hintTexts: LanguageKey.confirmPassword.tr,
                            //     suffixIconShow: true,
                            //     obscureText: true,
                            //     onFieldSubmitted: (p0) {
                            //       // _ageNode.requestFocus();
                            //     },
                            //   ),
                            // ),
                            // CustomTextField(
                            //   controller: _ageController,
                            //   focusNode: _ageNode,
                            //   hintTexts: 'Age',
                            //   textInputAction: TextInputAction.done,
                            // ),
                            // Padding(
                            //   padding: EdgeInsets.only(
                            //     top: 28.h,
                            //     bottom: 10.h,
                            //     left: 10.w,
                            //   ),
                            //   child: Row(
                            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //     children: [
                            //       Text(
                            //         'Gender',
                            //         style: AppFontStyle.poppinsRegular
                            //             .copyWith(color: AppColors.white),
                            //       ),
                            //       Expanded(
                            //         child: GridView.builder(
                            //           padding: EdgeInsets.only(left: 40.w),
                            //           shrinkWrap: true,
                            //           physics: const NeverScrollableScrollPhysics(),
                            //           itemCount: mdlGender.length,
                            //           gridDelegate:
                            //               SliverGridDelegateWithFixedCrossAxisCount(
                            //             crossAxisCount: 2,
                            //             crossAxisSpacing: 0,
                            //             mainAxisSpacing: 0,
                            //             mainAxisExtent: 25.h,
                            //           ),
                            //           itemBuilder: (BuildContext context, int index) {
                            //             return _genderSelectionRow(
                            //               onTap: () {
                            //                 for (int i = 0;
                            //                     i < mdlGender.length;
                            //                     i++) {
                            //                   mdlGender[i].isSelected = false;
                            //                 }
                            //                 setState(() {
                            //                   mdlGender[index].isSelected = true;
                            //                   selectedGender =
                            //                       mdlGender[index].tittle;
                            //                 });
                            //               },
                            //               data: mdlGender[index],
                            //             );
                            //           },
                            //         ),
                            //       )
                            //     ],
                            //   ),
                            // ),
                            // Padding(
                            //   padding: EdgeInsets.symmetric(vertical: 18.h),
                            //   child: CustomTextField(
                            //     controller: _countryController,
                            //     hintTexts: 'Country ',
                            //     readOnly: true,
                            //     suffixOnTap: () {
                            //       showCountryStateBottomSheet(
                            //         tittle: 'Select Country',
                            //         list: mdlCountry,
                            //         textEditingController: _countryController,
                            //       );
                            //     },
                            //     suffixIconWidget: Container(
                            //       height: Get.height,
                            //       padding: EdgeInsets.only(right: 20.w),
                            //       child: SvgPicture.asset(
                            //         AssetImages.icArrowDown,
                            //         colorFilter: const ColorFilter.mode(
                            //           AppColors.white,
                            //           BlendMode.srcIn,
                            //         ),
                            //         height: 8.h,
                            //       ),
                            //     ),
                            //   ),
                            // ),
                            // CustomTextField(
                            //   controller: _stateController,
                            //   hintTexts: 'State',
                            //   readOnly: true,
                            //   suffixOnTap: () {
                            //     showCountryStateBottomSheet(
                            //       tittle: 'Select State',
                            //       list: mdlState,
                            //       textEditingController: _stateController,
                            //     );
                            //   },
                            //   suffixIconWidget: Container(
                            //     height: Get.height,
                            //     padding: EdgeInsets.only(right: 20.w),
                            //     child: SvgPicture.asset(
                            //       AssetImages.icArrowDown,
                            //       colorFilter: const ColorFilter.mode(
                            //         AppColors.white,
                            //         BlendMode.srcIn,
                            //       ),
                            //       height: 8.h,
                            //     ),
                            //   ),
                            // ),
                            // Padding(
                            //   padding: EdgeInsets.symmetric(vertical: 18.h),
                            //   child: CustomTextField(
                            //     controller: _cityController,
                            //     focusNode: _cityNode,
                            //     hintTexts: 'City',
                            //   ),
                            // ),
                            // CustomTextField(
                            //   controller: _pinCodeController,
                            //   focusNode: _pinCodeNode,
                            //   hintTexts: 'Pincode',
                            //   textInputAction: TextInputAction.done,
                            //   onFieldSubmitted: (val) {
                            //     userRegisterBloc.add(
                            //       RegisterUserEvent(
                            //         mdlUserRegisterParam: MDLUserRegisterParam(
                            //           firstName: _firstNameController.text.trim(),
                            //           lastName: _lastNameController.text.trim(),
                            //           email: _emailController.text.trim(),
                            //           password: _passwordController.text.trim(),
                            //           confirmPassword:
                            //               _confirmPasswordController.text.trim(),
                            //           studentAge: _ageController.text.isEmpty
                            //               ? 0
                            //               : int.tryParse(_ageController.text.trim()),
                            //           studentGander: selectedGender ?? '',
                            //           // country: _countryController.text.trim(),
                            //           // state: _stateController.text.trim(),
                            //           // city: _cityController.text.trim(),
                            //           // pinCode: _pinCodeController.text.trim(),
                            //         ),
                            //       ),
                            //     );
                            //   },
                            // ),
                            SizedBox(height: 26.h),
                            customButton(
                              onTap: () {
                                hideKeyboard(context);
                                userRegisterBloc.add(
                                  RegisterUserEvent(
                                    mdlUserRegisterParam: MDLUserRegisterParam(
                                      firstName:
                                          _firstNameController.text.trim(),
                                      // lastName: _lastNameController.text.trim(),
                                      email: _emailController.text.trim(),
                                      phoneNumber:
                                          _phoneNumberController.text.trim(),
                                      password:
                                          _phoneNumberController.text.trim(),
                                      confirmPassword:
                                          _phoneNumberController.text.trim(),
                                      // studentAge: _ageController.text.isEmpty
                                      //     ? 0
                                      //     : int.tryParse(_ageController.text.trim()),
                                      // studentGander: selectedGender,
                                      // country: _countryController.text.trim(),
                                      // state: _stateController.text.trim(),
                                      // city: _cityController.text.trim(),
                                      // pinCode: _pinCodeController.text.trim(),
                                    ),
                                  ),
                                );
                              },
                              buttonText:
                                  LanguageKey.registerNow.tr.toUpperCase(),
                            ),
                            SizedBox(height: 30.h),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        });
  }

  Widget _bottomContainer({required BuildContext context}) {
    return Container(
      height: 165.h,
      alignment: Alignment.bottomCenter,
      child: containerBoxDecoration(
        padding:
            EdgeInsets.only(left: 56.w, right: 56.w, top: 18.h, bottom: 35.h),
        child: Column(
          children: [
            Text(
              LanguageKey.alreadyHaveAccount.tr,
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
                Get.offAllNamed(Routes.login);
              },
              boxColor: AppColors.bgColorBottom,
              borderColor: AppColors.greenBorderColor,
              showBorder: true,
              buttonText: LanguageKey.login.tr.toUpperCase(),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _genderSelectionRow({Function()? onTap, MDLGender? data}) {
  //   return InkWell(
  //     splashColor: Colors.transparent,
  //     hoverColor: Colors.transparent,
  //     highlightColor: Colors.transparent,
  //     focusColor: Colors.transparent,
  //     onTap: onTap,
  //     child: Row(
  //       children: [
  //         Container(
  //           width: 22.w,
  //           height: 22.h,
  //           margin: EdgeInsets.only(right: 10.w),
  //           decoration: BoxDecoration(
  //             color: data?.isSelected ?? false ? AppColors.white : Colors.transparent,
  //             shape: BoxShape.circle,
  //             border: Border.all(
  //               width: 3.w,
  //               color: AppColors.white,
  //             ),
  //           ),
  //         ),
  //         Text(
  //           data?.tittle ?? "",
  //           style: AppFontStyle.poppinsRegular.copyWith(color: AppColors.white),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  showCountryStateBottomSheet({
    required TextEditingController textEditingController,
    List<String>? list,
    required String tittle,
  }) {
    hideKeyboard(context);
    Get.bottomSheet(
      CountryBottomSheet(
        title: tittle,
        list: list ?? [],
        handler: (val) {
          textEditingController.text = val.toString();
          setState(() {});
        },
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }
}
