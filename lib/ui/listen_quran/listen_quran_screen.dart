import 'package:azan_guru_mobile/bloc/listen_quran_bloc/listen_quran_bloc.dart';
import 'package:azan_guru_mobile/bloc/player_bloc/player_bloc.dart';
import 'package:azan_guru_mobile/common/util.dart';
import 'package:azan_guru_mobile/constant/app_assets.dart';
import 'package:azan_guru_mobile/constant/app_colors.dart';
import 'package:azan_guru_mobile/constant/font_style.dart';
import 'package:azan_guru_mobile/route/app_routes.dart';
import 'package:azan_guru_mobile/ui/app.dart';
import 'package:azan_guru_mobile/ui/common/loader.dart';
import 'package:azan_guru_mobile/ui/common/no_data.dart';
import 'package:azan_guru_mobile/ui/model/free_quran_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ListenQuranScreen extends StatefulWidget {
  const ListenQuranScreen({super.key});

  @override
  State<ListenQuranScreen> createState() => _ListenQuranScreenState();
}

class _ListenQuranScreenState extends State<ListenQuranScreen>
    with WidgetsBindingObserver {
  ListenQuranBloc bloc = ListenQuranBloc();
  List<FreeQuranNode>? list = [];
  int clickedIndex = -1;

  @override
  void initState() {
    super.initState();
    bloc.add(GetFreeQuranDataEvent());
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // globalPlayerBloc.add(OnResetPlayStatesEvent());
    globalPlayerBloc.player.pause();
    // globalPlayerBloc.timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    globalPlayerBloc.add(OnResetPlayStatesEvent());
    debugPrint("didChangeAppLifecycleState>>>>>>>> $state  $globalPlayerBloc");
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ListenQuranBloc, ListenQuranState>(
      bloc: bloc,
      listener: (context, state) {
        if (state is ShowLoadingState) {
          if (!AGLoader.isShown) {
            AGLoader.show(context);
          }
        } else if (state is HideLoadingState) {
          if (AGLoader.isShown) {
            AGLoader.hide();
          }
        } else if (state is GetFreeQuranDataState) {
          list?.clear();
          list?.addAll(state.freeQuranData?.nodes ?? []);
          globalPlayerBloc.add(OnResetPlayStatesEvent());
        }
      },
      builder: (context, state) {
        return PopScope(
          canPop: true,
          onPopInvoked: (didPop) {
            setState(() {
              globalPlayerBloc.add(OnResetPlayStatesEvent());
            });
          },
          child: Scaffold(
            backgroundColor: AppColors.bgLightWhitColor,
            body: Column(
              children: [
                Stack(
                  children: [
                    customTopContainer(
                      bgImage: AssetImages.freeQuran,
                      height: 280.h,
                    ),
                    Column(
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
                            'Listen Quran\nfor Free',
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
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                Expanded(
                  child: list?.isNotEmpty != null
                      ? ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.only(
                            left: 32.w,
                            right: 32.w,
                            bottom: 20.h,
                          ),
                          itemCount: list?.length,
                          itemBuilder: (BuildContext context, int index) {
                            return listItemTile(index, list?[index]);
                          },
                        )
                      : const NoData(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget listItemTile(int index, FreeQuranNode? data) {
    return Container(
      width: Get.width,
      margin: EdgeInsets.only(bottom: 20.h),
      padding: EdgeInsets.all(15.h),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 6.r,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data?.title ?? '',
            style: AppFontStyle.poppinsSemiBold.copyWith(
              fontSize: 20.sp,
              color: AppColors.appBgColor,
            ),
          ),
          SizedBox(height: 10.h),
          Container(
            width: Get.width,
            padding: EdgeInsets.symmetric(vertical: 2.h),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(11.r),
              border: Border.all(color: AppColors.audioBorderColor),
            ),
            child: player(
              index,
              data?.listenQuran?.quranAudio?.node?.mediaItemUrl ?? '',
            ),
          ),
          SizedBox(height: 10.h),
          if (data?.listenQuran?.listenQuranDescription?.isNotEmpty ??
              false) ...[
            // Html(data: data?.content ?? ''),

            Text(
              data?.listenQuran?.listenQuranDescription ?? '',
              style: AppFontStyle.poppinsRegular.copyWith(
                fontSize: 16.sp,
                color: AppColors.appBgColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget player(int index, String path) {
    return BlocBuilder<PlayerBloc, PlayerState>(
      builder: (context, state) {
        bool isLoading = (state.loading) && (clickedIndex == index);
        bool isPlaying = state.isPlaying && (clickedIndex == index);
        return Center(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  if (isLoading) return;
                  state.isPlaying ? _pause() : _play(path);
                  setState(() {
                    clickedIndex = index;
                  });
                },
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(5),
                  backgroundColor: AppColors.iconButtonColor,
                  foregroundColor: AppColors.bgLightWhitColor,
                ),
                child: isLoading
                    ? SizedBox(
                        height: 30.w,
                        width: 30.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.w,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.white,
                          ),
                          backgroundColor: AppColors.white.withOpacity(0.5),
                        ),
                      )
                    : Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow,
                        color: AppColors.white,
                      ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: LinearProgressIndicator(
                    borderRadius: BorderRadius.circular(10),
                    backgroundColor: Colors.grey.withOpacity(.1),
                    // color: blueBackground,
                    value: (clickedIndex == index) ? state.progress : 0,
                  ),
                ),
              ),
              if (isPlaying) ...[
                Text(
                  state.duration ?? '',
                  style: AppFontStyle.dmSansRegular.copyWith(
                    color: AppColors.listBorderColor,
                  ),
                ),
              ],
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.volume_up_rounded),
              ),
            ],
          ),
        );
      },
    );
  }

  void _play(String path) {
    globalPlayerBloc.add(OnPlayEvent(file: path));
  }

  void _pause() {
    globalPlayerBloc.add(PlayPauseEvent(isPlaying: false, progress: 0));
  }

  Widget _headerView() {
    return customAppBar(
      showPrefixIcon: true,
      onClick: () async {
        globalPlayerBloc.player.pause();
        // globalPlayerBloc.add(OnResetPlayStatesEvent());
        Get.back();
      },
      suffixIcons: [
        Padding(
          padding: EdgeInsets.only(left: 20.w, right: 20.w),
          child: customIcon(
            onClick: () {
              globalPlayerBloc.player.pause();
              // globalPlayerBloc.add(OnResetPlayStatesEvent());
              Get.toNamed(Routes.menuPage);
            },
            icon: AssetImages.icMenu,
            iconColor: AppColors.white,
          ),
        ),
      ],
    );
  }
}
