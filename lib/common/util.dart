import 'dart:io';

import 'package:azan_guru_mobile/constant/app_assets.dart';
import 'package:azan_guru_mobile/constant/app_colors.dart';
import 'package:azan_guru_mobile/constant/font_style.dart';
import 'package:azan_guru_mobile/service/local_storage/storage_manager.dart';
import 'package:azan_guru_mobile/ui/common/alert/custom_alert.dart';
import 'package:azan_guru_mobile/ui/common/alert/normal_custom_alert.dart';
import 'package:azan_guru_mobile/ui/model/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:azan_guru_mobile/route/app_routes.dart';

import '../service/local_storage/local_storage_keys.dart';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../entities/app_version.dart';
import '../graphQL/queries.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> launchUrlInExternalBrowser(String url) async {
  if (await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  } else {
    debugPrint('Could not launch $url');
  }
}

Future<bool> isUpdateRequired(GraphQLClient client) async {
  final result = await client.query(
    QueryOptions(
      document: gql(AzanGuruQueries.fetchAppVersionsQuery),
    ),
  );

  if (result.hasException || result.data == null) {
    return false;
  }

  final versions = AppVersion.fromJson(result.data!['appVersions']);
  final info = await PackageInfo.fromPlatform();
  final currentVersion = info.version;

  final latest = Platform.isAndroid ? versions.android : versions.ios;
  return _compareVersion(currentVersion, latest) < 0;
}

/// Returns -1 if [a] < [b], 0 if equal, 1 if [a] > [b]
int _compareVersion(String a, String b) {
  final aParts = a.split('.').map(int.parse).toList();
  final bParts = b.split('.').map(int.parse).toList();

  for (int i = 0; i < 3; i++) {
    if (aParts[i] < bParts[i]) return -1;
    if (aParts[i] > bParts[i]) return 1;
  }
  return 0;
}

// const String baseUrl = 'https://staging.azanguru.com/';
const String baseUrl = 'https://azanguru.com/';

AppBar customAppBar({
  Widget? titleWidget,
  Function()? onClick,
  String? prefixIcon,
  String? title,
  String? suffixIconSetting,
  bool showPrefixIcon = false,
  bool centerTitle = false,
  bool showTitle = false,
  List<Widget>? suffixIcons,
  Color? backgroundColor,
  SystemUiOverlayStyle systemOverlayStyle = SystemUiOverlayStyle.light,
}) {
  return AppBar(
    backgroundColor: backgroundColor ?? Colors.transparent,
    toolbarHeight: 55.h,
    iconTheme: const IconThemeData(
      color: Colors.white,
    ),
    scrolledUnderElevation: 0,
    elevation: 0,
    titleSpacing: 0,
    systemOverlayStyle: systemOverlayStyle,
    automaticallyImplyLeading: true,
    centerTitle: centerTitle,
    leading: showPrefixIcon
        ? customIcon(onClick: onClick, icon: prefixIcon)
        : const SizedBox.shrink(),
    title: showTitle
        ? titleWidget ??
            Text(
              title ?? '',
              textAlign: TextAlign.center,
              style: AppFontStyle.dmSansSemiBold.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w400,
              ),
            )
        : const SizedBox.shrink(),
    actions: suffixIcons,
  );
}

Widget customIcon({
  Function()? onClick,
  String? icon,
  double? height,
  double? width,
  Color? iconColor,
}) {
  return InkWell(
    splashColor: Colors.transparent,
    focusColor: Colors.transparent,
    highlightColor: Colors.transparent,
    hoverColor: Colors.transparent,
    onTap: onClick,
    child: Container(
      alignment: Alignment.center,
      height: height ?? 25.h,
      width: width ?? 25.h,
      child: iconColor == null
          ? SvgPicture.asset(
              icon ?? AssetImages.icArrowBack,
              fit: BoxFit.scaleDown,
            )
          : SvgPicture.asset(
              icon ?? AssetImages.icArrowBack,
              fit: BoxFit.scaleDown,
              colorFilter: ColorFilter.mode(
                iconColor,
                BlendMode.srcIn,
              ),
            ),
    ),
  );
}

Widget customTopContainer({
  double? height,
  required String bgImage,
  Widget? insideChild,
  double? radius,
  BoxFit? fit,
  Color? backgroundColor,
}) {
  return Container(
    height: height,
    width: Get.width,
    clipBehavior: Clip.hardEdge,
    decoration: BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(radius ?? 30.r),
        bottomRight: Radius.circular(radius ?? 30.r),
      ),
    ),
    child: Stack(
      children: [
        if (bgImage.isNotEmpty)
          SizedBox(
            height: height,
            width: Get.width,
            child: Image.asset(
              bgImage,
              fit: fit ?? BoxFit.fill,
              width: Get.width,
            ),
          ),
        SizedBox(
          height: height,
          width: Get.width,
          child: insideChild,
        ),
      ],
    ),
  );
}

