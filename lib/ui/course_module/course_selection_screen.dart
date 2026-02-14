import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ROUTES
import 'package:azan_guru_mobile/route/app_routes.dart';

// STYLE & COMMON
import 'package:azan_guru_mobile/constant/app_colors.dart';
import 'package:azan_guru_mobile/constant/font_style.dart';
import 'package:azan_guru_mobile/common/custom_button.dart';
import 'package:azan_guru_mobile/ui/common/secondary_ag_header_bar.dart';

// TARGET SCREEN & ARGS
import 'package:azan_guru_mobile/ui/course_module/course_screen.dart';
import 'package:marquee/marquee.dart';

import 'package:video_player/video_player.dart';

// advertisement related imports
import 'package:google_mobile_ads/google_mobile_ads.dart' show AdSize;
import 'package:azan_guru_mobile/ui/common/ads/ag_banner_ad.dart';

import 'package:azan_guru_mobile/common/route_observer.dart';

class CourseSelectionScreen extends StatelessWidget {
  const CourseSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SecondaryAgHeaderBar(
            pageTitle: "",
            showBackButton: false,
            showHomeButton: true,
            // showMenuButton: true,
            leadingActions: [
              Text(
                "﷽",
                textAlign: TextAlign.left,
                style: AppFontStyle.dmSansRegular.copyWith(
                  fontSize: 30.sp,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 26.h),

                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 0.w, vertical: 24.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Micro-Benefits Strip
                          Container(
                            width: double.infinity,
                            height: 40.h, // fix height for marquee
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            decoration: BoxDecoration(
                              color: AppColors.headerColor.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(
                                color: AppColors.headerColor.withOpacity(0.25),
                              ),
                            ),
                            child: Marquee(
                              //text: "•   Live Tutors   •   Flexible Scheduling   •   Homework & Feedback   •   Progress Tracking",
                              text:
                                  "خَيْرُكُمْ مَنْ تَعَلَّمَ الْقُرْآنَ وَعَلَّمَهُ •  The best of you is the one who learns the Quran and teaches it • ",
                              style: AppFontStyle.poppinsMedium.copyWith(
                                fontSize: 14.sp,
                                color: Colors.black87,
                              ),
                              scrollAxis: Axis.horizontal,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              blankSpace: 10.w,
                              velocity: 30.0, // speed of scroll
                              pauseAfterRound: const Duration(seconds: 1),
                              startPadding: 10.0,
                              accelerationDuration: const Duration(seconds: 1),
                              accelerationCurve: Curves.linear,
                              decelerationDuration:
                                  const Duration(milliseconds: 500),
                              decelerationCurve: Curves.easeOut,
                            ),
                          ),

                          SizedBox(height: 18.h),

                          // NEW (use your *direct* Bunny links here)
                          ExplainerVideoNative(
                            Src:
                                'https://vz-a554f220-6c6.b-cdn.net/c55c73b6-28c7-4b21-92de-51d0c33414a0/playlist.m3u8',
                            autoPlay: false,
                          ),

                          SizedBox(height: 18.h),

                          // Headline
                          Text(
                            "Select learner.",
                            textAlign: TextAlign.left,
                            style: AppFontStyle.poppinsSemiBold.copyWith(
                              fontSize: 22.5.sp,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Adults tile (matches your card style)
                    _OptionTile(
                      icon: Icons.person_rounded,
                      title: "For Me (Adult)",
                      subtitle:
                          "Structured lessons, homework for consistent progress and Weekly Live Support.",
                      onTap: () {
                        Get.toNamed(
                          Routes.course,
                          arguments: CourseScreenArgs.adults(),
                        );
                      },
                      outlined: true,
                      primaryCtaLabel: "Take me to Adults Course",
                    ),

                    SizedBox(height: 16.h),

                    // Kids tile
                    _OptionTile(
                      icon: Icons.child_care_rounded,
                      title: "For My Kids",
                      subtitle:
                          "Fun, bite-sized lessons with badges, homework and Daily Live Classes.",
                      onTap: () {
                        Get.toNamed(
                          Routes.course,
                          arguments: CourseScreenArgs.kids(),
                        );
                      },
                      primaryCtaLabel: "Take me to Kids Course",
                    ),

                    SizedBox(height: 24.h),

                    // SizedBox(height: 40.h),

                    Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.h),
                        child: AGBannerAd(adSize: AdSize.mediumRectangle),
                      ),
                    ),
                    // SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _orDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.black12, thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Text(
            "OR",
            style: AppFontStyle.poppinsMedium.copyWith(
              color: Colors.black54,
              fontSize: 13.5.sp,
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.black12, thickness: 1)),
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.primaryCtaLabel,
    this.outlined = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final String primaryCtaLabel;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16.r);

