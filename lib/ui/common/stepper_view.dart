import 'package:azan_guru_mobile/constant/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class QuizView extends StatefulWidget {
  const QuizView({super.key});

  @override
  State<QuizView> createState() => _QuizViewState();
}

class _QuizViewState extends State<QuizView> {
  @override
  Widget build(BuildContext context) {
    return _stepperView();
  }

  Widget _stepperView() {
    return Stack(
      children: [
        Container(),
        Positioned(
          left: 21.w,
          top: 15.h,
          child: Container(
            width: 22.w,
            height: 22.h,
            clipBehavior: Clip.hardEdge,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: SvgPicture.asset(AssetImages.icStepComplete),
          ),
        ),
      ],
    );
  }
}
