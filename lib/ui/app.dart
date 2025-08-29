import 'dart:async';
import 'dart:developer' show log;
import 'package:audioplayers/audioplayers.dart' show AudioPlayer;
import 'package:azan_guru_mobile/bloc/course_detail_bloc/course_detail_bloc.dart';
import 'package:azan_guru_mobile/bloc/firebase_bloc/firebase_bloc.dart';
import 'package:azan_guru_mobile/bloc/in_app_purchase_bloc/in_app_purchase_bloc.dart';
import 'package:azan_guru_mobile/bloc/my_course_bloc/my_course_bloc.dart';
import 'package:azan_guru_mobile/bloc/player_bloc/player_bloc.dart';
import 'package:azan_guru_mobile/bloc/video_bloc/video_bloc.dart';
import 'package:azan_guru_mobile/common/util.dart';
import 'package:azan_guru_mobile/firebase_message_sevice.dart';
import 'package:azan_guru_mobile/route/app_routes.dart';
import 'package:azan_guru_mobile/service/local_storage/local_storage_keys.dart';
import 'package:azan_guru_mobile/service/local_storage/storage_manager.dart';
import 'package:azan_guru_mobile/service/localization/app_translation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_meta_sdk/flutter_meta_sdk.dart' show FlutterMetaSdk;
import 'package:flutter_screenutil/flutter_screenutil.dart' show ScreenUtilInit;
import 'package:get/get.dart';
import 'package:overlay_support/overlay_support.dart' show OverlaySupport;
import 'package:app_links/app_links.dart';
import 'package:azan_guru_mobile/ui/splash/splash_screen.dart';
import 'package:azan_guru_mobile/ui/force_update_screen.dart';
//import 'package:azan_guru_mobile/main.dart'; // Required for navigatorKey

// use your existing LoginBloc + login model
import 'package:azan_guru_mobile/bloc/lrf_module/login_module/login_bloc.dart';
import 'package:azan_guru_mobile/ui/model/mdl_login_param.dart';




PlayerBloc get globalPlayerBloc => Get.key.currentContext!.read<PlayerBloc>();

class App extends StatefulWidget {
  final bool forceUpdate;
  const App({super.key, this.forceUpdate = false});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  StreamSubscription? _sub;
  bool _hasVisibleNoInternet = false;
  static final metaSdk = FlutterMetaSdk();

  /// Initializes the app by handling the deep link, observing the widgets
  /// binding, configuring the internet connectivity, initializing the FCM and
  /// calling the parent's init state.
  ///
  /// This function is called when the app is initialized.
  @override
  void initState() {
    super.initState();

    // Handle the deep link by getting the initial link and listening to the
    // link stream.
    handleDeepLink();

    // Observe the widgets binding to listen to the app's life cycle events.
    WidgetsBinding.instance.addObserver(this);

    // Configure the internet connectivity after a delay of 1 second.
    Future.delayed(const Duration(seconds: 1)).then((value) {
      _configureInternetConnectivity();
    });

    // Initialize the FCM.
    initFcm();
  }

