import 'package:azan_guru_mobile/bloc/profile_module/delete_user_bloc/delete_user_bloc.dart';
import 'package:azan_guru_mobile/common/custom_button.dart';
import 'package:azan_guru_mobile/common/util.dart';
import 'package:azan_guru_mobile/constant/app_assets.dart';
import 'package:azan_guru_mobile/constant/app_colors.dart';
import 'package:azan_guru_mobile/constant/font_style.dart';
import 'package:azan_guru_mobile/route/app_routes.dart';
import 'package:azan_guru_mobile/service/local_storage/local_storage_keys.dart';
import 'package:azan_guru_mobile/service/local_storage/storage_manager.dart';
import 'package:azan_guru_mobile/ui/common/loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

class DeleteAccountDetailPage extends StatefulWidget {
  const DeleteAccountDetailPage({super.key});

  @override
  State<DeleteAccountDetailPage> createState() =>
      _DeleteAccountDetailPageState();
}

class _DeleteAccountDetailPageState extends State<DeleteAccountDetailPage> {
  List<String> deleteAccountContainsList = [
    'Your all personal information will be removed.',
    'Your all courses will be removed.',
  ];
  bool isSelected = false;
  DeleteUserBloc bloc = DeleteUserBloc();

  @override
  void initState() {
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
        title: 'Delete Account',
        showPrefixIcon: true,
        onClick: () {
          Get.back();
        },
      ),
      bottomNavigationBar: continueButton(),
      body: BlocConsumer<DeleteUserBloc, DeleteUserState>(
        bloc: bloc,
        listener: (context, state) {
          if (state is DeleteUserLoadingState) {
            AGLoader.show(context);
          } else if (state is DeleteUserErrorState) {
            AGLoader.hide();
            Fluttertoast.showToast(
              msg: 'Please accept over condition',
              backgroundColor: Colors.black,
              textColor: Colors.white,
            );
          } else if (state is DeleteUserSuccessState) {
            AGLoader.hide();
            Get.offAllNamed(Routes.login);
            StorageManager.instance
                .setBool(LocalStorageKeys.prefUserLogin, false);
            StorageManager.instance.clear();
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 25.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Image.asset(
                      AssetImages.deleteAccountPage,
                      width: 220,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.h),
                    child: Text(
                      "Are you sure, you want to delete your account?",
                      style: AppFontStyle.poppinsMedium.copyWith(
                        fontSize: 20.sp,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                  Text(
                    'If you delete your account :',
                    style: AppFontStyle.poppinsSemiBold.copyWith(
                      fontSize: 18.sp,
                      color: AppColors.black,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10.h, bottom: 30.h),
                    child: Column(
                      children: List.generate(
                        deleteAccountContainsList.length,
                        (index) => Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 3.h, horizontal: 8.w),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.only(top: 8.h, right: 10.w),
                                height: 8.0,
                                width: 8.0,
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.black),
                              ),
                              Expanded(
                                child: Text(
                                  deleteAccountContainsList[index],
                                  style: AppFontStyle.poppinsRegular.copyWith(
                                      color: AppColors.black, fontSize: 15.sp),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            isSelected = !isSelected;
                          });
                        },
                        child: Icon(
                          isSelected
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          size: 22.0,
                          color:
                              isSelected ? AppColors.green : AppColors.appBgColor,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          'I understand and accept all the above risks regarding my account deletion.',
                          textAlign: TextAlign.start,
                          style: AppFontStyle.poppinsMedium.copyWith(
                            fontSize: 15,
                            color: AppColors.black,
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget continueButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
      child: customButton(
        onTap: () {
          if (isSelected == true) {
            bloc.add(UserAccountDeleteEvent());
          } else {
            Fluttertoast.showToast(
              msg: 'Please accept over condition',
              backgroundColor: Colors.black,
              textColor: Colors.white,
            );
          }
        },
        boxColor: AppColors.appBgColor,
        child: Text(
          'Yes, Continue',
          textAlign: TextAlign.center,
          style: AppFontStyle.dmSansBold.copyWith(
            color: AppColors.white,
            fontSize: 17.sp,
          ),
        ),
      ),
    );
  }
}
