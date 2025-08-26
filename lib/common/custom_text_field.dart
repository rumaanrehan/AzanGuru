import 'package:azan_guru_mobile/constant/app_assets.dart';
import 'package:azan_guru_mobile/constant/app_colors.dart';
import 'package:azan_guru_mobile/constant/font_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

// ignore: must_be_immutable
class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;

  // final ChangeThemeState themeState;
  bool obscureText;
  bool readOnly;
  String? suffixIcon;
  String? hideEyeIcon;
  final TextInputType keyBordType;
  int? maxLines;
  int? maxLength;
  int? minLines;
  double? heights;
  TextAlign? textAligns;
  List<TextInputFormatter>? inputFormatters;
  bool isDigitOnly = false;
  bool expands = false;
  final FocusNode? focusNode;
  TextStyle? textStyles;
  final String? hintTexts;
  Function? onChanges;
  TextStyle? textInputTextStyle;
  Color? textFieldBackground;
  double? width;
  bool showTitle = true;
  final Function()? handler;
  bool suffixIconShow;
  Function()? onTap;
  Function()? suffixOnTap;
  Function()? prefixOnTap;
  String? prefixIcon;
  bool prefixIconShow;
  Color? backgroundColor;
  Color? borderColor;
  final TextInputAction? textInputAction;
  Widget? suffixIconWidget;
  BorderRadiusGeometry? borderRadius;
  Color? cursorColor;

  // TextFieldType textFieldType = TextFieldType.textInput;
  TextCapitalization? textCapitalization;
  final void Function(String)? onFieldSubmitted;

  CustomTextField({
    // required this.themeState,
    @required this.controller,
    this.heights,
    this.maxLines,
    this.minLines,
    this.maxLength,
    this.focusNode,
    this.readOnly = false,
    this.expands = false,
    this.isDigitOnly = false,
    this.obscureText = false,
    this.suffixIconShow = false,
    this.suffixIcon,
    this.hideEyeIcon,
    this.keyBordType = TextInputType.text,
    this.inputFormatters,
    this.textAligns,
    this.textStyles,
    this.hintTexts,
    this.onChanges,
    this.textInputTextStyle,
    this.textFieldBackground,
    this.width,
    this.showTitle = true,
    super.key,
    this.handler,
    this.textCapitalization,
    this.onTap,
    this.suffixOnTap,
    this.prefixOnTap,
    this.prefixIcon,
    this.prefixIconShow = false,
    this.textInputAction = TextInputAction.next,
    this.onFieldSubmitted,
    this.backgroundColor,
    this.borderColor,
    this.suffixIconWidget,
    this.borderRadius,
    this.cursorColor,

    // this.textFieldType = TextFieldType.textInput
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  DateTime selectedDateTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
            color: widget.borderColor ?? AppColors.borderTextFieldColor),
        color: widget.backgroundColor ?? AppColors.appBgColor,
        borderRadius: widget.borderRadius ??
            BorderRadius.all(
              Radius.circular(50.r),
            ),
      ),
      height: widget.heights ?? 55.h,
      width: widget.width ?? Get.width,
      alignment: Alignment.center,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          widget.prefixIconShow
              ? _prefixIconButton(image: widget.prefixIcon)
              : const SizedBox.shrink(),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: widget.prefixIconShow ? 5.w : 20.w,
                right: 20.w,
              ),
              child: TextFormField(
                textAlignVertical: TextAlignVertical.top,
                cursorColor: widget.cursorColor ?? AppColors.white,
                textCapitalization:
                    widget.textCapitalization ?? TextCapitalization.none,
                enableInteractiveSelection: true,
                onFieldSubmitted: widget.onFieldSubmitted,
                scrollPadding:
                    EdgeInsets.only(bottom: (widget.heights ?? 60.0) + 10),
                readOnly: widget.readOnly,
                onChanged: (value) => widget.onChanges,
                keyboardAppearance: Brightness.light,
                textAlign: widget.textAligns ?? TextAlign.start,
                expands: widget.expands,
                focusNode: widget.focusNode,
                inputFormatters: widget.inputFormatters,
                keyboardType: widget.keyBordType,
                maxLines: widget.maxLines ?? 1,
                minLines: widget.minLines ?? 1,
                obscureText: widget.obscureText,
                controller: widget.controller,
                textInputAction: widget.textInputAction,
                style: widget.textInputTextStyle ??
                    AppFontStyle.poppinsRegular.copyWith(
                      color: AppColors.white,
                      overflow: TextOverflow.clip,
                      fontWeight: FontWeight.w500,
                    ),
                maxLength: widget.maxLength,
                decoration: InputDecoration(
                  // contentPadding: EdgeInsets.only(bottom: 3.h),
                  hintStyle: widget.textInputTextStyle ??
                      AppFontStyle.poppinsRegular.copyWith(
                        color: AppColors.white,
                      ),
                  hintText: widget.hintTexts,
                  // fillColor: widget.themeState
                  //     .customColors[AppColors.appThemeColor],
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                ),
                onTap: widget.readOnly ? widget.suffixOnTap : widget.onTap,
              ),
            ),
          ),
          _suffixIconButton(),
        ],
      ),
    );
  }

  Widget _prefixIconButton({String? image}) {
    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: widget.prefixOnTap,
      child: Container(
        height: Get.height,
        width: 45.w,
        padding: EdgeInsets.only(left: 20.w),
        child: SvgPicture.asset(image ?? '', fit: BoxFit.scaleDown),
      ),
    );
  }

  Widget _suffixIconButton() {
    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: widget.readOnly
          ? widget.suffixOnTap
          : widget.suffixIconShow
              ? () {
                  setState(() {
                    widget.obscureText = !widget.obscureText;
                  });
                }
              : widget.suffixOnTap,
      child: widget.suffixIconShow
          ? Container(
              height: Get.height,
              padding: EdgeInsets.only(right: 15.w),
              child: SvgPicture.asset(
                widget.obscureText
                    ? AssetImages.icEyeClose
                    : AssetImages.icEyeOpen,
                colorFilter: const ColorFilter.mode(
                  AppColors.white,
                  BlendMode.srcIn,
                ),
              ),
            )
          : widget.suffixIconWidget ?? const SizedBox.shrink(),
    );
  }
}
