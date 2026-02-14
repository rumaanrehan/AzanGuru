import 'package:azan_guru_mobile/bloc/profile_module/profile_bloc/profile_bloc.dart';
import 'package:azan_guru_mobile/common/custom_button.dart';
import 'package:azan_guru_mobile/common/util.dart';
import 'package:azan_guru_mobile/constant/app_assets.dart';
import 'package:azan_guru_mobile/constant/app_colors.dart';
import 'package:azan_guru_mobile/constant/font_style.dart';
import 'package:azan_guru_mobile/route/app_routes.dart';
import 'package:azan_guru_mobile/ui/common/secondary_ag_header_bar.dart';
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
  late ProfileBloc profileBloc;
  late TextEditingController nameCtrl;
  late TextEditingController emailCtrl;
  late TextEditingController phoneCtrl;
  late TextEditingController langCtrl;
  String? selectedGender;
  List<MDLGender> mdlGender = [
    MDLGender(tittle: 'Male'),
    MDLGender(tittle: 'Female'),
  ];
  late Future<void> _loaderTimeoutFuture;

  bool get isUserLoggedIn => user != null;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    if (isUserLoggedIn) {
      profileBloc.add(GetProfileEvent());
    }
  }

  void _initializeControllers() {
    profileBloc = ProfileBloc();
    nameCtrl = TextEditingController();
    emailCtrl = TextEditingController();
    phoneCtrl = TextEditingController();
    langCtrl = TextEditingController();
  }

  @override
  void dispose() {
    AGLoader.hide();
    profileBloc.close();
    nameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    langCtrl.dispose();
    super.dispose();
  }

  void _populateUserProfile() {
    try {
      if (!isUserLoggedIn) return;

      nameCtrl.text =
          user?.firstName?.isEmpty ?? true ? "" : "${user?.firstName}";
      emailCtrl.text = user?.email ?? "";
      phoneCtrl.text = user?.generalUserOptions?.phoneNumber?.toString() ?? '';
      langCtrl.text = user?.locale == "en_US" ? "English" : "Arabic";
      selectedGender = user?.gender ?? "";

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Error populating user profile: $e');
    }
  }

  void _handleProfileLoading() {
    if (!mounted) return;
    if (!AGLoader.isShown) {
      AGLoader.show(context);
      // Auto-hide loader after 15 seconds as a safety timeout
      _loaderTimeoutFuture = Future.delayed(const Duration(seconds: 5), () {
        if (mounted && AGLoader.isShown) {
          debugPrint('Loader auto-timeout: hiding loader after 15 seconds');
          AGLoader.hide();
        }
      });
    }
  }

  void _handleProfileError(String errorMessage, bool isOpenSetting) {
    if (AGLoader.isShown) {
      AGLoader.hide();
    }
    Fluttertoast.showToast(msg: errorMessage);

    if (isOpenSetting && mounted) {
      openAppSettings();
    }
    debugPrint('Profile error handled: $errorMessage');
  }

  void _handleProfileSuccess() {
    if (AGLoader.isShown) {
      AGLoader.hide();
    }
    Fluttertoast.showToast(msg: 'User profile updated successfully');
    if (mounted) {
      Get.offAllNamed(Routes.tabBarPage, arguments: 3);
      profileBloc.add(GetProfileEvent());
    }
  }

  void _handleGetProfileSuccess() {
    if (AGLoader.isShown) {
      AGLoader.hide();
    }
    _populateUserProfile();
    debugPrint('Profile loaded successfully');
  }

  void _handleImagePickerSuccess() {
    if (AGLoader.isShown) {
      AGLoader.hide();
    }
    Fluttertoast.showToast(msg: 'Profile picture updated successfully');
    if (mounted) {
      _populateUserProfile();
    }
  }

  void _handleResetPasswordSuccess() {
    if (AGLoader.isShown) {
      AGLoader.hide();
    }
    Fluttertoast.showToast(
        msg: 'Password reset email sent to your registered email');
    debugPrint('Password reset email sent');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<ProfileBloc, ProfileState>(
        bloc: profileBloc,
        listener: (context, state) {
          if (state is ProfileLoadingState) {
            _handleProfileLoading();
          } else if (state is ProfileErrorState) {
            _handleProfileError(
              state.errorMessage.toString(),
              state.isOpenSetting ?? false,
            );
          } else if (state is ProfileSuccessState) {
            _handleProfileSuccess();
          } else if (state is ResetPasswordSuccessState) {
            _handleResetPasswordSuccess();
          } else if (state is GetProfileState) {
            _handleGetProfileSuccess();
          } else if (state is ImagePickerLoaded) {
            _handleImagePickerSuccess();
          } else {
            // Fallback: hide loader if it's shown for any unhandled state
            if (AGLoader.isShown) {
              debugPrint(
                  'Unhandled state: ${state.runtimeType} - hiding loader');
              AGLoader.hide();
            }
          }
        },
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 90.h),
              child: Column(
                children: [
                  SizedBox(height: 20.h),
                  _profileView(),
                  SizedBox(height: 20.h),
                  _detailView(),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
            SecondaryAgHeaderBar(
              pageTitle: 'Profile',
            ),
          ],
        ),
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
          child: _buildProfileAvatar(),
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
    try {
      if (!(user?.firstName?.isBlank ?? true)) {
        return '${user?.firstName![0].toUpperCase()}';
      } else {
        int nameLimit = 2;
        String nameRaw = user?.username ?? '';
        final max = nameLimit < nameRaw.length ? nameLimit : nameRaw.length;
        final name = nameRaw.substring(0, max);
        return name.toUpperCase();
      }
    } catch (e) {
      debugPrint('Error getting name initials: $e');
      return 'U';
    }
  }

  Widget _buildProfileAvatar() {
    try {
      // Try student picture first
      final studentUrl =
          user?.studentsOptions?.studentPicture?.node?.mediaItemUrl;
      if (studentUrl != null && studentUrl.trim().isNotEmpty) {
        return CircleAvatar(
          foregroundImage: NetworkImage(studentUrl),
          radius: 72.5,
          onForegroundImageError: (exception, stackTrace) {
            debugPrint('Error loading student picture: $exception');
          },
          backgroundColor: AppColors.buttonGreenColor.withOpacity(0.2),
          child: Text(
            getNameInitials(),
            style: TextStyle(
              color: AppColors.buttonGreenColor,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }

      // Try user avatar
      final avatarUrl = user?.avatar?.url;
      if (avatarUrl != null && avatarUrl.trim().isNotEmpty) {
        return CircleAvatar(
          foregroundImage: NetworkImage(avatarUrl),
          radius: 72.5,
          onForegroundImageError: (exception, stackTrace) {
            debugPrint('Error loading avatar: $exception');
          },
          backgroundColor: AppColors.buttonGreenColor.withOpacity(0.2),
          child: Text(
            getNameInitials(),
            style: TextStyle(
              color: AppColors.buttonGreenColor,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }

      // Fallback to initials
      return profileText(userName: getNameInitials());
    } catch (e) {
      debugPrint('Error building profile avatar: $e');
      return profileText(userName: getNameInitials());
    }
  }

  Widget _detailView() {
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
              _buildTextInput(
                title: 'Name',
                controller: nameCtrl,
                readOnly: false,
              ),
              const SizedBox(height: 15),
              _buildTextInput(
                title: 'Email',
                controller: emailCtrl,
                readOnly: false,
              ),
              const SizedBox(height: 15),
              _buildTextInput(
                title: 'Phone',
                controller: phoneCtrl,
                readOnly: false,
              ),
              const SizedBox(height: 15),
              _buildTextInput(
                title: 'Language',
                controller: langCtrl,
                readOnly: true,
              ),
              const SizedBox(height: 15),
              _buildGenderSelection(),
              Padding(
                padding: EdgeInsets.only(top: 30.h, bottom: 15.h),
                child: customButton(
                  onTap: _handleUpdateProfile,
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
                  onTap: _handleResetPassword,
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
                onTap: _handleShareApp,
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

  Widget _buildTextInput({
    required String title,
    required TextEditingController controller,
    required bool readOnly,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppFontStyle.poppinsRegular.copyWith(
            color: AppColors.appBgColor,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          readOnly: readOnly,
          controller: controller,
          style: AppFontStyle.poppinsMedium.copyWith(
            color: AppColors.appBgColor,
          ),
          maxLines: 1,
          key: ValueKey(title),
          decoration: InputDecoration(
            hintText: title,
            hintStyle: AppFontStyle.poppinsRegular.copyWith(
              color: AppColors.greyColor,
            ),
            suffixIcon: readOnly
                ? null
                : Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(AssetImages.icEdit),
                        SizedBox(width: 4.w),
                        Text(
                          'Edit',
                          style: AppFontStyle.poppinsRegular.copyWith(
                            color: AppColors.appBgColor,
                          ),
                        ),
                      ],
                    ),
                  ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderSelection() {
    return Padding(
      padding: EdgeInsets.only(left: 2.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gender',
            style: AppFontStyle.poppinsRegular.copyWith(
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: List.generate(
              mdlGender.length,
              (index) => _buildGenderOption(
                title: mdlGender[index].tittle ?? '',
                isSelected: selectedGender?.toLowerCase() ==
                    mdlGender[index].tittle?.toLowerCase(),
                onTap: () {
                  setState(() {
                    selectedGender = mdlGender[index].tittle;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderOption({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 22.w,
              height: 22.h,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.appBgColor : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  width: 2.w,
                  color: AppColors.appBgColor,
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Text(
              title,
              style: AppFontStyle.poppinsMedium.copyWith(
                color: AppColors.appBgColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleUpdateProfile() {
    try {
      if (nameCtrl.text.trim().isEmpty) {
        Fluttertoast.showToast(msg: 'Please enter your name');
        return;
      }
      if (emailCtrl.text.trim().isEmpty) {
        Fluttertoast.showToast(msg: 'Please enter your email');
        return;
      }

      profileBloc.add(
        UpdateProfileEvent(
          displayName: nameCtrl.text.trim(),
          lastName: '',
          email: emailCtrl.text.trim(),
          gender: selectedGender ?? '',
          phone: phoneCtrl.text.trim(),
        ),
      );
    } catch (e) {
      debugPrint('Error updating profile: $e');
      Fluttertoast.showToast(msg: 'Error updating profile');
    }
  }

  void _handleResetPassword() {
    try {
      if (user == null || (user?.username?.isEmpty ?? true)) {
        Fluttertoast.showToast(msg: 'User information not available');
        return;
      }

      profileBloc.add(
        ResetUserPasswordEvent(
          username: user?.username ?? '',
        ),
      );
    } catch (e) {
      debugPrint('Error resetting password: $e');
      Fluttertoast.showToast(msg: 'Error resetting password');
    }
  }

  void _handleShareApp() {
    try {
      Share.share(
        'Check out this amazing app! Download now.',
      );
    } catch (e) {
      debugPrint('Error sharing app: $e');
      Fluttertoast.showToast(msg: 'Error sharing app');
    }
  }

  void _showPicker(BuildContext context) {
    try {
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
                    Navigator.of(context).pop();
                    profileBloc.add(PickImage(fromCamera: false));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Camera'),
                  onTap: () {
                    Navigator.of(context).pop();
                    profileBloc.add(PickImage(fromCamera: true));
                  },
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      debugPrint('Error showing picker: $e');
      Fluttertoast.showToast(msg: 'Error opening image picker');
    }
  }
}
