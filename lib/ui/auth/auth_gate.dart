import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../route/app_routes.dart';
import '../../service/local_storage/local_storage_keys.dart';
import '../../service/local_storage/storage_manager.dart';
import 'package:azan_guru_mobile/ui/lrf_module/login_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final token =
    StorageManager.instance.getString(LocalStorageKeys.prefAuthToken);

    if (token != null && token.isNotEmpty) {
      /// Already authenticated → go to home
      Future.microtask(() {
        Get.offAllNamed(Routes.tabBarPage);
      });

      return const SizedBox.shrink();
    }

    /// Not authenticated → show login
    return const LoginPage();
  }

}
