import 'package:azan_guru_mobile/common/util.dart';
import 'package:azan_guru_mobile/constant/app_colors.dart';
import 'package:azan_guru_mobile/service/local_storage/local_storage_keys.dart';
import 'package:azan_guru_mobile/service/local_storage/storage_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AGWebViewPage extends StatefulWidget {
  const AGWebViewPage({super.key});

  @override
  State<AGWebViewPage> createState() => _AGWebViewPageState();
}

class _AGWebViewPageState extends State<AGWebViewPage> {
  late final WebViewController _controller;
  String url = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    if (Get.arguments is String) {
      url = Get.arguments as String;
    }

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) async {
            final url = request.url;

            // Handle deep links
            if (url.startsWith('azanguru://')) {
              final uri = Uri.parse(url);
              await launchUrl(uri, mode: LaunchMode.externalApplication);
              if (mounted) Get.back();
              return NavigationDecision.prevent;
            }

            // Handle other custom schemes (e.g. mailto, tel, etc.)
            if (!url.startsWith('http://') && !url.startsWith('https://')) {
              final uri = Uri.parse(url);
              await launchUrl(uri, mode: LaunchMode.externalApplication);
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
          onPageStarted: (value) {
            setState(() => isLoading = true);
            debugPrint("Page started: $value");
          },
          onPageFinished: (value) {
            setState(() => isLoading = false);
          },
          onWebResourceError: (error) {
            debugPrint('WebView error: ${error.description}');
          },
        ),
      );

    _loadRequest();
  }

  Future<void> _loadRequest() async {
    // Clear cookies to ensure clean session for JWT auth
    final cookieManager = WebViewCookieManager();
    await cookieManager.clearCookies();

    // Retrieve the auth token to pass the session to the WebView
    final token = StorageManager.instance.getString(LocalStorageKeys.prefAuthToken);
    // Use databaseId as a stable session identifier for the fingerprint
    final deviceId = StorageManager.instance.getString(LocalStorageKeys.prefDatabaseId);

    final Map<String, String> headers = {};
    if (token.isNotEmpty) {
      // Standard Auth header (kept for compatibility)
      headers['Authorization'] = 'Bearer $token';
      // Specific header for the strict token-bound PHP script
      headers['X-AG-WV-TOKEN'] = token;
    }

    if (deviceId.isNotEmpty) {
      // Provide a stable ID for fingerprinting
      headers['X-AG-DEVICE'] = deviceId;
    }

    if (mounted) {
      _controller.loadRequest(Uri.parse(url), headers: headers);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLightWhitColor,
      body: Column(
        children: [
          _headerView(),
          Expanded(
            child: Container(
              height: Get.height,
              width: Get.width,
              color: Colors.white,
              child: Stack(
                children: <Widget>[
                  WebViewWidget(controller: _controller),
                  if (isLoading)
                    Center(
                      child: CircularProgressIndicator(
                        color: AppColors.appBgColor,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerView() {
    return customAppBar(
      showPrefixIcon: true,
      showTitle: true,
      title: "",
      onClick: () {
        Get.back();
      },
      backgroundColor: AppColors.appBgColor,
      suffixIcons: const [],
    );
  }
}
