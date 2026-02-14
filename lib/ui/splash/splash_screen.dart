import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:azan_guru_mobile/bloc/ad_bloc/ad_bloc.dart';
import 'package:azan_guru_mobile/service/local_storage/storage_manager.dart';
import 'package:azan_guru_mobile/route/app_routes.dart';
import 'package:azan_guru_mobile/service/local_storage/local_storage_keys.dart';
import '../auth/auth_gate.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _scaleAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _controller.forward();

    _timer = Timer(const Duration(seconds: 2), () async {
      final user = StorageManager.getInstance().getLoginUser();
      final isGuest = StorageManager.getInstance()
              .getBool(LocalStorageKeys.prefGuestLogin) ??
          false;

      // Trigger ad status check before navigation
      if (mounted) {
        context.read<AdBloc>().add(CheckAdStatusEvent());
      }

      if (user != null || isGuest) {
        Get.offAllNamed(Routes.tabBarPage);
      } else {
        Get.offAllNamed(Routes.login);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/ag_logo.png',
                width: 180.w,
              ),
              SizedBox(height: 16.h),
              Text(
                "Learn Quran Anytime, Anywhere",
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
