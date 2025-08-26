import 'package:azan_guru_mobile/constant/app_assets.dart';
import 'package:azan_guru_mobile/constant/app_colors.dart';
import 'package:azan_guru_mobile/constant/font_style.dart';
import 'package:azan_guru_mobile/route/app_routes.dart';
import 'package:azan_guru_mobile/ui/model/mdl_select_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class SelectLanguagePage extends StatefulWidget {
  const SelectLanguagePage({super.key});

  @override
  State<SelectLanguagePage> createState() => _SelectLanguagePageState();
}

class _SelectLanguagePageState extends State<SelectLanguagePage> {
  List<MDLSelectLanguage> selectLanguage = [
    MDLSelectLanguage(title: 'English', languageCode: 'en'),
    MDLSelectLanguage(title: 'عربي', subTitle: 'Arabic', languageCode: 'ar-sa'),
    MDLSelectLanguage(title: 'اردو', subTitle: 'Urdu', languageCode: 'ur'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBgColor,
      body: SafeArea(
        child: mainBody(),
      ),
    );
  }

  Widget mainBody() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(top: 50.h, bottom: 35.h),
              alignment: Alignment.center,
              child: SvgPicture.asset(AssetImages.icLogo),
            ),
            _tittleText(
              marginBottom: 13.h,
              tittle: "Select your \nPreferred Language",
              // tittle: AppUtils.getLocaleText(context, LanguageKey.langTittle),
            ),
            _tittleText(
              tittle: 'إختر حقك  اللغة المفضلة\n',
            ),
            _tittleText(
              tittle: 'اپنے کو منتخب کریں۔  ترجیحی زبان',
            ),
            SizedBox(height: 90.h),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: selectLanguage.length,
              itemBuilder: (BuildContext ctx, index) {
                var data = selectLanguage[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: 18.h),
                  child: _languageSelectBox(
                    buttonTittle: data.title,
                    buttonSubTittle: data.subTitle,
                    onTap: () {
                      // Locale locale = Locale(data.languageCode);
                      // Get.updateLocale(locale);
                      Get.updateLocale(const Locale('en'));
                      Get.offAllNamed(Routes.login);
                    },
                  ),
                );
              },
            ),
            SizedBox(height: 55.h),
          ],
        ),
      ),
    );
  }

  Widget _tittleText(
      {required String tittle, double? marginBottom, double? marginTop}) {
    return Container(
      margin: EdgeInsets.only(bottom: marginBottom ?? 0, top: marginTop ?? 0),
      alignment: Alignment.center,
      child: Text(
        tittle,
        textAlign: TextAlign.center,
        style: AppFontStyle.playfairDisplayBold.copyWith(
          fontWeight: FontWeight.w400,
          color: AppColors.tittleTextColor,
          height: 1.05,
        ),
      ),
    );
  }

  Widget _languageSelectBox(
      {required String buttonTittle,
      String? buttonSubTittle,
      Function()? onTap}) {
    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onTap,
      child: Container(
        width: Get.width,
        height: 60.h,
        padding: EdgeInsets.symmetric(horizontal: 30.w),
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 1, color: AppColors.borderColor),
            borderRadius: BorderRadius.circular(49.r),
          ),
        ),
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisAlignment: buttonSubTittle?.isNotEmpty ?? false
              ? MainAxisAlignment.start
              : MainAxisAlignment.spaceBetween,
          children: [
            Text(
              buttonTittle,
              textAlign: TextAlign.center,
              style: AppFontStyle.poppinsRegular.copyWith(
                fontSize: 15.sp,
                color: AppColors.white,
              ),
            ),
            SizedBox(width: buttonSubTittle?.isNotEmpty ?? false ? 25.w : 0),
            buttonSubTittle?.isNotEmpty ?? false
                ? Text(
                    buttonSubTittle ?? '',
                    textAlign: TextAlign.center,
                    style: AppFontStyle.poppinsRegular.copyWith(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w300,
                      color: AppColors.greyColor,
                    ),
                  )
                : const SizedBox.shrink(),
            const Spacer(),
            SizedBox(
              height: 20.h,
              width: 15.h,
              child: SvgPicture.asset(AssetImages.icArrowForword),
            ),
          ],
        ),
      ),
    );
  }
}
