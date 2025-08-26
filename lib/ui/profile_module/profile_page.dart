import 'dart:developer';

import 'package:azan_guru_mobile/bloc/profile_module/profile_bloc/profile_bloc.dart';
import 'package:azan_guru_mobile/common/custom_button.dart';
import 'package:azan_guru_mobile/common/util.dart';
import 'package:azan_guru_mobile/constant/app_assets.dart';
import 'package:azan_guru_mobile/constant/app_colors.dart';
import 'package:azan_guru_mobile/constant/font_style.dart';
import 'package:azan_guru_mobile/ui/common/loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

import '../model/mdl_gender.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  ProfileBloc profileBloc = ProfileBloc();
  TextEditingController nameCtrl = TextEditingController();
  TextEditingController emailCtrl = TextEditingController();
  TextEditingController phoneCtrl = TextEditingController();
  TextEditingController langCtrl = TextEditingController();

  bool get isUserLoggedIn => user != null;

  @override
  void initState() {
    super.initState();
    if (isUserLoggedIn) {
      profileBloc.add(GetProfileEvent());
    }
  }

  showUserProfile() {
    if (isUserLoggedIn) {
      debugPrint(
          "isUserLoggedIn>>>>>>> ${user?.generalUserOptions?.phoneNumber}");
      nameCtrl.text =
          (user?.firstName?.isEmpty ?? true) ? "" : "${user?.firstName}";
      emailCtrl.text = user?.email ?? "";
      phoneCtrl.text = user?.generalUserOptions?.phoneNumber.toString() ?? '';
      langCtrl.text = user?.locale == "en_US" ? "English" : "";
      selectedGender = user?.gender ?? "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        showTitle: true,
        centerTitle: true,
        backgroundColor: AppColors.appBgColor,
        title: 'My Profile',
        showPrefixIcon: true,
        onClick: () {
          Get.back();
        },
        // suffixIcons: [
        //   // customIcon(onClick: () {}, icon: AssetImages.icSetting),
        //   Padding(
        //     padding: EdgeInsets.only(left: 25.w, right: 23.w),
        //     child: customIcon(
        //         onClick: () {
        //           Get.toNamed(Routes.notificationPage);
        //         },
        //         icon: AssetImages.icNotification,
        //         iconColor: AppColors.white),
        //   ),
        // ],
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        bloc: profileBloc,
        listener: (context, state) {
          if (state is ProfileLoadingState) {
            if (!AGLoader.isShown) {
              AGLoader.show(context);
            }
          } else if (state is ProfileErrorState) {
            if (AGLoader.isShown) {
              AGLoader.hide();
            }
            showNormalDialog(
              context,
              state.errorMessage.toString(),
              handler: state.isOpenSetting == true
                  ? (i) {
                      Navigator.pop(context);
                      openAppSettings();
                    }
                  : null,
              btnFirst: state.isOpenSetting == true ? 'Open Setting' : null,
              barrierDismissible: state.isOpenSetting == true ? true : false,
            );
          } else if (state is ResetPasswordSuccessState) {
            if (AGLoader.isShown) {
              AGLoader.hide();
            }
            showNormalDialog(
              context,
              'An email has been sent to the registered email with the instructions to reset the password.',
            );
          } else if (state is ProfileSuccessState) {
            if (AGLoader.isShown) {
              AGLoader.hide();
            }
            Fluttertoast.showToast(msg: 'User profile updated successfully');

            profileBloc.add(GetProfileEvent());
          } else if (state is GetProfileState) {
            if (AGLoader.isShown) {
              AGLoader.hide();
            }
            selectedGender = state.user?.gender ?? '';
            showUserProfile();
          } else if (state is ImagePickerLoaded) {
            if (AGLoader.isShown) {
              AGLoader.hide();
            }
            Fluttertoast.showToast(
                msg: 'User profile picture updated successfully.');
            showUserProfile();
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              SizedBox(height: 20.h),
              _profileView(),
              SizedBox(height: 20.h),
              detailView(),
              SizedBox(height: 20.h),
              // Expanded(
              //   child: Stack(
              //     alignment: Alignment.center,
              //     children: [
              //       Align(
              //         alignment: Alignment.topCenter,
              //         child: _backgroundView(),
              //       ),
              //       if (isUserLoggedIn) ...[
              //         Column(
              //           children: [
              //             SizedBox(height: 230.h),
              //             detailView(),
              //           ],
              //         ),
              //         _profileView(),
              //       ],
              //     ],
              //   ),
              // ),
              // SizedBox(height: 120.h)
            ],
          );
        },
      ),
    );
  }

  // Widget _backgroundView() {
  //   return customTopContainer(
  //     bgImage: AssetImages.icBgProfile,
  //     height: 260.h,
  //     insideChild: customAppBar(
  //       showTitle: true,
  //       centerTitle: true,
  //       title: 'Profile',
  //       suffixIcons: [
  //         customIcon(
  //           onClick: () {
  //             Get.toNamed(Routes.menuPage);
  //           },
  //           icon: AssetImages.icMenu,
  //           iconColor: AppColors.white,
  //         ),
  //         Padding(
  //           padding: EdgeInsets.only(left: 25.w, right: 23.w),
  //           child: customIcon(
  //             onClick: () {
  //               Get.toNamed(Routes.notificationPage);
  //             },
  //             icon: AssetImages.icNotification,
  //             iconColor: AppColors.white,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _profileView() {
    return Stack(
      children: [
        Container(
          alignment: Alignment.center,
          width: 145.h,
          height: 145.h,
          decoration: ShapeDecoration(
            color: AppColors.white,
            shape: OvalBorder(
              side: BorderSide(width: 1.w, color: AppColors.profileBorderColor),
            ),
          ),
          child: (user?.studentsOptions != null) &&
                  (user?.studentsOptions?.studentPicture != null) &&
                  (user?.studentsOptions?.studentPicture?.node != null) &&
                  (user?.studentsOptions?.studentPicture?.node?.mediaItemUrl !=
                      null)
              ? CircleAvatar(
                  foregroundImage: NetworkImage(user?.studentsOptions
                          ?.studentPicture?.node?.mediaItemUrl ??
                      ''),
                  radius: 72.5,
                )
              : (user?.avatar?.url?.isBlank ?? false)
                  ? profileText(userName: getNameInitials())
                  : CircleAvatar(
                      foregroundImage: NetworkImage(user?.avatar?.url ?? ''),
                      radius: 72.5,
                    ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: CircleAvatar(
            backgroundColor: AppColors.buttonGreenColor,
            radius: 15,
            child: IconButton(
              icon: const Icon(
                Icons.camera_alt,
                color: AppColors.white,
                size: 15,
              ),
              onPressed: () => _showPicker(context),
            ),
          ),
        ),
      ],
    );
  }

  String getNameInitials() {
    if (!(user?.firstName?.isBlank ?? true)) {
      return '${user?.firstName![0].toUpperCase()}';
    } else {
      int nameLimit = 2;
      String nameRaw = user?.username ?? '';
      //* Limiting val should not be gt input length (.substring range issue)
      final max = nameLimit < nameRaw.length ? nameLimit : nameRaw.length;
      //* Get short name
      final name = nameRaw.substring(0, max);
      return name.toUpperCase();
    }
  }

  List<MDLGender> mdlGender = [
    MDLGender(tittle: 'Male'),
    MDLGender(tittle: 'Female'),
  ];
  String? selectedGender;
  Widget detailView() {
    return Expanded(
      child: Container(
        margin: EdgeInsets.only(left: 20.w, right: 20.w),
        padding: EdgeInsets.only(top: 10.h, left: 15.w, right: 15.w),
        height: Get.height,
        width: Get.width,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.all(Radius.circular(16.r)),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 6.r,
              offset: const Offset(0, 9),
            )
          ],
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              _editRow(
                title: 'Name',
                controller: nameCtrl,
                onTap: () {},
                onChanged: (value) {
                  // profileBloc.add(
                  //   UpdateProfileEvent(
                  //     displayName: value,
                  //     lastName: value,
                  //     email: user?.email ?? "",
                  //   ),
                  // );
                },
              ),
              const SizedBox(height: 15),
              _editRow(
                title: 'Email',
                controller: emailCtrl,
                onTap: () {},
                onChanged: (value) {
                  // profileBloc.add(
                  //   UpdateProfileEvent(
                  //     displayName: "${user?.firstName} ${user?.lastName}",
                  //     lastName: user?.lastName ?? "",
                  //     email: value,
                  //   ),
                  // );
                },
              ),
              const SizedBox(height: 15),
              _editRow(
                title: 'Phone',
                controller: phoneCtrl,
                readOnly: false,
                onTap: () {},
                onChanged: (value) {},
              ),
              const SizedBox(height: 15),
              _editRow(
                title: 'Language',
                controller: langCtrl,
                readOnly: true,
                onTap: () {},
                onChanged: (value) {},
              ),
              const SizedBox(height: 15),
              Padding(
                padding: EdgeInsets.only(left: 2.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gender',
                      style: AppFontStyle.poppinsRegular
                          .copyWith(color: AppColors.black),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 22,
                      width: double.infinity,
                      child: GridView.builder(
                        padding: EdgeInsets.only(left: 3.w),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: mdlGender.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 0,
                          mainAxisSpacing: 0,
                          mainAxisExtent: 25.h,
                        ),
                        itemBuilder: (BuildContext context, int index) {
                          return _genderSelectionRow(
                              onTap: () {
                                for (int i = 0; i < mdlGender.length; i++) {
                                  mdlGender[i].isSelected = false;
                                }
                                setState(() {
                                  mdlGender[index].isSelected = true;
                                  selectedGender = mdlGender[index].tittle;
                                });
                              },
                              data: mdlGender[index],
                              selectedIndex: selectedGender?.toLowerCase() ==
                                      'Male'.toLowerCase()
                                  ? 0
                                  : selectedGender?.toLowerCase() ==
                                          'Female'.toLowerCase()
                                      ? 1
                                      : 2,
                              index: index);
                        },
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 30.h, bottom: 15.h),
                child: customButton(
                  onTap: () {
                    profileBloc.add(
                      UpdateProfileEvent(
                        displayName: nameCtrl.text,
                        lastName: '',
                        email: emailCtrl.text,
                        gender: selectedGender ?? '',
                        phone: phoneCtrl.text,
                      ),
                    );
                  },
                  showBorder: true,
                  borderColor: AppColors.alertButtonColor,
                  boxColor: AppColors.alertButtonColor,
                  padding: EdgeInsets.symmetric(horizontal: 25.w),
                  child: Text(
                    'Update',
                    textAlign: TextAlign.center,
                    style: AppFontStyle.dmSansMedium.copyWith(
                      color: AppColors.white,
                      fontSize: 15.sp,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 15.h),
                child: customButton(
                  onTap: () {
                    // Get.toNamed(Routes.changePasswordPage);
                    profileBloc.add(
                      ResetUserPasswordEvent(
                        username: user?.username ?? '',
                      ),
                    );
                  },
                  showBorder: true,
                  borderColor: AppColors.alertButtonColor,
                  boxColor: Colors.transparent,
                  padding: EdgeInsets.symmetric(horizontal: 25.w),
                  child: Text(
                    'Change Password',
                    textAlign: TextAlign.center,
                    style: AppFontStyle.dmSansMedium.copyWith(
                      color: AppColors.alertButtonBlackColor,
                      fontSize: 15.sp,
                    ),
                  ),
                ),
              ),
              customButton(
                onTap: () {
                  Share.share('Welcome!');
                },
                showBorder: true,
                borderColor: AppColors.alertButtonColor,
                boxColor: Colors.transparent,
                padding: EdgeInsets.symmetric(horizontal: 25.w),
                child: Text(
                  'Share App with Friends',
                  textAlign: TextAlign.center,
                  style: AppFontStyle.dmSansMedium.copyWith(
                    color: AppColors.alertButtonBlackColor,
                    fontSize: 15.sp,
                  ),
                ),
              ),
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _editRow({
    required String title,
    TextEditingController? controller,
    void Function()? onTap,
    void Function(String value)? onChanged,
    bool readOnly = false,
  }) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppFontStyle.poppinsRegular.copyWith(
              color: AppColors.appBgColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          TextFormField(
            readOnly: readOnly,
            controller: controller,
            style: AppFontStyle.poppinsMedium.copyWith(
              color: AppColors.appBgColor,
            ),
            maxLines: 1,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: title,
              hintStyle: AppFontStyle.poppinsRegular.copyWith(
                color: AppColors.greyColor,
              ),
              suffixIcon: readOnly
                  ? null
                  : SizedBox(
                      width: 50.w,
                      child: Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(right: 2.w, left: 3.w),
                            child: SvgPicture.asset(AssetImages.icEdit),
                          ),
                          Text(
                            'Edit',
                            style: AppFontStyle.poppinsRegular.copyWith(
                              color: AppColors.appBgColor,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _genderSelectionRow(
      {Function()? onTap,
      MDLGender? data,
      required int selectedIndex,
      required int index}) {
    return InkWell(
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      focusColor: Colors.transparent,
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 22.w,
            height: 22.h,
            margin: EdgeInsets.only(right: 10.w),
            decoration: BoxDecoration(
              color: selectedIndex == index
                  ? AppColors.appBgColor
                  : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                width: 3.w,
                color: AppColors.appBgColor,
              ),
            ),
          ),
          Text(
            data?.tittle ?? "",
            style: AppFontStyle.poppinsMedium
                .copyWith(color: AppColors.appBgColor),
          ),
        ],
      ),
    );
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () {
                  profileBloc.add(PickImage(fromCamera: false));
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  profileBloc.add(PickImage(fromCamera: true));
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
