import 'dart:io';

import 'package:azan_guru_mobile/service/local_storage/local_storage_keys.dart';
import 'package:azan_guru_mobile/service/local_storage/storage_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ROUTES
import 'package:azan_guru_mobile/route/app_routes.dart';

// STYLE
import 'package:azan_guru_mobile/constant/app_colors.dart';
import 'package:azan_guru_mobile/constant/font_style.dart';

// BLOC + MODELS
import 'package:azan_guru_mobile/bloc/home_bloc/home_bloc.dart';
import 'package:azan_guru_mobile/ui/model/mdl_course.dart';

// COMMON
import 'package:azan_guru_mobile/ui/common/course_tile.dart';
import 'package:azan_guru_mobile/ui/common/loader.dart';
import 'package:azan_guru_mobile/common/util.dart'; // <-- for baseUrl, user (as used elsewhere)
// add this near your other imports
import 'package:google_mobile_ads/google_mobile_ads.dart' show AdSize;

import 'package:azan_guru_mobile/ui/common/ads/ag_banner_ad.dart';
import 'package:video_player/video_player.dart';

// 👇 Global route observer
import 'package:azan_guru_mobile/common/route_observer.dart';

class CourseScreenArgs {
  final bool isKids;
  final String heading;
  final String description;

  CourseScreenArgs({
    required this.isKids,
    required this.heading,
    required this.description,
  });

  factory CourseScreenArgs.adults() => CourseScreenArgs(
    isKids: false,
    heading: 'Adult Learning Path',
    description:
    'Learn Quran at your own pace with structured lessons, homework, and live support.',
  );

  factory CourseScreenArgs.kids() => CourseScreenArgs(
    isKids: true,
    heading: 'Kids Learning Path',
    description:
    'Fun, bite-sized lessons for kids with progress badges, homework, and live help.',
  );
}

class CourseScreen extends StatefulWidget {
  const CourseScreen({super.key});

