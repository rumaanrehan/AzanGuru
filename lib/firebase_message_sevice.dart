import 'dart:convert' show jsonEncode;
import 'dart:developer' show log;
import 'package:flutter/material.dart';

import 'dart:io' show Platform;

import 'package:azan_guru_mobile/firebase_options.dart';
import 'package:azan_guru_mobile/local_message_service.dart';
import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'package:firebase_messaging/firebase_messaging.dart'
    show FirebaseMessaging, RemoteMessage, NotificationSettings;

/// A private constructor for the FCMService class.
///
/// This constructor is not intended to be instantiated from outside the class.
/// It is used to ensure that only a single instance of the FCMService class
/// is created.
///
/// Returns:
///   void
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase if it is not already initialized.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Print the received message data to the debug console.
  debugPrint(
    "FCM  Handling a background message: ${message.data}",
  );
}

/// [FCMService] is a singleton class that provides methods for initializing
/// Firebase Cloud Messaging (FCM) and handling incoming messages.
///
/// This class is responsible for initializing FCM and handling incoming
/// messages. The [init] method is used to initialize FCM. The [handleNavigation]
/// method is used to handle incoming navigation messages. The [iOSPermission]
/// method is used to request permission for iOS devices. The [getFirebaseToken]
/// method is used to get the Firebase token. The [onTokenRefresh] method is used
/// to listen for token refresh events.
///
/// The [FCMService] class is a singleton class. It can be accessed using the
/// [instance] getter.
class FCMService {
  static FCMService instance = FCMService._private();
  final _localNotification = LocalMessageService.instance;

  FCMService._private();

  /// end
  final _firebaseMessaging = FirebaseMessaging.instance;

  /// Initializes the Firebase Cloud Messaging (FCM) service.
  ///
  /// This method initializes FCM, sets up the foreground and background
  /// message listeners, and requests permission for notifications.
  ///
  /// Returns:
  ///   A [Future] that completes when initialization is done.
  Future init() async {
    // Log the start of the initialization process.
    debugPrint('FCM init()');

    // Request permission for notifications.
    await _setPermission();

    // Initialize the local notification service.
    await LocalMessageService.instance.init();

    // Get the Firebase token.
    await getFirebaseToken();

    // Set up the foreground message listener.
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Log the fact that a message has been received whilst in the foreground.
      debugPrint('Got a message whilst in the foreground!');

      // Log the received message data.
      debugPrint('Message data: ${message.data}');

      // If the message contains a notification, construct a local notification.
      if (message.notification != null) {
        if (Platform.isAndroid) {
          // Construct an Android local notification.
          _localNotification.send(
            message.hashCode,
            title: message.notification!.title,
            body: message.notification!.body,
            payload: jsonEncode(message.data),
          );
        } else if (Platform.isIOS) {
          // Construct an iOS local notification.
          _localNotification.send(
            message.hashCode,
            title: message.notification!.title,
            body: message.notification!.body,
            payload: jsonEncode(message.data),
          );
        }
      }
    });

    // Set up the background message listener.
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  /// Sets the permission for Firebase Cloud Messaging (FCM) notifications.
  ///
  /// This function requests permission for FCM notifications and sets the
  /// presentation options for notifications. The [authorizationStatus] of the
  /// [NotificationSettings] is logged.
  ///
  /// Returns a [Future] that completes when the permission is set.
  Future<void> _setPermission() async {
    // Request permission for FCM notifications.
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      // Show alerts.
      alert: true,
      // Show announcements.
      announcement: false,
      // Show badges.
      badge: true,
      // Show notifications on CarPlay.
      carPlay: false,
      // Show critical alerts.
      criticalAlert: false,
      // Show notifications while the app is in the background.
      provisional: false,
      // Show notifications with sound.
      sound: true,
    );

    // Set the presentation options for notifications.
    _firebaseMessaging.setForegroundNotificationPresentationOptions(
      // Show alerts.
      alert: true,
      // Play sound.
      sound: true,
      // Show badges.
      badge: true,
    );

    // Log the authorization status.
    debugPrint('FCM  User granted permission: ${settings.authorizationStatus}');
  }

  /// Handles the navigation by calling the [handlerFunction] with the
  /// [initialMessage] data.
  ///
  /// This function gets the [initialMessage] from the FirebaseMessaging service.
  /// If the [initialMessage] is not null, it calls the [handlerFunction] with
  /// the [initialMessage] data. It also logs the [initialMessage] data.
  ///
  /// The [handlerFunction] receives a map of the initial message data as its
  /// parameter.
  ///
  /// This function sets the handler function for the local notifications.
  ///
  /// It also listens to the onMessageOpenedApp stream and calls the
  /// [handlerFunction] whenever a new message is opened.
  ///
  /// Returns a [Future] that completes when the navigation is handled.
  Future<void> handleNavigation({
    required void Function(Map<String, dynamic> initialMessage) handlerFunction,
  }) async {
    // Get the initial message from the FirebaseMessaging service.
    RemoteMessage? initialMessage =
        await _firebaseMessaging.getInitialMessage();

    // If the initial message is not null, call the handler function with the
    // initial message data and log the initial message data.
    if (initialMessage != null) {
      handlerFunction(initialMessage.data);
      debugPrint(
          'FCM getInitialMessage is handleNavigation ${initialMessage.data}');
    }

    // Set the handler function for the local notifications.
    _localNotification.setHandler(handlerFunction: handlerFunction);

    // Also handle any interaction when the app is in the background via a
    // Stream listener.
    FirebaseMessaging.onMessageOpenedApp
        .listen((event) => handlerFunction(event.data));
  }

  /// Requests iOS permissions for displaying notifications.
  ///
  /// This method asks the user for permission to show notifications
  /// with sound, badge, and alert. It's crucial to call this method
  /// at the initial launch of the app on iOS devices to ensure
  /// notifications are delivered.
  ///
  /// Example:
  /// ```dart
  /// FCMService().iOSPermission();
  ///
  Future<String?> getFirebaseToken() async {
    String? token = await _firebaseMessaging.getToken();
    debugPrint('FCM token >>>>>> $token');
    return token;
  }

  /// Listens for token refresh events from Firebase Cloud Messaging (FCM).
  ///
  /// This method sets up a listener for token refresh events. When a new token
  /// is generated or refreshed, the provided [onToken] function will be called
  /// with the new token as a parameter.
  ///
  /// Example:
  /// ```dart
  /// FCMService().onTokenRefresh((token) {
  ///   print('FCM token refreshed: $token');
  /// });
  ///
  void onTokenRefresh(Function(String) onToken) {
    _firebaseMessaging.onTokenRefresh.listen(onToken);
  }
}
