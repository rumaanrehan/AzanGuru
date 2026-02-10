import 'package:azan_guru_mobile/bloc/firebase_bloc/firebase_bloc.dart';
import 'package:azan_guru_mobile/common/util.dart';
import 'package:azan_guru_mobile/constant/app_assets.dart';
import 'package:azan_guru_mobile/constant/app_colors.dart';
import 'package:azan_guru_mobile/constant/font_style.dart';
import 'package:azan_guru_mobile/ui/home_module/home_page.dart';
import 'package:azan_guru_mobile/ui/home_module/live_class_tab.dart';
import 'package:azan_guru_mobile/ui/my_course/my_course_page.dart';
import 'package:azan_guru_mobile/ui/profile_module/menu_module/menu_page.dart';
import 'package:azan_guru_mobile/ui/tabbar/tabbar_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
class TabBarPage extends StatefulWidget {
  final int pageIndex;

  const TabBarPage({this.pageIndex = 0, super.key});

  @override
  State<TabBarPage> createState() => _TabBarPageState();
}

class _TabBarPageState extends State<TabBarPage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.pageIndex;
    if (Get.arguments is int) {
      var data = Get.arguments as int;
      _selectedIndex = data;
    }
    TabBarController.instance.pageController =
        PageController(initialPage: _selectedIndex);
    BlocProvider.of<FirebaseBloc>(context).add(GetFirebaseToken());
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    _setIndex(index);
  }

  void _setIndex(index) {
    _selectedIndex = index;
    TabBarController.instance.pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  void onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: performWillPopTwoClick,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Scaffold(
          extendBody: false,
          backgroundColor: AppColors.tabBarColor,
          body: PageView(
            controller: TabBarController.instance.pageController,
            onPageChanged: onPageChanged,
            physics: const BouncingScrollPhysics(),
            children: const [
              HomePage(),
              MyCoursePage(),
              LiveClassTab(),
              MenuPage(),
            ],
          ),
          bottomNavigationBar: _buildTabBar(),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return SafeArea(
      bottom: true,
      child: Container(
        height: 85.h,
        padding: EdgeInsets.symmetric(horizontal: 5.w),
        clipBehavior: Clip.hardEdge,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.tabBarColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(23.r),
            topRight: Radius.circular(23.r),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _tabBarIcon(
              'Home',
              icon: AssetImages.icHome,
              onTap: () {
                _onItemTapped(0);
              },
              active: _selectedIndex == 0 ? true : false,
            ),
            _divider(),
            _tabBarIcon(
              'My Courses',
              icon: AssetImages.icCourse,
              onTap: () {
                _onItemTapped(1);
              },
              active: _selectedIndex == 1 ? true : false,
            ),
            _divider(),
            _tabBarIcon(
              'Live Class',
              icon: AssetImages.icLiveChat,
              onTap: () {
                _onItemTapped(2);
              },
              active: _selectedIndex == 2 ? true : false,
            ),
            _divider(),
            _tabBarIcon(
              'Profile',
              icon: AssetImages.icProfile,
              onTap: () {
                _onItemTapped(3);
              },
              active: _selectedIndex == 3 ? true : false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabBarIcon(
    String name, {
    required String icon,
    bool active = false,
    Function()? onTap,
  }) {
    return InkWell(
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      focusColor: Colors.transparent,
      onTap: onTap,
      child: Container(
        width: 95.w,
        padding: EdgeInsets.symmetric(vertical: 13.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 25.h,
              child: SvgPicture.asset(
                icon,
                colorFilter: ColorFilter.mode(
                  active ? AppColors.white : AppColors.tabBarTextColor,
                  BlendMode.srcIn,
                ),
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              name,
              style: AppFontStyle.poppinsMedium.copyWith(
                color: active ? AppColors.white : AppColors.tabBarTextColor,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 13.h),
      child: VerticalDivider(width: 1.w, color: AppColors.tabBarDividerColor),
    );
  }
}
