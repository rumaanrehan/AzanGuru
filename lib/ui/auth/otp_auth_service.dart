import '../../graphQL/graphql_service.dart';
import '../../service/digits_service.dart';

class OtpAuthService {
  final DigitsService _digitsService;
  final GraphQLService _graphQLService;

  OtpAuthService(this._digitsService, this._graphQLService);

  /// 🔹 ONE-CLICK LOGIN / SIGNUP
  Future<(String jwt, String userId)> oneClickLoginOrRegister({
    required String mobile,
    required String otp,
  }) async {
    // 1. Digits One-Click Login/Register
    final digitsResult = await _digitsService.oneClickLoginOrRegister(
      countryCode: '+91',
      mobile: mobile,
      otp: otp,
    );

    // 2. Exchange Token with Backend
    final mutation = await _graphQLService.performMutation(
      r'''
      mutation LoginWithDigits($input: LoginWithDigitsInput!) {
        loginWithDigits(input: $input) {
          token
          userId
        }
      }
      ''',
      variables: {
        'input': {
          'digitsToken': digitsResult.accessToken,
        }
      },
    );

    if (mutation.hasException) {
      final error = mutation.exception!.graphqlErrors.first.message;
      throw Exception('GraphQL Error: $error');
    }

    final data = mutation.data?['loginWithDigits'];
    if (data == null || data['token'] == null) {
      throw Exception('Login failed: Invalid token or user data received.');
    }

    return (data['token'] as String, data['userId'].toString());
  }

  /// 🔹 SEND OTP (Still needed for the first step)
  Future<void> sendOtp(String mobile) async {
    // Always use type: 'register' as it works for both new and existing users in your setup
    await _digitsService.sendOtp(
      countryCode: '+91',
      mobile: mobile,
      type: 'register',
    );
  }
}