Widget customHeader({
  double? height,
  double? radius,
  Color backgroundColor = AppColors.headerColor,
  Widget? insideChild,
}) {
  return Container(
    width: Get.width,
    padding: EdgeInsets.only(
      left: 20.w,
      right: 20.w,
      top: 46.h,
      bottom: 12.h,
    ),
    decoration: BoxDecoration(
      color: backgroundColor,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: insideChild == null
              ? MainAxisAlignment.spaceBetween
              : MainAxisAlignment.start,
          children: [
            Image.asset(
              'assets/images/ag_header_logo.png',
              width: 150.w,
            ),
            if (insideChild == null)
              Row(
                children: [
                  customIcon(
                    iconColor: AppColors.white,
                    onClick: () => Get.toNamed(Routes.menuPage),
                    icon: AssetImages.icMenu,
                  ),
                  SizedBox(width: 20.w),
                  customIcon(
                    onClick: () => Get.toNamed(Routes.notificationPage),
                    icon: AssetImages.icNotification,
                    iconColor: AppColors.white,
                  ),
                ],
              ),
          ],
        ),
        if (insideChild != null)
          Padding(
            padding: EdgeInsets.only(top: 10.h),
            child: insideChild,
          ),
      ],
    ),
  );
}

DateTime? backButtonPressedTime;

Future<bool> performWillPopTwoClick() async {
  DateTime currentTime = DateTime.now();

  bool backButton = backButtonPressedTime == null ||
      currentTime.difference(backButtonPressedTime!) >
          const Duration(seconds: 3);

  if (backButton) {
    final SharedPreferences token = await SharedPreferences.getInstance();
    await token.remove('token');
    backButtonPressedTime = currentTime;
    Fluttertoast.showToast(
      msg: 'Double click to exit app',
      backgroundColor: Colors.black,
      textColor: Colors.white,
    );
    return Future.value(false);
  }
  exit(0);
  // return true;
}

void showErrorDialog(
  BuildContext context,
  String errorMessage, {
  Function? handler,
  String? btnSecond,
  String? btnFirst,
  double? height,
  String? image,
  bool showHorizontalButton = false,
}) {
  CustomAlert.showAlert(
    errorMessage,
    showHorizontalButton: showHorizontalButton,
    btnFirst: btnFirst ?? "Ok",
    btnSecond: btnSecond,
    height: height,
    image: image,
    handler: (index) async {
      if (handler != null) {
        handler(index);
      }
    },
  );
}

void showNormalDialog(
  BuildContext context,
  String message, {
  Function? handler,
  String? btnSecond,
  String? btnFirst,
  double? height,
  bool showIcon = false,
  bool barrierDismissible = false,
}) {
  NormalCustomAlert.showAlert(
    message,
    btnFirst: btnFirst ?? "Ok",
    btnSecond: btnSecond,
    height: height,
    showIcon: showIcon,
    handler: (index) async {
      if (handler != null) {
        handler(index);
      }
    },
    barrierDismissible: barrierDismissible,
  );
}

Widget profileText({String? userName}) {
  return Text(
    userName ?? 'KS',
    style: AppFontStyle.poppinsRegular.copyWith(
      fontWeight: FontWeight.w100,
      fontSize: 53.sp,
      color: AppColors.appBgColor,
    ),
  );
}

BoxDecoration bottomSheetBoxDecoration({
  Color? backgroundColor,
  double? radius,
}) {
  return BoxDecoration(
    color: backgroundColor ?? AppColors.white,
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(20.r),
      topRight: Radius.circular(20.r),
    ),
  );
}

void hideKeyboard(BuildContext context) {
  FocusScope.of(context).requestFocus(FocusNode());
}

KeyboardActionsConfig getKeyboardActionsConfig(
    BuildContext context, List<FocusNode> list) {
  return KeyboardActionsConfig(
    keyboardBarColor: Colors.grey[200],
    nextFocus: true,
    actions: Platform.isIOS
        ? List.generate(
            list.length,
            (i) => KeyboardActionsItem(
              focusNode: list[i],
              toolbarButtons: [
                (node) {
                  return GestureDetector(
                    onTap: () => node.unfocus(),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: _buildDoneButton(),
                    ),
                  );
                },
              ],
            ),
          )
        : [],
  );
}

Widget _buildDoneButton() {
  return Container(
    padding: const EdgeInsets.only(left: 15, right: 15, top: 8, bottom: 8),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8.0),
      color: Colors.transparent,
    ),
    child: const Text(
      'Done',
      style: TextStyle(color: Colors.blue),
    ),
  );
}

User? get user => StorageManager.instance.getLoginUser()?.user;
String? get prefDatabaseId =>
    StorageManager.instance.getString(LocalStorageKeys.prefDatabaseId);

List<String> kidsCourseIds = ['dGVybToxMA==', 'dGVybTo5', 'dGVybToxMQ=='];
List<String> adultCourseIds = ['dGVybToxMw==', 'dGVybToxNg==', 'dGVybToxMg=='];
