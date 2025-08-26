import 'package:flutter/material.dart';
import 'package:azan_guru_mobile/main.dart'; // contains navigatorKey
import 'package:azan_guru_mobile/ui/common/loader.dart';

void showGlobalLoader() {
  final ctx = navigatorKey.currentContext;
  if (ctx != null && !AGLoader.isShown) {
    AGLoader.show(ctx);
  }
}

void hideGlobalLoader() {
  if (AGLoader.isShown) {
    AGLoader.hide();
  }
}
