import 'package:azan_guru_mobile/bloc/my_subscription_bloc/my_subscription_bloc.dart';
import 'package:azan_guru_mobile/common/util.dart';
import 'package:azan_guru_mobile/constant/app_colors.dart';
import 'package:azan_guru_mobile/constant/font_style.dart';
import 'package:azan_guru_mobile/ui/common/loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class MySubscriptionScreen extends StatefulWidget {
  const MySubscriptionScreen({super.key});

  @override
  State<MySubscriptionScreen> createState() => _MySubscriptionScreenState();
}

class _MySubscriptionScreenState extends State<MySubscriptionScreen> {
  final MySubscriptionBloc bloc = MySubscriptionBloc();
  String isPaidUser = '-';
  @override
  void initState() {
    bloc.add(GetMySubscriptionEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MySubscriptionBloc, MySubscriptionState>(
      bloc: bloc,
      listener: (context, state) {
        if (state is GetMySubscriptionState) {
          isPaidUser = state.isPaidUser ? 'Yes' : 'No';
        } else if (state is MySubscriptionLoading) {
          if (state.isLoading) {
            AGLoader.show(context);
          } else {
            AGLoader.hide();
          }
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: customAppBar(
            showTitle: true,
            centerTitle: true,
            backgroundColor: AppColors.appBgColor,
            title: 'Enrollment History',
            showPrefixIcon: true,
            onClick: () {
              Get.back();
            },
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          'Paid User:',
                          style: AppFontStyle.dmSansBold.copyWith(
                            fontSize: 20.sp,
                            color: AppColors.black,
                          ),
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Expanded(
                        child: Text(
                          isPaidUser,
                          style: AppFontStyle.dmSansRegular.copyWith(
                            color: AppColors.lightBlack,
                            fontSize: 20.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          'Course Name:',
                          style: AppFontStyle.dmSansBold.copyWith(
                            fontSize: 20.sp,
                            color: AppColors.black,
                          ),
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Expanded(
                        child: Text(
                          '-',
                          style: AppFontStyle.dmSansRegular.copyWith(
                            color: AppColors.lightBlack,
                            fontSize: 20.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          'Course Validity:',
                          style: AppFontStyle.dmSansBold.copyWith(
                            fontSize: 20.sp,
                            color: AppColors.black,
                          ),
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Expanded(
                        child: Text(
                          '-',
                          style: AppFontStyle.dmSansRegular.copyWith(
                            color: AppColors.lightBlack,
                            fontSize: 20.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          'Amount:',
                          style: AppFontStyle.dmSansBold.copyWith(
                            fontSize: 20.sp,
                            color: AppColors.black,
                          ),
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Expanded(
                        child: Text(
                          '-',
                          style: AppFontStyle.dmSansRegular.copyWith(
                            color: AppColors.lightBlack,
                            fontSize: 20.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          'Extra features:',
                          style: AppFontStyle.dmSansBold.copyWith(
                            fontSize: 20.sp,
                            color: AppColors.black,
                          ),
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Expanded(
                        child: Text(
                          '-',
                          style: AppFontStyle.dmSansRegular.copyWith(
                            color: AppColors.lightBlack,
                            fontSize: 20.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
