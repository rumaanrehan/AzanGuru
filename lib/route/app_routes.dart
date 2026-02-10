import 'package:azan_guru_mobile/ui/help_module/answer_detail_page.dart';
import 'package:azan_guru_mobile/ui/help_module/help_page.dart';
import 'package:azan_guru_mobile/ui/help_module/live_chat_page.dart';
import 'package:azan_guru_mobile/ui/help_module/question_answer_page.dart';
import 'package:azan_guru_mobile/ui/help_module/question_message_page.dart';
import 'package:azan_guru_mobile/ui/home_module/course_detail_module/course_complete_success.dart';
import 'package:azan_guru_mobile/ui/home_module/course_detail_module/course_detail_page.dart';
import 'package:azan_guru_mobile/ui/home_module/course_detail_module/home_work_screen.dart';
import 'package:azan_guru_mobile/ui/home_module/course_detail_module/lesson_detail_page.dart';
import 'package:azan_guru_mobile/ui/home_module/course_selection_question_module/choose_course_page.dart';
import 'package:azan_guru_mobile/ui/home_module/course_selection_question_module/course_suggestion_page.dart';
import 'package:azan_guru_mobile/ui/home_module/home_page.dart';
import 'package:azan_guru_mobile/ui/home_module/notification_module/notification_page.dart';
import 'package:azan_guru_mobile/ui/home_module/plan_screen.dart';
import 'package:azan_guru_mobile/ui/listen_quran/listen_quran_screen.dart';
import 'package:azan_guru_mobile/ui/lrf_module/login_page.dart';
import 'package:azan_guru_mobile/ui/lrf_module/register_page.dart';
import 'package:azan_guru_mobile/ui/lrf_module/reset_password_page.dart';
import 'package:azan_guru_mobile/ui/lrf_module/forgot_password_page.dart';
import 'package:azan_guru_mobile/ui/lrf_module/select_language_page.dart';
import 'package:azan_guru_mobile/ui/my_subscription/my_subscription_screen.dart';
import 'package:azan_guru_mobile/ui/ag_webview_page.dart';
import 'package:azan_guru_mobile/ui/profile_module/change_password_page.dart';
import 'package:azan_guru_mobile/ui/profile_module/menu_module/delete_account_detail_page.dart';
import 'package:azan_guru_mobile/ui/profile_module/menu_module/menu_page.dart';
import 'package:azan_guru_mobile/ui/profile_module/menu_module/setting_page.dart';
import 'package:azan_guru_mobile/ui/profile_module/profile_page.dart';
import 'package:azan_guru_mobile/ui/tabbar/tabbar_page.dart';
import 'package:get/get.dart';
import 'package:azan_guru_mobile/ui/splash/splash_screen.dart';
import 'package:azan_guru_mobile/ui/course_module/course_selection_screen.dart';
import 'package:azan_guru_mobile/ui/course_module/course_screen.dart';
import 'package:azan_guru_mobile/ui/my_course/my_course_page.dart';

import 'package:flutter/material.dart';