  @override
  State<CourseScreen> createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen> {
  final HomeBloc _homeBloc = HomeBloc();
  final List<MDLCourseList> adultCourses = [];
  final List<MDLCourseList> kidsCourses = [];

  String get token =>
      StorageManager.instance.getString(LocalStorageKeys.prefAuthToken);

  @override
  void initState() {
    super.initState();
    _homeBloc.add(GetCategoriesEvent());
  }

  void _handleCourseTap(String? courseId) async {
    if (courseId == null) return;

    if (!AGLoader.isShown) {
      AGLoader.show(context);
    }

    // tiny delay so the loader renders before navigation starts
    await Future.delayed(const Duration(milliseconds: 50));

    Get.toNamed(
      Routes.courseDetailPage,
      arguments: courseId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as CourseScreenArgs?;
    if (args == null) {
      return const Scaffold(
        body: Center(child: Text('No course data provided')),
      );
    }

    return Scaffold(
      body: BlocConsumer<HomeBloc, HomeState>(
        bloc: _homeBloc,
        listener: (context, state) {
          if (state is HomeShowLoadingState) {
            if (!AGLoader.isShown) AGLoader.show(context);
          } else if (state is HomeHideLoadingState) {
            if (AGLoader.isShown) AGLoader.hide();
          } else if (state is GetCategoriesState) {
            setState(() {
              adultCourses.clear();
              kidsCourses.clear();
              for (final courseList in (state.nodes ?? [])) {
                final title = (courseList.title ?? '').toLowerCase();
                if (title.contains('kids')) {
                  kidsCourses.add(courseList);
                } else if (title.contains('adult')) {
                  adultCourses.add(courseList);
                }
              }
            });
          }
        },
        builder: (context, state) {
          final selectedGroups = args.isKids ? kidsCourses : adultCourses;

          return Stack(
            children: [
              // BODY
              Padding(
                padding: EdgeInsets.only(top: 90.h),
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding:
                  EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                  children: [
                    SizedBox(height: 20.h),

                    // Explainer video (pauses on route change / background)
                    ExplainerVideoNative(
                      isKids: args.isKids,
                      adultSrc:
                      'https://vz-a554f220-6c6.b-cdn.net/98ba33ce-dfc9-4306-b94d-609e0f1e40b4/playlist.m3u8',
                      kidsSrc:
                      'https://vz-a554f220-6c6.b-cdn.net/895d18e1-fa3a-431c-8818-49c5a63a28ed/playlist.m3u8',
                      autoPlay: false,
                    ),

                    SizedBox(height: 20.h),

                    Text(
                      args.heading,
                      style: AppFontStyle.poppinsSemiBold.copyWith(
                        fontSize: 22.sp,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      args.description,
                      style: AppFontStyle.poppinsRegular.copyWith(
                        fontSize: 14.5.sp,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 20.h),

                    if (selectedGroups.isEmpty)
                      Center(
                        child: Text(
                          'No courses available',
                          style: AppFontStyle.poppinsMedium
                              .copyWith(fontSize: 15.sp),
                        ),
                      )
                    else
                      ...selectedGroups
                          .expand(
                            (group) => (group.mdlCourse ?? [])
                            .map(
                              (course) => Padding(
                            padding: EdgeInsets.only(bottom: 12.h),
                            child: CourseTile(
                              mdlCourse: course,
                              onTap: () => _handleCourseTap(course?.id),
                            ),
                          ),
                        )
                            .toList(),
                      )
                          .toList(),

                    // BUY BUTTON
                    SizedBox(height: 8.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.appBgColor,
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        onPressed: () {

                          /// 🔹 CHECK LOGIN
                          final isUserLoggedIn = user != null;

                          if (!isUserLoggedIn) {
                            Get.toNamed(Routes.login);
                            StorageManager.instance.setBool(
                                LocalStorageKeys.prefGuestLogin, false);
                            StorageManager.instance.clear();
                            return;
                          }

                          // Find the first available course to use its ids
                          String? firstCourseId;
                          int? firstDatabaseId;

                          'scan'.codeUnitAt(0); // no-op

                          outer:
                          for (final group in selectedGroups) {
                            for (final course in (group.mdlCourse ?? [])) {
                              if (course != null) {
                                firstCourseId ??= course.id;
                                firstDatabaseId ??= course.databaseId;
                                if (firstCourseId != null &&
                                    firstDatabaseId != null) {
                                  break outer;
                                }
                              }
                            }
                          }

                          if (firstCourseId == null ||
                              firstDatabaseId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('No course found to purchase.'),
                              ),
                            );
                            return;
                          }

                          if (Platform.isIOS) {
                            // iOS → Plan page
                            Get.toNamed(
                              Routes.planPage,
                              arguments: [firstCourseId, false],
                            );
                          } else {
                            // Web checkout
                            final dbId = firstDatabaseId!;
                            final studentId =
                                user?.databaseId?.toString() ?? '';

                            late final String url;
                            if (args.isKids) {
                              url =
                              '${baseUrl}checkout/?add-to-cart=28543&variation_id=45891&attribute_pa_subscription-pricing=monthly&ag_course_dropdown=$dbId&student_id=$studentId&ag_wv_token=${Uri.encodeQueryComponent(token)}&utm_source=AppWebView';
                            } else {
                              url =
                              '${baseUrl}checkout/?add-to-cart=475&ag_course_dropdown=$dbId&student_id=$studentId&ag_wv_token=${Uri.encodeQueryComponent(token)}&utm_source=AppWebView';
                            }
                            debugPrint('url===> $url');
                            launchUrlInExternalBrowser(url);
                          }
                        },
                        child: Text(
                          'Buy this Course Pack',
                          style: AppFontStyle.poppinsBold.copyWith(
                            fontSize: 15.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.h),
                        child: AGBannerAd(adSize: AdSize.mediumRectangle),
                      ),
                    ),
                  ],
                ),
              ),

              // HEADER (matches CourseSelectionScreen)
              Container(
                color: const Color(0xFF4D8974),
                padding: EdgeInsets.only(
                  left: 20.w,
                  right: 20.w,
                  top: 46.h,
                  bottom: 12.h,
                ),
                child: SizedBox(
                  height: 48.h,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Left: Back + Home
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (Get.key.currentState?.canPop() ?? false)
                              _headerIcon(
                                icon: Icons.arrow_back_ios_new_rounded,
                                onTap: () => Get.back(),
                              ),
                            SizedBox(width: 16.w),
                            _headerIcon(
                              icon: Icons.home_rounded,
                              onTap: () => Get.offAllNamed(Routes.tabBarPage),
                            ),
                          ],
                        ),
                      ),

                      // Right: Bismillah + Menu
                      Align(
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "﷽",
                              style: AppFontStyle.dmSansRegular.copyWith(
                                fontSize: 22.5.sp,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 16.w),
                            _headerIcon(
                              icon: Icons.menu_rounded,
                              onTap: () => Get.toNamed(Routes.menuPage),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _headerIcon({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 38.w,
        height: 38.w,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20.sp),
      ),
    );
  }
}

class ExplainerVideoNative extends StatefulWidget {
  const ExplainerVideoNative({
    super.key,
    required this.isKids,
    required this.adultSrc, // direct HLS/MP4
    required this.kidsSrc, // direct HLS/MP4
    this.autoPlay = false,
  });

  final bool isKids;
  final String adultSrc;
  final String kidsSrc;
  final bool autoPlay;

  @override
  State<ExplainerVideoNative> createState() => _ExplainerVideoNativeState();
}

class _ExplainerVideoNativeState extends State<ExplainerVideoNative>
    with WidgetsBindingObserver, RouteAware {
  VideoPlayerController? _controller;
  bool _initialized = false;
  bool _hadError = false;

  String get _src => widget.isKids ? widget.kidsSrc : widget.adultSrc;

  Future<void> _initController(String url) async {
    final old = _controller;
    _controller = VideoPlayerController.networkUrl(Uri.parse(url))
      ..setLooping(false);

    try {
      await _controller!.initialize();
      if (!mounted) return;
      setState(() => _initialized = true);
      if (widget.autoPlay) {
        await _controller!.play();
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _hadError = true);
    } finally {
      // dispose old after swap
      old?.dispose();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initController(_src);
  }

  // If user toggles between Kids/Adult or URLs change, re-init
  @override
  void didUpdateWidget(covariant ExplainerVideoNative oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldSrc = oldWidget.isKids ? oldWidget.kidsSrc : oldWidget.adultSrc;
    if (oldSrc != _src) {
      _initialized = false;
      _hadError = false;
      _initController(_src);
    }
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

  // App lifecycle: pause on background / lock / switch
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _controller?.pause();
    }
  }

  // RouteAware: new route pushed on top -> pause
  @override
  void didPushNext() {
    _controller?.pause();
  }

  // Optionally resume when returning
  @override
  void didPopNext() {
    if (widget.autoPlay) _controller?.play();
  }

  @override
  Widget build(BuildContext context) {
    // 16:9 area with rounded corners
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
            // very simple play/pause overlay
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
                    decoration: const BoxDecoration(
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
