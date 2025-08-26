import 'dart:developer' show log;
import 'package:flutter/material.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    show
        AndroidNotificationChannel,
        Importance,
        FlutterLocalNotificationsPlugin,
        AndroidFlutterLocalNotificationsPlugin,
        InitializationSettings,
        AndroidInitializationSettings,
        NotificationDetails,
        AndroidNotificationDetails;
import 'dart:convert' show jsonDecode;

/// Class responsible for handling local notifications.
///
/// This class provides methods for initializing the local notifications
/// plugin and handling notification events.
class LocalMessageService {
  /// Singleton instance of the [LocalMessageService] class.
  ///
  /// Use this instance to access the methods of this class.
  static final instance = LocalMessageService._();

  /// Private constructor for the singleton pattern.
  LocalMessageService._();

  /// Icon used for the notifications.
  final String icon = 'noti_icon';

  /// Android notification channel for the notifications.
  final AndroidNotificationChannel _channel = const AndroidNotificationChannel(
    'noti_com.azanguru.learners"', // id
    'AzanGuru', // title
    description: 'FCM notifications', // description
    importance: Importance.max,
  );

  /// Flutter local notifications plugin instance.
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Initializes the local notifications plugin.
  ///
  /// This method initializes the [flutterLocalNotificationsPlugin] with the
  /// specified Android notification channel.
  ///
  /// It is an asynchronous operation and does not return a value.
  Future<void> init() async {
    // Resolve the platform-specific implementation of the plugin for Android.
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    // If the platform-specific implementation is available, create the
    // notification channel.
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(_channel);
    }
  }

  /// Sets a handler function for the local notifications.
  ///
  /// This function initializes the [flutterLocalNotificationsPlugin] with the
  /// specified Android initialization settings. It also sets a callback to handle
  /// the notification response.
  ///
  /// The callback function decodes the payload of the notification and calls the
  /// [handlerFunction] with the decoded message. If the payload cannot be decoded
  /// as a JSON object, an error message is printed to the debug console.
  ///
  /// The [handlerFunction] receives a map of the notification message as its
  /// parameter.
  ///
  /// The method does not return a value.
  void setHandler({
    required void Function(Map<String, dynamic> initialMessage) handlerFunction,
  }) {
    flutterLocalNotificationsPlugin.initialize(
      InitializationSettings(
        android: AndroidInitializationSettings(icon),
      ),
      onDidReceiveNotificationResponse: (details) {
        try {
          var data = jsonDecode(details.payload ?? '');
          if (data is Map<String, dynamic>) {
            handlerFunction(data);
          }
        } catch (e) {
          debugPrint('local notification open error $e');
        }

        debugPrint('local notification details ${details.payload}');
      },
    );
  }

  /// Sends a local notification with the specified parameters.
  ///
  /// [id] is a unique identifier for the notification.
  /// [title] is the title of the notification.
  /// [body] is the body text of the notification.
  /// [payload] is an optional payload for the notification.
  ///
  /// This function uses the [flutterLocalNotificationsPlugin] to show a local
  /// notification with the specified parameters.
  ///
  /// The notification is configured with the specified [id], [title], [body], and
  /// [payload]. The Android notification details are configured with the channel
  /// ID, channel name, channel description, and icon.
  ///
  /// The method does not return a value.
  void send(int id, {String? title, String? body, String? payload}) {
    // Show a local notification using the flutterLocalNotificationsPlugin
    flutterLocalNotificationsPlugin.show(
      id, // notification ID
      title, // notification title
      body, // notification body
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id, // channel ID
          _channel.name, // channel name
          channelDescription: _channel.description, // channel description
          icon: icon, // icon resource name
        ),
      ),
      payload: payload,
    ); // notification payload
  }
}
