import 'dart:async';
import 'dart:developer' show log;
import 'package:azan_guru_mobile/firebase_options.dart';
import 'package:azan_guru_mobile/service/local_storage/storage_manager.dart';
import 'package:azan_guru_mobile/ui/app.dart';
import 'package:azan_guru_mobile/ui/model/free_quran_data.dart';
import 'package:azan_guru_mobile/ui/model/live_classes_data.dart';
import 'package:azan_guru_mobile/ui/model/media_node.dart';
import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show SystemChrome, SystemUiOverlayStyle, DeviceOrientation;
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:pod_player/pod_player.dart' show PodVideoPlayer;
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:azan_guru_mobile/common/util.dart';
import 'package:azan_guru_mobile/entities/app_version.dart'; // (You’ll create this file)

import 'package:google_mobile_ads/google_mobile_ads.dart';

//import 'package:azan_guru_mobile/service/deep_link_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();


/// Runs the main application.
Future<void> main() async {
  return runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Wait for initializing shared preferences
    await Future.wait([_initSharedPreferences()]);

    // Initialize Hive
    await initHiveForFlutter();
    await Hive.initFlutter();
    initializeHiveAdapter();

    //Initialize Google AdMob
    await MobileAds.instance.initialize();

    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.black,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.light,
    ));

    // Set preferred orientation to portrait up
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    // Enable PodVideoPlayer logs
    PodVideoPlayer.enableLogs = true;

    /// 🔄 Check for update
    final client = GraphQLClient(
      link: HttpLink('https://azanguru.com/graphql'),
      cache: GraphQLCache(),
    );
    final needsUpdate = await isUpdateRequired(client);

    /// 🔁 Run the app with update condition
    runApp(App(
      forceUpdate: needsUpdate,
    ));
  }, (Object error, StackTrace stack) {
    debugPrint(error.toString());
  });
}

/// Initializes shared preferences and firebase.
///
/// This function initializes shared preferences by getting an instance of
/// SharedPreferences and passing it to StorageManager. It also initializes
/// firebase by calling Firebase.initializeApp with the current platform's
/// options.
///
/// Returns a [Future] that completes when the initialization is done.
Future<void> _initSharedPreferences() async {
  // Get an instance of SharedPreferences.
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // Initialize StorageManager with the obtained SharedPreferences.
  StorageManager.init(prefs);

  // Initialize firebase with the current platform's options.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

void initializeHiveAdapter() {
  //adapters for model listen quran for free
  Hive.registerAdapter(FreeQuranDataAdapter());
  Hive.registerAdapter(FreeQuranNodeAdapter());
  Hive.registerAdapter(ListenQuranAdapter());
  Hive.registerAdapter(QuranAudioAdapter());
  Hive.registerAdapter(
      MediaNodeAdapter()); // Ensure MediaNodeAdapter is also registered

//adapters for live class
  Hive.registerAdapter(LiveClassesDataAdapter());
  Hive.registerAdapter(GeneralOptionsFieldsAdapter());
  Hive.registerAdapter(LiveClassInfoSectionAdapter());
  Hive.registerAdapter(AddMoreRangeAdapter());
  Hive.registerAdapter(LiveClassesLinkAdapter());
}
