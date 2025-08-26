import 'package:azan_guru_mobile/constant/app_assets.dart';
import 'package:azan_guru_mobile/constant/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// AGImageView is a widget that displays a network image.
/// It handles placeholder and error widgets.
class AGImageView extends StatelessWidget {
  ///Network Image URL
  final String image;

  ///The width of the image.
  final double? width;

  ///The height of the image.
  final double? height;

  ///How the image should be inscribed into the space allocated during layout.
  final BoxFit? fit;

  ///Constructor for AGImageView.
  const AGImageView(
    this.image, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      // The height of the image.
      height: height,

      // The width of the image.
      width: width,

      // The network image URL.
      imageUrl: image,

      // How the image should be inscribed into the space allocated during layout.
      fit: fit,

      // Widget to display while the target image is loading.
      placeholder: (context, url) => Center(
        child: SizedBox(
          height: 20.0,
          width: 20.0,
          child: CircularProgressIndicator(
            color: AppColors.primaryColor,
            strokeWidth: 1.5,
          ),
        ),
      ),

      // Widget to display if the target image fails to load.
      errorWidget: (context, url, error) => Center(
        child: SvgPicture.asset(
          AssetImages.icLogo,
          fit: BoxFit.scaleDown,
        ),
      ),
    );
  }
}
