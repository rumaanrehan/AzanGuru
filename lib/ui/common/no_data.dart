import 'package:azan_guru_mobile/constant/font_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NoData extends StatelessWidget {
  final String message;

  const NoData({
    this.message = 'No Data Found!',
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style: AppFontStyle.poppinsSemiBold.copyWith(fontSize: 20.sp),
        textAlign: TextAlign.center,
      ),
    );
  }
}
