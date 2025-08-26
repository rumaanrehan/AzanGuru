import 'package:azan_guru_mobile/common/util.dart';
import 'package:azan_guru_mobile/constant/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AGWebViewPage extends StatefulWidget {
  const AGWebViewPage({super.key});

  @override
  State<AGWebViewPage> createState() => _AGWebViewPageState();
}

class _AGWebViewPageState extends State<AGWebViewPage> {
  // https://staging.azanguru.com/student-rec/?student_id=32
  // String get paymentUrl =>
  //     '${baseUrl}student-rec/?student_id=${user?.databaseId.toString()}';
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
                  isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: AppColors.appBgColor,
                          ),
                        )
                      : const Stack(),
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
      suffixIcons: [],
    );
  }
}
