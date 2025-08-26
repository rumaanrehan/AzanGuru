// import 'package:azan_guru_mobile/graphQL/graphql_service.dart';
// import 'package:azan_guru_mobile/service/local_storage/local_storage.dart';
// import 'package:azan_guru_mobile/service/local_storage/local_storage_keys.dart';
// import 'package:azan_guru_mobile/ui/model/user_data.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class StorageManager extends LocalStorage {
//   static StorageManager instance = StorageManager();
//
//   static late final SharedPreferences _prefs;
//   static Future<SharedPreferences> init(SharedPreferences sp) async {
//     _prefs = sp;
//     return _prefs;
//   }
//
//   static StorageManager getInstance() {
//     return instance;
//   }
//
//   Future<bool> setUserSession(String userData) async {
//     return await _prefs.setString(LocalStorageKeys.prefUserData, userData);
//   }
//
//   UserData? getLoginUser() {
//     String? data = _prefs.getString(LocalStorageKeys.prefUserData);
//     if (data == null || data.isEmpty || data == "null") {
//       return null;
//     } else {
//       UserData userData = userDataFromJson(data);
//       return userData;
//     }
//   }
//
//   @override
//   Future<bool> clear() async {
//     final graphQLService = GraphQLService();
//     graphQLService.clearCache();
//     // _client.cache.store.reset();
//     return await _prefs.clear();
//   }
//
//   Future<bool> setFCMToken(String token) async {
//     return await _prefs.setString(LocalStorageKeys.prefFcmToken, token);
//   }
//
//   String? getFCMToken() {
//     String? data = _prefs.getString(LocalStorageKeys.prefFcmToken);
//     return data;
//   }
//
//   @override
//   bool getBool(String key, {bool defaultValue = false}) {
//     return _prefs.getBool(key) ?? defaultValue;
//   }
//
//   @override
//   double getDouble(String key, {double defaultValue = 0}) {
//     return _prefs.getDouble(key) ?? defaultValue;
//   }
//
//   @override
//   int getInt(String key, {int defaultValue = 0}) {
//     return _prefs.getInt(key) ?? defaultValue;
//   }
//
//   @override
//   String getString(String key, {String? defaultValue}) {
//     return _prefs.getString(key) ?? defaultValue ?? '';
//   }
//
//   @override
//   Future<bool> remove(String key) async {
//     return await _prefs.remove(key);
//   }
//
//   @override
//   Future<bool> setBool(String key, bool value) async {
//     return await _prefs.setBool(key, value);
//   }
//
//   @override
//   Future<bool> setDouble(String key, double value) async {
//     return await _prefs.setDouble(key, value);
//   }
//
//   @override
//   Future<bool> setInt(String key, int value) async {
//     return await _prefs.setInt(key, value);
//   }
//
//   @override
//   Future<bool> setString(String key, String value) async {
//     return await _prefs.setString(key, value);
//   }
// }


import 'package:azan_guru_mobile/graphQL/graphql_service.dart';
import 'package:azan_guru_mobile/service/local_storage/local_storage.dart';
import 'package:azan_guru_mobile/service/local_storage/local_storage_keys.dart';
import 'package:azan_guru_mobile/ui/model/user_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageManager extends LocalStorage {
  static StorageManager instance = StorageManager();

  static late final SharedPreferences _prefs;
  static Future<SharedPreferences> init(SharedPreferences sp) async {
    _prefs = sp;
    return _prefs;
  }

  static StorageManager getInstance() {
    return instance;
  }

  /// User Session Handling
  Future<bool> setUserSession(String userData) async {
    return await _prefs.setString(LocalStorageKeys.prefUserData, userData);
  }

  UserData? getLoginUser() {
    String? data = _prefs.getString(LocalStorageKeys.prefUserData);
    if (data == null || data.isEmpty || data == "null") {
      return null;
    } else {
      UserData userData = userDataFromJson(data);
      return userData;
    }
  }

  /// General Setters
  Future<bool> setBool(String key, bool value) async {
    return await _prefs.setBool(key, value);
  }

  Future<bool> setInt(String key, int value) async {
    return await _prefs.setInt(key, value);
  }

  Future<bool> setDouble(String key, double value) async {
    return await _prefs.setDouble(key, value);
  }

  Future<bool> setString(String key, String value) async {
    return await _prefs.setString(key, value);
  }

  /// Dynamic setter (for skip login etc.)
  Future<void> setValue(String key, dynamic value) async {
    if (value is bool) {
      await _prefs.setBool(key, value);
    } else if (value is int) {
      await _prefs.setInt(key, value);
    } else if (value is double) {
      await _prefs.setDouble(key, value);
    } else if (value is String) {
      await _prefs.setString(key, value);
    } else if (value is List<String>) {
      await _prefs.setStringList(key, value);
    }
  }

  /// General Getters
  bool getBool(String key, {bool defaultValue = false}) {
    return _prefs.getBool(key) ?? defaultValue;
  }

  int getInt(String key, {int defaultValue = 0}) {
    return _prefs.getInt(key) ?? defaultValue;
  }

  double getDouble(String key, {double defaultValue = 0}) {
    return _prefs.getDouble(key) ?? defaultValue;
  }

  String getString(String key, {String? defaultValue}) {
    return _prefs.getString(key) ?? defaultValue ?? '';
  }

  /// Dynamic getter
  dynamic getValue(String key) {
    return _prefs.get(key);
  }

  /// Remove one key
  Future<bool> remove(String key) async {
    return await _prefs.remove(key);
  }

  /// Clear all values
  @override
  Future<bool> clear() async {
    final graphQLService = GraphQLService();
    graphQLService.clearCache();
    return await _prefs.clear();
  }

  /// FCM
  Future<bool> setFCMToken(String token) async {
    return await _prefs.setString(LocalStorageKeys.prefFcmToken, token);
  }

  String? getFCMToken() {
    return _prefs.getString(LocalStorageKeys.prefFcmToken);
  }

  /// Login status management
  Future<void> setLoginStatus(bool isLoggedIn) async {
    await _prefs.setBool(LocalStorageKeys.isLoggedIn, isLoggedIn);
  }

  bool getLoginStatus() {
    return _prefs.getBool(LocalStorageKeys.isLoggedIn) ?? false;
  }

  /// Subscription status management
  Future<void> setSubscriptionStatus(bool isSubscribed) async {
    await _prefs.setBool(LocalStorageKeys.isUserHasSubscription, isSubscribed);
  }

  bool getSubscriptionStatus() {
    return _prefs.getBool(LocalStorageKeys.isUserHasSubscription) ?? false;
  }

}