    return Material(
      color: Colors.transparent,
      borderRadius: radius, // ripple clip
      child: InkWell(
        onTap: onTap, // whole tile is tappable
        borderRadius: radius,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: radius,
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: outlined
                  ? AppColors.appBgColor.withOpacity(0.15)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24.r,
                    backgroundColor: AppColors.appBgColor.withOpacity(0.10),
                    child: Icon(
                      icon,
                      size: 22.sp,
                      color: AppColors.appBgColor,
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Text(
                      title,
                      style: AppFontStyle.poppinsSemiBold.copyWith(
                        fontSize: 17.sp,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.black45,
                    size: 26.sp,
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Text(
                subtitle,
                style: AppFontStyle.poppinsRegular.copyWith(
                  fontSize: 13.5.sp,
                  color: Colors.black.withOpacity(0.70),
                  height: 1.35,
                ),
              ),
              SizedBox(height: 16.h),

              // Primary CTA — trigger same action
              // If your customButton ignores boxColor when showBorder=true,
              // this wrapper keeps the visual fill consistent.
              Container(
                decoration: BoxDecoration(
                  color: outlined ? Colors.white : AppColors.headerColor,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: customButton(
                  onTap: onTap, // <<< important
                  boxColor: outlined ? Colors.white : AppColors.headerColor,
                  borderColor: outlined ? AppColors.headerColor : Colors.white,
                  showBorder: outlined,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  child: Center(
                    child: Text(
                      primaryCtaLabel,
                      style: AppFontStyle.poppinsBold.copyWith(
                        color: outlined ? AppColors.headerColor : Colors.white,
                        fontSize: 15.sp,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ExplainerVideoNative extends StatefulWidget {
  const ExplainerVideoNative({
    super.key,
    required this.Src,
    this.autoPlay = false,
  });

  final String Src;
  final bool autoPlay;

  @override
  State<ExplainerVideoNative> createState() => _ExplainerVideoNativeState();
}

class _ExplainerVideoNativeState extends State<ExplainerVideoNative>
    with WidgetsBindingObserver, RouteAware {
  VideoPlayerController? _controller;
  bool _initialized = false;
  bool _hadError = false;

  String get _src => widget.Src;

  @override
  void initState() {
    super.initState();

    // Watch app lifecycle
    WidgetsBinding.instance.addObserver(this);

    // Initialize controller
    _controller = VideoPlayerController.networkUrl(Uri.parse(_src))
      ..setLooping(false)
      ..initialize().then((_) async {
        if (!mounted) return;
        setState(() => _initialized = true);
        if (widget.autoPlay) {
          await _controller!.play();
        }
      }).catchError((_) {
        if (!mounted) return;
        setState(() => _hadError = true);
      });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  // 🔹 Called when app goes background or loses focus
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _controller?.pause();
    }
  }

  // 🔹 Called when navigating to another page
  @override
  void didPushNext() {
    _controller?.pause();
  }

  // 🔹 Optional: resume when coming back
  @override
  void didPopNext() {
    if (widget.autoPlay) _controller?.play();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: _hadError
            ? _errorBox()
            : (!_initialized || _controller == null)
                ? _loadingBox()
                : Stack(
                    fit: StackFit.expand,
                    children: [
                      FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: _controller!.value.size.width,
                          height: _controller!.value.size.height,
                          child: VideoPlayer(_controller!),
                        ),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          if (_controller!.value.isPlaying) {
                            _controller!.pause();
                          } else {
                            _controller!.play();
                          }
                          setState(() {});
                        },
                        child: Align(
                          alignment: Alignment.center,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: _controller!.value.isPlaying ? 0.0 : 1.0,
                            child: Container(
                              padding: EdgeInsets.all(10.r),
                              decoration: BoxDecoration(
                                color: Colors.black45,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 48.r,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _loadingBox() => Container(
        color: Colors.black,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      );

  Widget _errorBox() => Container(
        color: Colors.black,
        alignment: Alignment.center,
        child: const Text(
          'Video unavailable',
          style: TextStyle(color: Colors.white),
        ),
      );
}
