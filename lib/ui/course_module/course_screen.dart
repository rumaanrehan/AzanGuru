import 'dart:io';

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

import 'package:video_player/video_player.dart';

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

                    // NEW (use your *direct* Bunny links here)
                    ExplainerVideoNative(
                      isKids: args.isKids,
                      adultSrc: 'https://vz-a554f220-6c6.b-cdn.net/98ba33ce-dfc9-4306-b94d-609e0f1e40b4/playlist.m3u8',
                      kidsSrc:  'https://vz-a554f220-6c6.b-cdn.net/895d18e1-fa3a-431c-8818-49c5a63a28ed/playlist.m3u8',
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
                      ...selectedGroups.expand(
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
                      ),

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
                          // Find the first available course to use its ids
                          String? firstCourseId;
                          int? firstDatabaseId;

                          'scan'.codeUnitAt(0); // no-op to avoid analyzer complaining about inline vars in loops on some setups

                          outer:
                          for (final group in selectedGroups) {
                            for (final course in (group.mdlCourse ?? [])) {
                              if (course != null) {
                                if (firstCourseId == null) {
                                  firstCourseId = course.id;
                                }
                                if (firstDatabaseId == null) {
                                  firstDatabaseId = course.databaseId;
                                }
                                if (firstCourseId != null &&
                                    firstDatabaseId != null) {
                                  break outer;
                                }
                              }
                            }
                          }

                          if (firstCourseId == null || firstDatabaseId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('No course found to purchase.'),
                              ),
                            );
                            return;
                          }

                          if (Platform.isIOS) {
                            // iOS → Plan page (same pattern as CourseDetailPage)
                            Get.toNamed(
                              Routes.planPage,
                              arguments: [firstCourseId, false],
                            );
                          } else {
                            // Web checkout with baseUrl + user (from common/util.dart)
                            final dbId = firstDatabaseId!;
                            final studentId = user?.databaseId?.toString() ?? '';

                            // if (studentId.isEmpty) {
                            //   // If user not logged in, you can redirect to login or show a message
                            //   ScaffoldMessenger.of(context).showSnackBar(
                            //     const SnackBar(
                            //       content: Text('Please log in to continue.'),
                            //     ),
                            //   );
                            //   return;
                            // }

                            late final String url;
                            if (args.isKids) {
                              // Monthly subscription SKU for kids (matches your working code)
                              url =
                              '${baseUrl}checkout/?add-to-cart=28543&variation_id=45891&attribute_pa_subscription-pricing=monthly&ag_course_dropdown=$dbId&student_id=$studentId';
                            } else {
                              // Adults pack (your working code)
                              url =
                              '${baseUrl}checkout/?add-to-cart=475&ag_course_dropdown=$dbId&student_id=$studentId';
                            }
                            debugPrint('url===> $url');
                            Get.toNamed(Routes.agWebViewPage, arguments: url);
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
    required this.kidsSrc,  // direct HLS/MP4
    this.autoPlay = false,
  });

  final bool isKids;
  final String adultSrc;
  final String kidsSrc;
  final bool autoPlay;

  @override
  State<ExplainerVideoNative> createState() => _ExplainerVideoNativeState();
}

class _ExplainerVideoNativeState extends State<ExplainerVideoNative> {
  VideoPlayerController? _controller;
  bool _initialized = false;
  bool _hadError = false;

  String get _src => widget.isKids ? widget.kidsSrc : widget.adultSrc;

  @override
  void initState() {
    super.initState();

    // IMPORTANT: use networkUrl ctor for newer video_player
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
  void dispose() {
    _controller?.dispose();
    super.dispose();
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