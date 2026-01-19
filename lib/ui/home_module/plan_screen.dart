import 'dart:developer';

import 'package:azan_guru_mobile/bloc/in_app_purchase_bloc/in_app_purchase_bloc.dart';
import 'package:azan_guru_mobile/common/custom_button.dart';
import 'package:azan_guru_mobile/common/util.dart';
import 'package:azan_guru_mobile/constant/app_colors.dart';
import 'package:azan_guru_mobile/constant/font_style.dart';
import 'package:azan_guru_mobile/ui/common/loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../bloc/profile_module/profile_bloc/profile_bloc.dart';
import '../../route/app_routes.dart';
import '../../service/local_storage/local_storage_keys.dart';
import '../../service/local_storage/storage_manager.dart';
import '../common/alert/normal_custom_alert.dart';

class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  List<ProductDetails> products = [];
  bool? loading = false;

  bool get isUserLoggedIn => user != null;
  String? courseId;
  bool? isHideBasicPlan;

  String get token =>
      StorageManager.instance.getString(LocalStorageKeys.prefAuthToken);
  ProfileBloc profileBloc = ProfileBloc();

  openCallingApp(String uri) async {
    launchUrlInExternalBrowser(uri);
  }

  @override
  void initState() {
    if (Get.arguments is List<dynamic>) {
      var data = Get.arguments as List<dynamic>;
      courseId = data[0];
      isHideBasicPlan = data[1];
      debugPrint('UserId ${user?.databaseId} Token $token ');
    }
    context.read<InAppPurchaseBloc>().add(LoadProducts());
    if (isUserLoggedIn) {
      profileBloc.add(GetProfileEvent());
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: customAppBar(
        showTitle: true,
        centerTitle: true,
        backgroundColor: AppColors.appBgColor,
        title: 'Choose Plan',
        showPrefixIcon: true,
        onClick: () {
          Get.back();
        },
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state is GetProfileState) {
              debugPrint('User Details ${state.user}');
            } else if (state is ProfileErrorState) {
              debugPrint('User Details ${state.errorMessage}');
            }
          },
          bloc: profileBloc,
          builder: (context, snapshot) {
            return BlocConsumer<InAppPurchaseBloc, InAppPurchaseState>(
              listener: (context2, state) {
                if (state is PurchaseLoadingState) {
                  if (!AGLoader.isShown || state.loading == true) {
                    AGLoader.show(context);
                  }
                  if (AGLoader.isShown || state.loading == false) {
                    AGLoader.hide();
                  }
                } else if (state is PurchaseErrorState) {
                  if (AGLoader.isShown) {
                    AGLoader.hide();
                  }
                  showNormalDialog(
                    context,
                    state.errorMessage ?? '',
                  );
                } else if (state is PurchaseSuccessState) {
                  if (AGLoader.isShown) {
                    AGLoader.hide();
                  }
                  Fluttertoast.showToast(msg: state.successMessage ?? '');
                  profileBloc.add(GetProfileEvent());
                } else if (state is InAppPurchaseLoading) {
                  if (!AGLoader.isShown) {
                    AGLoader.show(context);
                  }
                } else if (state is InAppPurchaseProcessingLoading) {
                  loading = state.isLoading;
                  loading == true ? AGLoader.show(context) : AGLoader.hide();
                } else if (state is InAppPurchaseError) {
                  if (AGLoader.isShown) {
                    AGLoader.hide();
                  }
                  if (state.showCancelButton == true) {
                    NormalCustomAlert.showAlert2(
                      state.message,
                      btnFirst: "Complete Purchase",
                      onTap: () {
                        Navigator.pop(context);
                      },
                      barrierDismissible: true,
                    );
                  } else {
                    showNormalDialog(
                      context,
                      state.message,
                    );
                  }

                  loading = false;
                  debugPrint(state.message);
                } else if (state is InAppPurchaseLoaded) {
                  products = state.products;
                  if (AGLoader.isShown) {
                    AGLoader.hide();
                  }
                } else if (state is PurchaseSuccess) {
                  if (AGLoader.isShown) {
                    AGLoader.hide();
                  }
                  profileBloc.add(GetProfileEvent());
                } else if (state is InAppPurchaseProcessing) {
                  if (AGLoader.isShown) {
                    AGLoader.hide();
                  }
                }
              },
              builder: (context, state) {
                return Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            return "ag_basic_plan" == products[index].id
                                ? isHideBasicPlan == true
                                    ? const SizedBox()
                                    : basicPlan(products[index])
                                : premiumPlan(products[index]);
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 4.0,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () {
                              openCallingApp(
                                  'https://azanguru.com/terms-condition/');
                            },
                            child: Text(
                              'Terms (EULA) & Conditions',
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
                              openCallingApp(
                                  'https://azanguru.com/privacy-policy/');
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
                        ],
                      ),
                      const SizedBox(
                        height: 4.0,
                      ),
                    ],
                  ),
                );
              },
            );
          }),
    );
  }

  Widget basicPlan(ProductDetails product) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardTextColor,
        borderRadius: BorderRadius.all(
          Radius.circular(10.r),
        ),
      ),
      padding: EdgeInsets.all(15.w),
      margin: EdgeInsets.symmetric(vertical: 15.w),
      // margin: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: Text(
              'Basic Plan',
              // product.title,
              textAlign: TextAlign.center,
              style: AppFontStyle.poppinsBold.copyWith(
                fontSize: 22.sp,
                color: AppColors.white,
              ),
            ),
          ),
          SizedBox(height: 5.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                product.price,
                // '999/',
                style: AppFontStyle.poppinsBold.copyWith(
                  fontSize: 22.sp,
                  color: AppColors.white,
                ),
              ),
              SizedBox(width: 5.w),
              Text(
                'One time',
                style: AppFontStyle.poppinsRegular.copyWith(
                  fontSize: 15.sp,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Text(
            '✓ Basic Quran Curriculum',
            style: AppFontStyle.poppinsRegular.copyWith(
              fontSize: 17.sp,
              color: AppColors.white,
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            '✓ 200+ Video Lessons and Assignments',
            style: AppFontStyle.poppinsRegular.copyWith(
              fontSize: 17.sp,
              color: AppColors.white,
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            '✓ Access to Forums and Groups',
            style: AppFontStyle.poppinsRegular.copyWith(
              fontSize: 17.sp,
              color: AppColors.white,
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            '✓ Standard Live Support',
            style: AppFontStyle.poppinsRegular.copyWith(
              fontSize: 17.sp,
              color: AppColors.white,
            ),
          ),
          SizedBox(height: 10.h),
          customButton(
            onTap: checkPlanAvailability(
                    user?.studentsOptions!.studentInappProductId ?? [],
                    'ag_basic_plan')
                ? null
                : () {
                    if (loading == false) {
                      context.read<InAppPurchaseBloc>().add(PurchaseProduct(
                            product,
                            user?.databaseId,
                            courseId,
                          ));
                    }
                  },
            boxColor: checkPlanAvailability(
                    user?.studentsOptions!.studentInappProductId ?? [],
                    'ag_basic_plan')
                ? AppColors.transparent
                : AppColors.alertButtonColor,
            child: Text(
              checkPlanAvailability(
                      user?.studentsOptions!.studentInappProductId ?? [],
                      'ag_basic_plan')
                  ? 'ALREADY PURCHASED'
                  : 'Buy Now'.toUpperCase(),
              textAlign: TextAlign.center,
              style: AppFontStyle.dmSansBold.copyWith(
                color: checkPlanAvailability(
                        user?.studentsOptions!.studentInappProductId ?? [],
                        'ag_basic_plan')
                    ? Colors.green
                    : AppColors.white,
                fontSize: 17.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool checkPlanAvailability(List<String> purchaseInfoList, String type) {
    if (purchaseInfoList.any((item) => item == type)) {
      return true;
    } else {
      return false;
    }
  }

  Widget premiumPlan(ProductDetails product) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.planBgColor,
        borderRadius: BorderRadius.all(Radius.circular(10.r)),
      ),
      padding: EdgeInsets.all(15.w),
      // margin: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: Text(
              'Subscription Plan',
              textAlign: TextAlign.center,
              style: AppFontStyle.poppinsBold.copyWith(
                fontSize: 22.sp,
                color: AppColors.cardTextColor,
              ),
            ),
          ),
          SizedBox(height: 5.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                // '599/',
                product.price,
                style: AppFontStyle.poppinsBold.copyWith(
                  fontSize: 22.sp,
                  color: AppColors.cardTextColor,
                ),
              ),
              SizedBox(width: 5.w),
              Text(
                'per month',
                style: AppFontStyle.poppinsRegular.copyWith(
                  fontSize: 15.sp,
                  color: AppColors.cardTextColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Text(
            '✓ All Included From Basic Plan',
            style: AppFontStyle.poppinsRegular.copyWith(
              fontSize: 17.sp,
              color: AppColors.cardTextColor,
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            '✓ Additional Live Classes',
            style: AppFontStyle.poppinsRegular.copyWith(
              fontSize: 17.sp,
              color: AppColors.cardTextColor,
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            '✓ Direct Teacher Interaction',
            style: AppFontStyle.poppinsRegular.copyWith(
              fontSize: 17.sp,
              color: AppColors.cardTextColor,
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            '✓ Instant Message Support',
            style: AppFontStyle.poppinsRegular.copyWith(
              fontSize: 17.sp,
              color: AppColors.cardTextColor,
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            '✓ Response to Daily Sabaq Recordings (Quick)',
            style: AppFontStyle.poppinsRegular.copyWith(
              fontSize: 17.sp,
              color: AppColors.cardTextColor,
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            '✓ Access to Forums and Groups',
            style: AppFontStyle.poppinsRegular.copyWith(
              fontSize: 17.sp,
              color: AppColors.cardTextColor,
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            '✓ Additional Homework and Assignments',
            style: AppFontStyle.poppinsRegular.copyWith(
              fontSize: 17.sp,
              color: AppColors.cardTextColor,
            ),
          ),
          SizedBox(height: 10.h),
          customButton(
            onTap: checkPlanAvailability(
                    user?.studentsOptions!.studentInappProductId ?? [],
                    'ag_subscription_plan')
                ? null
                : () {
                    if (loading == false) {
                      context.read<InAppPurchaseBloc>().add(
                            PurchaseProduct(
                              product,
                              user?.databaseId,
                              courseId,
                            ),
                          );
                    }
                  },
            boxColor: checkPlanAvailability(
                    user?.studentsOptions!.studentInappProductId ?? [],
                    'ag_subscription_plan')
                ? AppColors.transparent
                : AppColors.cardTextColor,
            child: Text(
              checkPlanAvailability(
                      user?.studentsOptions!.studentInappProductId ?? [],
                      'ag_subscription_plan')
                  ? 'ALREADY PURCHASED'
                  : 'Buy Now'.toUpperCase(),
              textAlign: TextAlign.center,
              style: AppFontStyle.dmSansBold.copyWith(
                color: checkPlanAvailability(
                        user?.studentsOptions!.studentInappProductId ?? [],
                        'ag_subscription_plan')
                    ? Colors.green
                    : AppColors.white,
                fontSize: 17.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
