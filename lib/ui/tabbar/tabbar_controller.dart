import 'package:flutter/material.dart';

class TabBarController {
  TabBarController._internal();

  static final TabBarController _instance = TabBarController._internal();
  static TabBarController get instance => _instance;
  var pageController = PageController();
}