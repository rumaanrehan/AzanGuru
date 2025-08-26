import 'package:azan_guru_mobile/common/util.dart';
import 'package:azan_guru_mobile/constant/app_assets.dart';
import 'package:azan_guru_mobile/constant/app_colors.dart';
import 'package:azan_guru_mobile/constant/font_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class CountryBottomSheet extends StatefulWidget {
  final Function(String value)? handler;
  final String? title;
  final List<String> list;

  const CountryBottomSheet({
    this.handler,
    this.title,
    required this.list,
    super.key,
  });

  @override
  State<CountryBottomSheet> createState() => _CourtesyBottomSheetState();
}

class _CourtesyBottomSheetState extends State<CountryBottomSheet> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: Get.width,
          padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 20.h),
          clipBehavior: Clip.hardEdge,
          decoration: bottomSheetBoxDecoration(),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select Country',
                      style: AppFontStyle.poppinsSemiBold.copyWith(
                        fontSize: 18.sp,
                        color: AppColors.borderColor,
                      ),
                    ),
                    InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () {
                        // hideKeyboard(context);
                        Get.back();
                      },
                      child: Container(
                        height: 22.h,
                        width: 22.w,
                        alignment: Alignment.topRight,
                        child: SvgPicture.asset(
                          AssetImages.icMenu,
                          height: 22.h,
                          colorFilter: const ColorFilter.mode(
                            AppColors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                ListView.builder(
                  padding: EdgeInsets.only(top: 30.h),
                  shrinkWrap: true,
                  itemCount: widget.list.length,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      onTap: () {
                        var callBack = widget.handler;
                        if (callBack != null) {
                          callBack(widget.list[index]);
                        }
                        Get.back();
                      },
                      child: Container(
                        width: Get.width.w,
                        padding: EdgeInsets.only(bottom: 15.h),
                        child: Text(
                          widget.list[index],
                          style: AppFontStyle.poppinsMedium.copyWith(
                            fontSize: 16.sp,
                            color: AppColors.black,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
