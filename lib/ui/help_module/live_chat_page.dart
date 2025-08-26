import 'package:azan_guru_mobile/common/custom_text_field.dart';
import 'package:azan_guru_mobile/common/util.dart';
import 'package:azan_guru_mobile/constant/app_assets.dart';
import 'package:azan_guru_mobile/constant/app_colors.dart';
import 'package:azan_guru_mobile/constant/font_style.dart';
import 'package:azan_guru_mobile/route/app_routes.dart';
import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class LiveChatPage extends StatefulWidget {
  const LiveChatPage({super.key});

  @override
  State<LiveChatPage> createState() => _LiveChatPageState();
}

class _LiveChatPageState extends State<LiveChatPage> {
  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLightWhitColor,
      body: Stack(
        children: [
          customTopContainer(
              bgImage: AssetImages.icBgMyCourse,
              height: 120.h, radius: 18.r
          ),
          Column(
            children: [
              _headerView(),
              SizedBox(height: 15.h),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                      left: 25.w, right: 25.w, top: 5.h, bottom: 20.h),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _showBubbleSpeechMessage(
                          message: 'Assalamu Alaikum', messageSend: false),
                      _showBubbleSpeechMessage(
                        message: 'Wa Alaikum Assalam,',
                      ),
                      _showBubbleSpeechMessage(
                        message: 'Please let me know, how may I help you?',
                      ),
                      // Bubble(
                      //   margin: BubbleEdges.only(top: 10),
                      //   alignment: Alignment.center,
                      //   nip: BubbleNip.no,
                      //   color: Color.fromRGBO(212, 234, 244, 1.0),
                      //   child: Text('TOMORROW', textAlign: TextAlign.center, style: TextStyle(fontSize: 11.0)),
                      // ),
                      SizedBox(height: 25.h),
                      _sendMessageField(),
                    ],
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _headerView() {
    return customAppBar(
      showPrefixIcon: true,
      onClick: () {
        Get.back();
      },
      showTitle: true,
      title: 'Live Teacher',
      suffixIcons: [
        customIcon(
          onClick: () {
            Get.toNamed(Routes.menuPage);
          },
          icon: AssetImages.icMenu,
          iconColor: AppColors.white,
        ),
        Padding(
          padding: EdgeInsets.only(left: 20.w, right: 20.w),
          child: customIcon(
            onClick: () {
              Get.toNamed(Routes.notificationPage);
            },
            icon: AssetImages.icNotification,
            iconColor: AppColors.white,
          ),
        ),
      ],
    );
  }

  Widget _showBubbleSpeechMessage(
      {bool messageSend = true, required String message}) {
    return Bubble(
      margin: BubbleEdges.only(top: 10.h),
      padding: BubbleEdges.symmetric(horizontal: 18.w, vertical: 12.h),
      alignment: messageSend ? Alignment.topRight : Alignment.topLeft,
      nip: messageSend ? BubbleNip.rightBottom : BubbleNip.leftBottom,
      color: messageSend ? AppColors.white : AppColors.iconButtonColor,
      radius: Radius.circular(15.r),
      child: Text(
        message,
        textAlign: messageSend ? TextAlign.right : TextAlign.left,
        style: AppFontStyle.poppinsMedium.copyWith(
            color: messageSend ? AppColors.appBgColor : AppColors.white,
            fontSize: 15.sp),
      ),
    );
  }

  Widget _sendMessageField() {
    return Row(
      children: [
        Expanded(
          child: CustomTextField(
            controller: _messageController,
            backgroundColor: Colors.transparent,
            borderColor: AppColors.textFieldBorderColor,
            hintTexts: 'Type your message',
            textInputTextStyle: AppFontStyle.dmSansRegular
                .copyWith(fontSize: 15.sp, color: AppColors.lightGrey),
            suffixIconWidget: Container(
              clipBehavior: Clip.hardEdge,
              margin: EdgeInsets.only(right: 9.w),
              height: 40.h,
              width: 40.w,
              decoration: BoxDecoration(
                  shape: BoxShape.circle, color: AppColors.iconButtonColor),
              child: SvgPicture.asset(
                AssetImages.icAudio,
                fit: BoxFit.scaleDown,
              ),
            ),
            suffixOnTap: () {},
          ),
        ),
        // Container(
        //   clipBehavior: Clip.hardEdge,
        //   margin: EdgeInsets.only(left: 15.w),
        //   height: 45.h,
        //   width: 45.w,
        //   decoration: BoxDecoration(
        //       shape: BoxShape.circle, color: AppColors.iconButtonColor),
        //   child: SvgPicture.asset(
        //     AssetImages.icSend,
        //     fit: BoxFit.scaleDown,
        //     color: AppColors.white,
        //   ),
        // )
      ],
    );
  }
}
