import 'package:dio/dio.dart';

class DigitsLoginResult {
  final String accessToken;
  final int userId;

  DigitsLoginResult({
    required this.accessToken,
    required this.userId,
  });
}

class DigitsService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://azanguru.com',
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      contentType: Headers.formUrlEncodedContentType,
    ),
  );

  /// 1. SEND OTP
  Future<void> sendOtp({
    required String countryCode,
    required String mobile,
    required String type,
  }) async {
    print('🔥 DIGITS SEND OTP: $mobile ($type)');
    final response = await _dio.post(
      '/wp-json/digits/v1/send_otp',
      data: {
        'countrycode': countryCode,
        'mobileNo': mobile,
        'type': type,
      },
    );

    final data = response.data;
    print('🔥 DIGITS SEND OTP RESPONSE: $data');

    if (data == null || data['code'].toString() != '1') {
      final msg = data?['message'] ?? data?['data']?['message'] ?? data?['msg'] ?? 'Failed to send OTP';
      throw Exception(msg);
    }
  }

  /// 2. ONE-CLICK LOGIN / SIGNUP
  Future<DigitsLoginResult> oneClickLoginOrRegister({
    required String countryCode,
    required String mobile,
    required String otp,
  }) async {
    print('🔥 Attempting One-Click Login/Register for: $mobile');
    final response = await _dio.post(
      '/wp-json/digits/v1/one_click',
      data: {
        'countrycode': countryCode,
        'mobileNo': mobile,
        'otp': otp,
      },
    );

    final data = response.data;
    print('🔥 DIGITS ONE-CLICK RESPONSE: $data');

    final success = data?['success'] == true;

    if (!success) {
      final errorMsg = data?['data']?['msg'] ?? 'Login/Registration failed';
      throw Exception(errorMsg);
    }

    final responseData = data['data'] ?? {};
    final digitsToken = responseData['access_token'];
    final userIdRaw = responseData['user_id'];

    if (digitsToken == null || userIdRaw == null) {
      throw Exception('Authentication succeeded but token/user_id was not returned.');
    }

    return DigitsLoginResult(
      accessToken: digitsToken.toString(),
      userId: int.tryParse(userIdRaw.toString()) ?? 0,
    );
  }
}