  /// Handles the deep link by getting the initial link and listening to the link
  /// stream.
  ///
  /// This function gets the initial link using the `getInitialLink` function and
  /// handles it by calling the `handleLink` function. It then listens to the link
  /// stream using the `linkStream` stream and calls the `handleLink` function
  /// whenever a new link is received. If there is an error, it logs the error.
  void handleDeepLink() async {
    final appLinks = AppLinks();

    try {
      // Get the initial deep link
      final Uri? initialUri = await appLinks.getInitialAppLink();
      if (initialUri != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          handleLink(initialUri.toString());
        });
      }
    } catch (e) {
      debugPrint('Error retrieving initial link: $e');
    }

    // Listen to deep link changes
    // appLinks.uriLinkStream.listen(
    //   (Uri? uri) {
    //     if (uri != null) {
    //       handleLink(uri.toString());
    //     }
    //   },
    //   onError: (err) {
    //     debugPrint('Error in deep link stream: $err');
    //   },
    // );
    // Listen to deep link changes
    _sub = appLinks.uriLinkStream.listen(
      (Uri? uri) {
        if (uri != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            handleLink(uri.toString());
          });
        }
      },
      onError: (err) {
        debugPrint('Error in deep link stream: $err');
      },
    );

  }

  /// Handles the incoming URL links targeting the application.
  ///
  /// This function parses the given [link] and processes it based on its scheme and host.
  /// URLs with the 'http' or 'https' scheme are further checked for their host. If the
  /// host is 'azanguru.com', it triggers the initialization of the main screen. For all
  /// other hosts, or unsupported URL schemes, it logs a corresponding message.
  ///
  /// [link] The URL link as a string.
  void handleLink(String link) async {
    final uri = Uri.parse(link);

    // 1) Our custom deep link from Thank You page
    if (uri.scheme == 'azanguru' && uri.host == 'auth' && uri.path == '/complete') {
      final email = uri.queryParameters['email'];
      final phone = uri.queryParameters['phone']; // phone used as password

      if (email == null || phone == null) {
        debugPrint('Deep link missing email/phone.');
        return;
      }

      await _autoLoginFromDeepLink(email: email, password: phone);
      return;
    }

    // 2) Keep your existing http/https behavior
    if (uri.scheme == 'http' || uri.scheme == 'https') {
      if (uri.host == 'azanguru.com') {
        debugPrint('Redirecting to main screen for $uri');
        _initMainScreen();
      } else {
        debugPrint('Unknown Host $uri');
      }
      return;
    }

    debugPrint('Unsupported scheme: ${uri.scheme}');
  }


  Future<void> _autoLoginFromDeepLink({
    required String email,
    required String password,
  }) async {
    try {
      // If already logged in → go to My Courses tab
      final alreadyLoggedIn = StorageManager.instance.getBool(LocalStorageKeys.prefUserLogin) == true;
      if (alreadyLoggedIn) {
        Get.offAllNamed(Routes.tabBarPage, arguments: 1);
        return;
      }

      // Ensure we read LoginBloc from the tree that actually provides it
      BuildContext? ctx = Get.key.currentContext;
      if (ctx == null) {
        // Give the tree a moment to mount
        await Future.delayed(const Duration(milliseconds: 50));
        ctx = Get.key.currentContext;
      }

      LoginBloc? loginBloc;
      if (ctx != null) {
        try {
          loginBloc = ctx.read<LoginBloc>();
        } catch (_) {
          // If still not found, wait once more (cold start edge)
          await Future.delayed(const Duration(milliseconds: 50));
          loginBloc = Get.key.currentContext?.read<LoginBloc>();
        }
      }

      // Fallback: if provider still not available, create a temporary bloc just for this login
      loginBloc ??= LoginBloc();

      // Wait for success/error
      final completer = Completer<bool>();
      late final StreamSubscription sub;
      sub = loginBloc.stream.listen((state) {
        if (state is LoginSuccessState) {
          completer.complete(true);
          sub.cancel();
        } else if (state is LoginErrorState) {
          completer.complete(false);
          sub.cancel();
        }
      });

      // Dispatch login
      loginBloc.add(UserLoginEvent(
        mdlLoginParam: MDLLoginParam(userName: email, password: password),
      ));

      final ok = await completer.future;

      if (ok) {
        // Deep-link success → go straight to My Courses
        Get.offAllNamed(Routes.tabBarPage, arguments: 1);
      } else {
        // Fallback → open Login with prefill + flag
        Get.toNamed(
          Routes.login,
          arguments: {
            'prefillEmail': email,
            'prefillPassword': password,
            'fromDeepLink': true, // so LoginPage routes to My Courses on success
          },
        );
      }
    } catch (e) {
      debugPrint('Auto login failed: $e');
      Get.toNamed(
        Routes.login,
        arguments: {
          'prefillEmail': email,
          'prefillPassword': password,
          'fromDeepLink': true,
        },
      );
    }
  }



  initFcm() async {
    metaSdk.setAdvertiserTracking(enabled: true);
    await FCMService.instance.init();
    FCMService.instance.handleNavigation(
      handlerFunction: (initialMessage) {
        debugPrint('initialMessage $initialMessage');
        if (user == null &&
            initialMessage['type'].toString().toLowerCase() !=
                'QTube'.toLowerCase()) {
          return;
        }
        debugPrint('initialMessage $initialMessage');
        if (initialMessage['type'] != null) {
          if (initialMessage['type'].toString().toLowerCase() ==
              'Course'.toLowerCase()) {
            Get.offAndToNamed(Routes.tabBarPage, arguments: 1);
            // Get.toNamed(Routes.tabBarPage, arguments: 1);
          } else if (initialMessage['type'].toString().toLowerCase() ==
              'QTube'.toLowerCase()) {
            Get.toNamed(Routes.questionAnswerPage);
          }
        }
      },
    );
    // }
  }

  @override
  void dispose() {
    _sub?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override

  /// Builds the app widget.
  ///
  /// This function initializes the app with the necessary bloc providers and
  /// sets up the screen util settings. It also initializes the FCM service and
  /// sets up the overlay support.
  ///
  /// Returns:
  /// - The app widget.
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      // Set the design size for the app.
      designSize: const Size(430, 932),
      // Enable text adaptation for different screen sizes.
      minTextAdapt: true,
      // Enable split screen mode for different screen sizes.
      splitScreenMode: true,
      // Build the app widget with the necessary settings.
      builder: (_, child) {
        return OverlaySupport(
          // Set up the overlay support for the app.
          child: MultiBlocProvider(
            // Set up the bloc providers for the app.
            providers: [
              BlocProvider(
                create: (_) => LoginBloc(),
              ),
              BlocProvider(
                // Create a bloc provider for the player bloc.
                create: (_) {
                  return PlayerBloc(player: AudioPlayer());
                  // globalPlayerBloc = PlayerBloc(player: AudioPlayer());
                  // return globalPlayerBloc;
                },
              ),
              BlocProvider(
                // Create a bloc provider for the course detail bloc.
                create: (_) => CourseDetailBloc(),
              ),
              BlocProvider(
                // Create a bloc provider for the my course bloc.
                create: (_) => MyCourseBloc(),
              ),
              BlocProvider(
                // Create a bloc provider for the video bloc.
                create: (_) => VideoBloc(),
              ),
              BlocProvider(
                // Create a bloc provider for the InAppPurchaseBloc bloc.
                create: (_) => InAppPurchaseBloc(),
              ),
              BlocProvider(
                // Create a bloc provider for the firebase bloc.
                create: (_) => FirebaseBloc(
                  // Initialize the firebase messaging service.
                  firebaseMessagingService: FCMService.instance,
                ),
              ),
            ],
            // Build the app widget with the necessary bloc providers.
            child: GetMaterialApp(
              //navigatorKey: navigatorKey,
              home: widget.forceUpdate ? const ForceUpdateScreen() : SplashScreen(),

              // Set the app's text direction to left-to-right.
              textDirection: TextDirection.ltr,
              // Set the app's translations keys.
              translationsKeys: AppTranslation.translationsKeys,
              // Disable the debug show checked mode banner.
              debugShowCheckedModeBanner: false,
              // Disable app logging.
              enableLog: false,
              // Set the navigator key for the app.
              navigatorKey: Get.key,
              // Set the initial route for the app.
              //initialRoute: _initMainScreen(),
              // Set the navigator observers for the app.
              navigatorObservers: [RouteChangeObserver()],
              // Set the app's routes.
              getPages: AppPages.routes,
              // Set the app's locale.
              locale: Get.deviceLocale,
              // Set the fallback locale for the app.
              fallbackLocale: const Locale("en"),
              // Build the app widget with the necessary media query settings.
              builder: (context, child) {
                return MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(textScaler: const TextScaler.linear(1.0)),
                  child: child ?? Container(),
                );
              },
            ),
          ),
        );
      },
    );
  }

  /// Initializes the main screen based on the user's login status.
  ///
  /// This function checks if the user is logged in or if a guest login is present.
  /// If the user is logged in or a guest login exists, it returns the route to the
  /// [Routes.tabBarPage]. Otherwise, it returns the route to the [Routes.login].
  ///
  /// Returns:
  /// - The route to the [Routes.tabBarPage] if the user is logged in or a guest
  /// login exists.
  /// - The route to the [Routes.login] otherwise.
  String _initMainScreen() {
    /// Check if the user is logged in or if a guest login is present.
    final isLoggedInOrGuest = StorageManager.instance.getBool(
              LocalStorageKeys.prefUserLogin,
            ) ==
            true ||
        StorageManager.instance.getBool(
              LocalStorageKeys.prefGuestLogin,
            ) ==
            true;

    /// Return the route to the tab bar page if the user is logged in or a guest
    /// login exists. Otherwise, return the route to the login page.
    return isLoggedInOrGuest ? Routes.tabBarPage : Routes.login;
  }

  /// Shows a dialog indicating that there is no internet connection.
  ///
  /// This function checks if the [result] is `ConnectivityResult.none` and if
  /// a dialog is already visible. If both conditions are met, a new dialog is
  /// shown using the [Get] package. The dialog is dismissible by tapping on the
  /// background. The dialog is not dismissible by tapping on the dialog itself.
  ///
  /// If a dialog is already visible, this function dismisses the dialog and
  /// sets [_hasVisibleNoInternet] to `false`.
  ///
  /// Parameters:
  /// - [result]: The current connectivity result.
  void _showNoInternetAlert(ConnectivityResult? result) {
    // Check if the result is 'none' and if a dialog is visible
    if (result == ConnectivityResult.none && !_hasVisibleNoInternet) {
      _hasVisibleNoInternet = true;

      // Show a new dialog using the Get package
      Get.generalDialog(
        barrierDismissible:
            false, // Prevent dismissing by tapping on the background
        barrierLabel: 'barrierLabel', // Accessibility label for the dialog
        barrierColor:
            Colors.black45, // Color of the background outside the dialog
        transitionDuration:
            const Duration(milliseconds: 0), // Duration of the transition
        pageBuilder: (BuildContext buildContext, Animation animation,
            Animation secondaryAnimation) {
          // Build the dialog content
          return _buildNoInternetDialog(buildContext);
        },
      );
    } else if (_hasVisibleNoInternet) {
      // Dismiss the visible dialog and set the flag to false
      Get.back();
      _hasVisibleNoInternet = false;
    }
  }

  /// Builds a dialog widget indicating that there is no internet connection.
  ///
  /// This widget is displayed when the user is not connected to the internet.
  /// It aligns the dialog to the top center of the screen and sets the width
  /// to infinity. The height is calculated based on the top padding of the
  /// screen and a constant body height. The dialog is padded from the top
  /// with a constant value. The alignment of the child widget is set to top
  /// center. The color of the dialog is set to the error color scheme of the
  /// current theme. The child of the dialog is a text widget displaying the
  /// message 'No Internet Connected'. The text alignment is set to end and
  /// the text style is copied from the body large text style of the primary
  /// text theme of the current theme.
  ///
  /// Parameters:
  /// - [context]: The build context used to access the theme and media query.
  ///
  /// Returns:
  /// A widget displaying a dialog indicating that there is no internet
  /// connection.
  Widget _buildNoInternetDialog(BuildContext context) {
    // Get the current theme and top padding from the media query
    final theme = Theme.of(context);
    final paddingTop = MediaQuery.of(context).padding.top;
    const bodyHeight = 30.0;

    // Build the dialog widget
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        width: double.infinity,
        height: paddingTop + bodyHeight,
        padding: const EdgeInsets.only(top: 30),
        alignment: Alignment.topCenter,
        color: theme.colorScheme.error,
        child: Text(
          'No Internet Connected',
          textAlign: TextAlign.end,
          style: theme.primaryTextTheme.bodyLarge!.copyWith(
              // fontFamily: FontFamily.INTER_MEDIUM,
              ),
        ),
      ),
    );
  }

  /// Configures the internet connectivity by checking the initial status and
  /// listening for any changes in the connectivity status.
  ///
  /// This function initializes a [Connectivity] instance and checks the initial
  /// connectivity status. If the initial status is [ConnectivityResult.none],
  /// an alert is shown indicating no internet connection.
  ///
  /// It also listens for any changes in the connectivity status and shows an alert
  /// if the status becomes [ConnectivityResult.none].
  ///
  /// If any error occurs during the initial check or listening, the error is
  /// logged.
  void _configureInternetConnectivity() {
    final connectivityService = Connectivity();

    // Initial connectivity check
    connectivityService.checkConnectivity().then((ConnectivityResult result) {
      debugPrint('Initial connectivity status: $result');
      if (result == ConnectivityResult.none) {
        _showNoInternetAlert(result);
      }
    }).onError((error, stackTrace) {
      debugPrint('Error during initial connectivity check: $error $stackTrace');
    });

    // Listen to connectivity changes
    connectivityService.onConnectivityChanged.listen((ConnectivityResult result) {
      debugPrint('Connectivity status changed: $result');
      _showNoInternetAlert(result);
    }, onError: (error) {
      debugPrint('Error listening to connectivity changes: $error');
    });
  }

}

class RouteChangeObserver extends GetObserver {
  static final metaSdk = FlutterMetaSdk();

  @override
  void didPush(Route route, Route? previousRoute) {
    debugPrint('Route changed to: ${route.settings.name}');
    metaSdk.logEvent(name: route.settings.name ?? '');
    super.didPush(route, previousRoute);
  }
}
