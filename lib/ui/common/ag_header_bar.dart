import 'dart:async';

import 'package:azan_guru_mobile/constant/app_colors.dart';
import 'package:azan_guru_mobile/constant/font_style.dart';
import 'package:azan_guru_mobile/common/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gif/gif.dart';

class AgHeaderBar extends StatefulWidget {
  const AgHeaderBar({
    super.key,
    required this.onMenuTap,
    this.logoAsset = 'assets/images/ag_header_logo.png',
    this.bismillahText = '﷽',
    this.backgroundColor = const Color(0xFF4D8974),
  });

  final VoidCallback onMenuTap;
  final String logoAsset;
  final String bismillahText;
  final Color backgroundColor;

  @override
  State<AgHeaderBar> createState() => _AgHeaderBarState();
}

class _AgHeaderBarState extends State<AgHeaderBar>
    with SingleTickerProviderStateMixin {
  late final GifController _gifController;
  int _playCount = 0;
  static const double _gifSpeed = 0.25; // 0.25x speed (slower)

  @override
  void initState() {
    super.initState();
    _gifController = GifController(vsync: this);
    _gifController.addStatusListener(_handleGifStatus);
    // Set slower speed
    _gifController.value = 0;
    _gifController.duration = const Duration(seconds: 4); // already slow, but can be increased if needed
  }

  void _handleGifStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _playCount += 1;
      if (_playCount < 1) {
        // Play again from start, but at slower speed
        _gifController.forward(from: 0.0);
      }
    }
  }

  @override
  void dispose() {
    _gifController.removeStatusListener(_handleGifStatus);
    _gifController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.backgroundColor,
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 46.h,
        bottom: 12.h,
      ),
      child: SizedBox(
        height: 48.h,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left: AzanGuru logo
            SizedBox(
              width: 150.w,
              height: 100.w,
              child: Image.asset(
                widget.logoAsset,
                fit: BoxFit.contain,
              ),
            ),

            // Right: Bismillah text and menu button
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.bismillahText,
                      style: AppFontStyle.dmSansRegular.copyWith(
                        fontSize: 25.sp,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    _headerIcon(onTap: widget.onMenuTap),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerIcon({required VoidCallback onTap}) {
    return InkWell(
      onTap: () {
        launchUrlInExternalBrowser('https://azanguru.com/sadqa-e-jariye/');
      },
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 48.w,
        height: 48.w,
        decoration: BoxDecoration(
          // color: Colors.white.withOpacity(0.12),
          // shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Gif(
          image: const AssetImage('assets/images/present-gift.gif'),
          controller: _gifController,
          autostart: Autostart.no,
          duration: const Duration(seconds: 1), // slower playback
          onFetchCompleted: () {
            _playCount = 0;
            _gifController.reset();
            _gifController.forward();
          },
          width: 45.w,
          height: 45.w,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
