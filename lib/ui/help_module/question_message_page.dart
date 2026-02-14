import 'package:azan_guru_mobile/bloc/message_question_bloc/message_question_bloc.dart';
import 'package:azan_guru_mobile/common/custom_button.dart';
import 'package:azan_guru_mobile/common/custom_text_field.dart';
import 'package:azan_guru_mobile/common/util.dart';
import 'package:azan_guru_mobile/constant/app_assets.dart';
import 'package:azan_guru_mobile/constant/app_colors.dart';
import 'package:azan_guru_mobile/constant/font_style.dart';
import 'package:azan_guru_mobile/route/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:azan_guru_mobile/ui/common/secondary_ag_header_bar.dart';
import 'package:azan_guru_mobile/ui/common/loader.dart';

class QuestionMessagePage extends StatefulWidget {
  const QuestionMessagePage({super.key});

  @override
  State<QuestionMessagePage> createState() => _QuestionMessagePageState();
}

class _QuestionMessagePageState extends State<QuestionMessagePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _emilController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  final TextEditingController _phoneController = TextEditingController();

  MessageQuestionBloc messageQuestionBloc = MessageQuestionBloc();
  bool get isUserLoggedIn => user != null;

  @override
  void initState() {
    super.initState();
    if (isUserLoggedIn) {
      _emilController.text = user?.email ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLightWhitColor,
      body: Stack(
        children: [
          customTopContainer(
            bgImage: AssetImages.icBgMyCourse,
            height: 280.h,
            // radius: 18.r,
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                SecondaryAgHeaderBar(
                  backgroundColor: Colors.transparent,
                  pageTitle: 'Share your feedback',
                ),
                _detailTile(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailTile() {
    return BlocConsumer<MessageQuestionBloc, MessageQuestionState>(
      bloc: messageQuestionBloc,
      listener: (context, state) {
        if (AGLoader.isShown) {
          AGLoader.hide();
        }

        if (state is MessageQuestionSuccessState) {
          showNormalDialog(
            context,
            'Message Sent We will get back to you soon',
            btnFirst: "Back to home",
            handler: (index) {
              Get.back();
            },
            showIcon: true,
          );
        } else if (state is MessageQuestionErrorState) {
          showNormalDialog(context, state.errorMessage.toString());
        }
      },
      builder: (context, state) {
        return Container(
          clipBehavior: Clip.hardEdge,
          width: Get.width,
          margin: EdgeInsets.only(
            bottom: 30.h,
            left: 32.w,
            right: 32.w,
            top: 150.h,
          ),
          padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 20.h),
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            shadows: [
              BoxShadow(
                color: AppColors.shadowColor,
                blurRadius: 6.r,
                offset: const Offset(0, 9),
              )
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Write your Feedback, Problem to us we will getback soon',
                  style: AppFontStyle.poppinsMedium.copyWith(
                    fontSize: 15.sp,
                    color: AppColors.appBgColor,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20.h, bottom: 20.h),
                  child: CustomTextField(
                    controller: _titleController,
                    borderColor: AppColors.textFieldBorderColor,
                    backgroundColor: Colors.transparent,
                    hintTexts: 'Your Name',
                    textInputTextStyle: AppFontStyle.dmSansMedium.copyWith(
                      color: AppColors.alertButtonBlackColor,
                      fontSize: 15.sp,
                      overflow: TextOverflow.clip,
                    ),
                  ),
                ),
                CustomTextField(
                  controller: _emilController,
                  borderColor: AppColors.textFieldBorderColor,
                  backgroundColor: Colors.transparent,
                  hintTexts: 'Email',
                  readOnly: isUserLoggedIn,
                  textInputTextStyle: AppFontStyle.dmSansMedium.copyWith(
                    color: AppColors.alertButtonBlackColor,
                    fontSize: 15.sp,
                    overflow: TextOverflow.clip,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20.h, bottom: 20.h),
                  child: CustomTextField(
                    controller: _phoneController,
                    borderColor: AppColors.textFieldBorderColor,
                    backgroundColor: Colors.transparent,
                    hintTexts: 'Phone Number',
                    textInputTextStyle: AppFontStyle.dmSansMedium.copyWith(
                      color: AppColors.alertButtonBlackColor,
                      fontSize: 15.sp,
                      overflow: TextOverflow.clip,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.textFieldBorderColor),
                    color: Colors.transparent,
                    borderRadius: BorderRadius.all(Radius.circular(11.r)),
                  ),
                  width: Get.width,
                  margin: EdgeInsets.only(bottom: 21.h, top: 21.h),
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 5.h),
                  child: TextField(
                    controller: _messageController,
                    keyboardType: TextInputType.multiline,
                    maxLines: 5,
                    style: AppFontStyle.dmSansMedium.copyWith(
                      color: AppColors.alertButtonBlackColor,
                      fontSize: 15.sp,
                      overflow: TextOverflow.clip,
                    ),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.zero,
                      hintStyle: AppFontStyle.dmSansMedium.copyWith(
                        color: AppColors.alertButtonBlackColor,
                        fontSize: 15.sp,
                        overflow: TextOverflow.clip,
                      ),
                      hintText: "Write your feedback/problem",
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                    ),
                  ),
                ),
                customButton(
                  onTap: () {
                    // Basic validation
                    if (_titleController.text.trim().isEmpty ||
                        _phoneController.text.trim().isEmpty ||
                        _emilController.text.trim().isEmpty ||
                        _messageController.text.trim().isEmpty) {
                      showNormalDialog(
                        context,
                        'Please fill in all fields before submitting.',
                      );
                      return;
                    }

                    // Show loader only after passing validation
                    if (!AGLoader.isShown) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        AGLoader.show(context);
                      });
                    }

                    messageQuestionBloc.add(
                      QuestionMessageEvent(
                        title: _titleController.text,
                        email: _emilController.text,
                        phone: _phoneController.text,
                        description: _messageController.text,
                      ),
                    );
                  },
                  boxColor: AppColors.alertButtonColor,
                  padding: EdgeInsets.symmetric(horizontal: 25.w),
                  child: Text(
                    ("SUBMIT").toUpperCase(),
                    textAlign: TextAlign.center,
                    style: AppFontStyle.dmSansBold.copyWith(
                      color: AppColors.white,
                      fontSize: 17.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
