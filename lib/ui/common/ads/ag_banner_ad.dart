import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:azan_guru_mobile/bloc/my_course_bloc/my_course_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:azan_guru_mobile/service/local_storage/storage_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:azan_guru_mobile/route/app_routes.dart';
import 'package:azan_guru_mobile/service/local_storage/local_storage_keys.dart';
import 'package:azan_guru_mobile/common/util.dart';


class AGBannerAd extends StatefulWidget {
  final AdSize adSize;
  const AGBannerAd({super.key, this.adSize = AdSize.banner});

  @override
  State<AGBannerAd> createState() => _AGBannerAdState();
}

class _AGBannerAdState extends State<AGBannerAd> {
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;
  bool _shouldShowAd = true;
  int _pollAttempts = 0;
  String get token =>
      StorageManager.instance.getString(LocalStorageKeys.prefAuthToken);

  @override
  void initState() {
    super.initState();
    _waitForStorageReady();
  }

  Future<void> _waitForStorageReady() async {
    /// Poll up to 20 times every 100ms (max 2s wait) until values are ready.
    while (_pollAttempts < 20) {
      final user = StorageManager.instance.getLoginUser();
      final hasSubscription = StorageManager.instance.getBool(LocalStorageKeys.isUserHasSubscription);
      final hasPurchase = StorageManager.instance.getBool(LocalStorageKeys.isCoursePurchased);

      if (user != null && hasSubscription || user != null && hasPurchase) {
        setState(() => _shouldShowAd = false);
        return;
      }

      if (user != null || _pollAttempts >= 5) {
        // If no subscription/purchase after some polls, assume not eligible.
        break;
      }

      _pollAttempts++;
      await Future.delayed(const Duration(milliseconds: 100));
    }

    // If not eligible, load the ad
    _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-2406981209450136/3506000660',
      size: widget.adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => setState(() => _isBannerAdReady = true),
        onAdFailedToLoad: (ad, error) {
          print('Ad failed: ${error.message}');
          ad.dispose();
        },
      ),
    )..load();
  }
  void _showRemoveAdsDialog() {
    final user = StorageManager.instance.getLoginUser();
    const baseUrl = 'https://azanguru.com/';

    final url =
        '${baseUrl}checkout/?add-to-cart=28543&variation_id=45891&attribute_pa_subscription-pricing=monthly&ag_course_dropdown=10&ag_wv_token=${Uri.encodeQueryComponent(token)}&utm_source=AppWebView'
        '${user != null ? '&student_id=${user.databaseId}' : ''}';

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFddece7),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "🚫 Remove Ads & Learn Better",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Subscribe now to enjoy an ad-free experience and get live teacher assistance to master Quranic learning.",
                  style: TextStyle(
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 14),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4D8974),
                    minimumSize: const Size.fromHeight(44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();                    debugPrint('url===> $url');
                    launchUrlInExternalBrowser(url);
                  },
                  child: const Text(
                    "Subscribe Now →",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      "Not Now",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }



  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyCourseBloc, MyCourseState>(
      builder: (context, state) {
        bool isPurchased = false;
        if (state is GetMyCourseState && (state.nodes?.isNotEmpty ?? false)) {
          isPurchased = true;
        }

        if (isPurchased || !_shouldShowAd || !_isBannerAdReady || _bannerAd == null) {
          return const SizedBox.shrink();
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
            ),
            TextButton(
              onPressed: _showRemoveAdsDialog,
              child: const Text(
                'Remove Ads?',
                style: TextStyle(
                  fontSize: 14,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
