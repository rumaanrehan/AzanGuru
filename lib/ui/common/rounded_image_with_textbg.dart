import 'dart:math';
import 'package:azan_guru_mobile/constant/app_colors.dart';
import 'package:azan_guru_mobile/ui/common/string_to_hex.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class RoundedImageWithTextAndBG extends StatelessWidget {
  ///radius of the circle,
  ///Height = radius *2
  ///Width = radius *2
  final double? radius;

  ///Padding arround the loadingWidget
  final double? loaderPadding;

  ///Network Image URL
  ///Send empty if Text with Random Backround needed
  ///If image.isEmpty = true, then the image will be a circle with a random color generated according to the [uniqueId] with [text] as initials in center
  final String image;

  ///Intials of the text will be used to show in the circle
  ///With constant Random Background Color to give effect like Gmail
  final String text;

  ///If Background is provided it will be used
  ///Otherwise Random Color will be assigned
  final Color? backgroudColor;

  ///Unique radix16 String needed to generate Random and Constant Color
  ///For e.g. 'ac170002-7446-1152-8174-46096d7f0000'
  ///or Firebase UID e.g. 'cT3GNJXiWPbB3fExrFHoD42LK263' will work
  final String? uniqueId;

  ///Assest Image path for error Image
  final String? errorImage;

  ///Network Image loading Widget Default is CircularProgressIndicator
  final Widget? loadingWidget;

  ///Loading Widget Circular Progress Indicator Color
  final Color? circularProgressColor;

  ///Color For TEXT intials
  final Color? backgroundTextColor;

  ///TextStyle for TEXT intials
  final TextStyle? textStyle;

  ///Network Image BoxFit
  final BoxFit? fit;

  ///To Show selected Widget
  final bool? isSelected;

  ///Custuom Selection Widget
  final Widget? selectedWidget;

  ///Selection Widget Background Color
  final Color? selectedBackgroundColor;

  ///Callback function onTap of the Widget
  final VoidCallback? onTap;

  const RoundedImageWithTextAndBG({
    super.key,
    this.radius = 16,
    this.loaderPadding = 10,
    required this.image,
    required this.text,
    this.backgroudColor,
    this.uniqueId,
    this.errorImage,
    this.loadingWidget,
    this.circularProgressColor,
    this.backgroundTextColor = Colors.white,
    this.textStyle = const TextStyle(
      fontSize: 11,
      height: 16 / 11,
      fontWeight: FontWeight.w500,
    ),
    this.fit = BoxFit.cover,
    this.isSelected = false,
    this.selectedBackgroundColor,
    this.selectedWidget,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = Size(radius! * 2, radius! * 2);
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: size.height,
        width: size.width,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius!),
          child: (isSelected ?? false)
              ? selectedWidget ??
                  Container(
                    height: size.height,
                    width: size.width,
                    color: selectedBackgroundColor ?? Colors.green[400],
                    child: Icon(
                      Icons.done,
                      size: radius,
                      color: Colors.white,
                    ),
                  )
              : Container(
                  height: size.height,
                  width: size.width,
                  alignment: Alignment.center,
                  color: backgroudColor ?? generateRandomColor(),
                  child: image.isNotEmpty
                      ? Image.network(
                          image,
                          alignment: Alignment.center,
                          height: size.height,
                          width: size.width,
                          errorBuilder: (ctx, err, _) => _InitialsWidget(
                            text: text,
                            textColor: backgroudColor ?? Colors.white,
                            textStyle: textStyle ??
                                const TextStyle(
                                  fontSize: 11,
                                  height: 16 / 11,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return loadingWidget ??
                                Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(loaderPadding!),
                                    child: CircularProgressIndicator(
                                      color: circularProgressColor ??
                                          AppColors.primaryColor,
                                    ),
                                  ),
                                );
                          },
                          fit: fit,
                        )
                      : _InitialsWidget(
                          text: text,
                          textColor: Colors.white,
                          textStyle: textStyle ??
                              const TextStyle(
                                fontSize: 11,
                                height: 16 / 11,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                ),
        ),
      ),
    );
  }

  Color generateRandomColor() {
    Random random = Random();
    int lengthFactor = (text.isEmpty ? 1 : text.length) % 9;
    if (lengthFactor == 0) {
      lengthFactor = 9;
    }
    int shadeFactor = random.nextInt(lengthFactor) * 100;
    if (shadeFactor < 500) {
      shadeFactor += 500;
    }
    Color? randomColor = Colors
        .primaries[random.nextInt(Colors.primaries.length)][shadeFactor]
        ?.withOpacity(0.9);

    Color? hexColor;
    if (uniqueId != null) {
      hexColor = getColorFromString(uniqueId ?? '').withOpacity(0.5);
    }
    return hexColor ?? randomColor ?? Colors.black;
  }
}

class _InitialsWidget extends StatelessWidget {
  final String text;
  final TextStyle textStyle;
  final Color textColor;
  const _InitialsWidget({
    required this.text,
    required this.textStyle,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Text(
        getNameInitials(),
        style: textStyle.copyWith(color: textColor),
        textAlign: TextAlign.center,
      ),
    );
  }

  List<String> splitStringBySpaceAndTrim() {
    // Split the string by all whitespace characters (including spaces, tabs, etc.)
    final List<String> words = text.split(RegExp(r"\s+"));

    // Trim leading and trailing whitespaces from each word
    return words.map((word) => word.trim()).toList();
  }

  String getNameInitials() {
    if (text.trim().isEmpty) return 'AG';
    if (text.trim().contains(' ')) {
      List<String> splitArray = splitStringBySpaceAndTrim();
      return splitArray[0][0].toUpperCase() + splitArray[1][0].toUpperCase();
    } else {
      return (text.trim().length < 2)
          ? text.trim()
          : text.trim().substring(0, 2).toUpperCase();
    }
    // String initials = text.trim().contains(' ')
    //     ? text.trim().split(' ')[0][0].toUpperCase() +
    //         text.trim().split(' ')[1][0].toUpperCase()
    //     : (text.trim().length < 2)
    //         ? text.trim()
    //         : text.trim().substring(0, 2).toUpperCase();
    // return initials;
  }
}

///To Get Color from String
///Send Radix 16 String as Param For e.g. 'ac170002-7446-1152-8174-46096d7f0000'
Color getColorFromString(String radix16String) {
  ///Giving a default color if radix16String is not valid
  Color hexColor = Colors.blue;
  try {
    hexColor = Color(StringToHex.toColor(radix16String));
  } catch (e) {
    if (kDebugMode) {
      print('$radix16String is not a valid radix string');
    }
  }
  return hexColor;
}
