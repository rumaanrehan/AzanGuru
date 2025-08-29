import 'package:azan_guru_mobile/common/util.dart';
import 'package:azan_guru_mobile/constant/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart'; // <-- NEW

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
          // KEY: intercept deep links / non-http(s) before WebView tries to load them
          onNavigationRequest: (NavigationRequest request) async {
            final url = request.url;

            // Handle our deep link
            if (url.startsWith('azanguru://')) {
              final uri = Uri.parse(url);
              await launchUrl(uri, mode: LaunchMode.externalApplication);
              if (mounted) Get.back(); // close WebView
              return NavigationDecision.prevent;
            }

            // Handle other custom schemes
            if (!url.startsWith('http://') && !url.startsWith('https://')) {
              final uri = Uri.parse(url);
              await launchUrl(uri, mode: LaunchMode.externalApplication);
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },

          onPageStarted: (value) {
            setState(() => isLoading = true);
            debugPrint("PAYMENT onPageStarted: $value");
          },
          onPageFinished: (value) {
            setState(() => isLoading = false);
          },
          onWebResourceError: (error) {
            debugPrint('WebView error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
  }

  bool _isHttpLike(String u) =>
      u.startsWith('http://') || u.startsWith('https://');

  Future<void> _openExternally(String u) async {
    final uri = Uri.parse(u);
    // Try opening with external application (so Android/iOS handle the intent)
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Cannot launch: $u');
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
