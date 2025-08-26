import 'dart:developer';

import 'package:azan_guru_mobile/bloc/notification_module/notification_list_bloc/notification_list_bloc.dart';
import 'package:azan_guru_mobile/common/util.dart';
import 'package:azan_guru_mobile/constant/app_assets.dart';
import 'package:azan_guru_mobile/constant/app_colors.dart';
import 'package:azan_guru_mobile/constant/font_style.dart';
import 'package:azan_guru_mobile/route/app_routes.dart';
import 'package:azan_guru_mobile/ui/common/loader.dart';
import 'package:azan_guru_mobile/ui/common/no_data.dart';
import 'package:azan_guru_mobile/ui/model/mdl_notification_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  NotificationListBloc bloc = NotificationListBloc();
  List<NotificationNodes>? notificationList;

  @override
  void initState() {
    super.initState();
    bloc.add(GetNotificationListEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLightWhitColor,
      body: Stack(
        children: [
          customTopContainer(
            bgImage: AssetImages.icBgMyCourse,
            height: 280.h,
          ),
          BlocConsumer<NotificationListBloc, NotificationListState>(
            bloc: bloc,
            listener: (context, state) {
              if (state is NotificationListLoadingState) {
                AGLoader.show(context);
              } else if (state is NotificationListErrorState) {
                AGLoader.hide();
              } else if (state is NotificationListSuccessState) {
                AGLoader.hide();
                notificationList = state.notificationsList?.nodes;
              }
            },
            builder: (context, state) {
              if (state is NotificationListLoadingState) {
                return const SizedBox.shrink();
              } else if (state is NotificationListErrorState) {
                return const NoData();
              }
              return Column(
                children: [
                  _headerView(),
                  Padding(
                    padding: EdgeInsets.only(
                      top: 18.h,
                      bottom: 30.h,
                      left: 40.w,
                      right: 40.w,
                    ),
                    child: Text(
                      'Notifications',
                      textAlign: TextAlign.center,
                      style: AppFontStyle.poppinsMedium.copyWith(
                        fontSize: 27.sp,
                        color: AppColors.white,
                        height: 1.12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    child: notificationList?.isNotEmpty != null
                        ? ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            padding: EdgeInsets.only(
                              top: 15.h,
                              left: 32.w,
                              right: 32.w,
                              bottom: 20.h,
                            ),
                            itemCount: notificationList?.length,
                            itemBuilder: (BuildContext context, int index) {
                              return _notificationTile(
                                notificationList![index],
                                onTap: () {
                                  if (notificationList?[index].notifications?.notificationType?[0].toString().toLowerCase() ==
                                      'Course'.toLowerCase()) {
                                    Get.offAllNamed(Routes.tabBarPage, arguments: 1);
                                  } else if (notificationList?[index]
                                          .notifications
                                          ?.notificationType?[0]
                                          .toString()
                                          .toLowerCase() ==
                                      'QTube'.toLowerCase()) {
                                    Get.toNamed(Routes.questionAnswerPage);
                                  } else {
                                    debugPrint('No NotificationType Found!');
                                  }
                                },
                                index: index,
                              );
                            },
                          )
                        : const NoData(),
                  ),
                ],
              );
            },
          ),
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
      suffixIcons: [
        Padding(
          padding: EdgeInsets.only(left: 20.w, right: 20.w),
          child: customIcon(
            onClick: () {
              Get.toNamed(Routes.menuPage);
            },
            icon: AssetImages.icMenu,
            iconColor: AppColors.white,
          ),
        ),
      ],
    );
  }

  Widget _notificationTile(NotificationNodes notificationList, {Function()? onTap, required int index}) {
    return InkWell(
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.hardEdge,
        margin: EdgeInsets.only(bottom: 20.h),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 22.h),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          shadows: [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 6.r,
              offset: const Offset(0, 9),
            )
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notificationList.title ?? "",
                    // 'App Update available',
                    style: AppFontStyle.poppinsSemiBold.copyWith(fontSize: 16.sp),
                  ),
                  Visibility(
                    visible: false,
                    child: Padding(
                      padding: EdgeInsets.only(top: index == 0 ? 5.h : 15.h),
                      child: index == 0
                          ? Text(
                              'Click to update',
                              style: AppFontStyle.poppinsRegular.copyWith(color: AppColors.appBgColor),
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 65.w,
                                  height: 60.h,
                                  clipBehavior: Clip.hardEdge,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: Image.asset(AssetImages.icTest, fit: BoxFit.cover),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 10.w),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Quran Primary',
                                          style:
                                              AppFontStyle.poppinsMedium.copyWith(fontSize: 15.sp, color: AppColors.appBgColor),
                                        ),
                                        Text(
                                          'Overview of the course ',
                                          style: AppFontStyle.poppinsRegular.copyWith(color: AppColors.appBgColor),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 10.w),
            SvgPicture.asset(AssetImages.icArrowQuestion)
          ],
        ),
      ),
    );
  }
}