class AppPages {
  static final routes = [
    GetPage(
      name: Routes.login,
      page: () => const LoginPage(),
    ),
    GetPage(
      name: Routes.selectLanguagePage,
      page: () => const SelectLanguagePage(),
    ),
    GetPage(
      name: Routes.registerPage,
      page: () => const RegisterPage(),
    ),
    GetPage(
      name: Routes.resetPasswordPage,
      page: () => const ResetPasswordPage(),
    ),
    GetPage(
      name: Routes.forgotPasswordPage,
      page: () => const ForgotPasswordPage(),
    ),
    GetPage(
      name: Routes.tabBarPage,
      page: () => const TabBarPage(),
    ),
    GetPage(
      name: Routes.homePage,
      page: () => const HomePage(),
    ),
    GetPage(
      name: Routes.changePasswordPage,
      page: () => const ChangePasswordPage(),
    ),
    GetPage(
      name: Routes.helpPage,
      page: () => const HelpPage(),
    ),
    GetPage(
      name: Routes.questionAnswerPage,
      page: () => const QuestionAnswerPage(),
    ),
    GetPage(
      name: Routes.answerDetailPage,
      page: () => const AnswerDetailPage(),
    ),
    GetPage(
      name: Routes.questionMessagePage,
      page: () => const QuestionMessagePage(),
    ),
    GetPage(
      name: Routes.liveChatPage,
      page: () => const LiveChatPage(),
    ),
    GetPage(
      name: Routes.chooseCoursePage,
      page: () => const ChooseCoursePage(),
    ),
    GetPage(
      name: Routes.courseDetailPage,
      page: () => const CourseDetailPage(),
    ),
    GetPage(
      name: Routes.notificationPage,
      page: () => const NotificationPage(),
    ),
    GetPage(
      name: Routes.menuPage,
      page: () => const MenuPage(),
    ),
    GetPage(
      name: Routes.lessonDetailPage,
      page: () => const LessonDetailPage(),
    ),
    GetPage(
      name: Routes.agWebViewPage,
      page: () => const AGWebViewPage(),
    ),
    GetPage(
      name: Routes.deleteAccountDetailPage,
      page: () => const DeleteAccountDetailPage(),
    ),
    GetPage(
      name: Routes.settingPage,
      page: () => const SettingPage(),
    ),
    GetPage(
      name: Routes.courseSuggestionPage,
      page: () => const CourseSuggestionTile(),
    ),
    GetPage(
      name: Routes.myProfile,
      page: () => const ProfilePage(),
    ),
    GetPage(
      name: Routes.mySubscription,
      page: () => const MySubscriptionScreen(),
    ),
    GetPage(
      name: Routes.listenQuran,
      page: () => const ListenQuranScreen(),
    ),
    GetPage(
      name: Routes.homeWork,
      page: () => const HomeWorkScreen(),
    ),
    GetPage(
      name: Routes.courseCompleteSuccessPage,
      page: () => const CourseCompleteSuccessPage(),
    ),
    GetPage(
      name: Routes.planPage,
      page: () => const PlanScreen(),
    ),
    GetPage(
      name: Routes.splash,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: Routes.selectCourse,
      page: () => const CourseSelectionScreen(),
    ),
    GetPage(
      name: Routes.course,
      page: () => const CourseScreen(),
    ),
    GetPage(
      name: Routes.myCourses,
      page: () => const MyCoursePage(),
    ),
  ];
}

class Routes {
  static const login = '/login';
  static const selectLanguagePage = '/selectLanguagePage';
  static const registerPage = '/registerPage';
  static const resetPasswordPage = '/resetPasswordPage';
  static const forgotPasswordPage = '/forgotPasswordPage';
  static const tabBarPage = '/tabBarPage';
  static const homePage = '/homePage';
  static const changePasswordPage = '/changePasswordPage';
  static const helpPage = '/helpPage';
  static const questionAnswerPage = '/questionAnswerPage';
  static const answerDetailPage = '/answerDetailPage';
  static const questionMessagePage = '/questionMessagePage';
  static const liveChatPage = '/liveChatPage';
  static const chooseCoursePage = '/chooseCoursePage';
  static const courseDetailPage = '/courseDetailPage';
  static const notificationPage = '/notificationPage';
  static const menuPage = '/menuPage';
  static const lessonDetailPage = '/courseDetailVideoPlayPage';
  static const agWebViewPage = '/paymentWebViewPage';
  static const deleteAccountDetailPage = '/deleteAccountDetailPage';
  static const settingPage = '/settingPage';
  static const courseSuggestionPage = '/courseSuggestionTile';
  static const myProfile = '/myProfile';
  static const mySubscription = '/mySubscription';
  static const listenQuran = '/listenQuran';
  static const homeWork = '/homeWork';
  static const courseCompleteSuccessPage = '/courseCompleteSuccessPage';
  static const planPage = '/planPage';
  static const splash = '/splash';
  static const selectCourse = '/selectCourse';
  static const course = '/course';
  static const String myCourses = '/my-courses';
}
