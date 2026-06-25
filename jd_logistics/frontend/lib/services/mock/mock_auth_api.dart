import 'package:jd_style_logistics/core/constants/mock_config.dart';

/// Thin wrapper that mirrors AuthService mock logic for direct use in screens.
class MockAuthApi {
  MockAuthApi._();
  static final MockAuthApi instance = MockAuthApi._();

  Future<Map<String, dynamic>> sendOtp(String phone) async {
    await _delay();
    return {'success': true, 'message': 'OTP sent (mock: ${MockConfig.mockOtp})'};
  }

  Future<Map<String, dynamic>> verifyOtp(String phone, String otp) async {
    await _delay(ms: 800);
    if (otp != MockConfig.mockOtp) {
      throw Exception('Invalid OTP. Use ${MockConfig.mockOtp}');
    }
    return {
      'success': true,
      'data': {
        'token': MockConfig.mockToken,
        'user': MockConfig.mockUser(phone: phone),
      },
    };
  }

  Future<Map<String, dynamic>> refreshToken(String token) async {
    await _delay(ms: 300);
    return {
      'success': true,
      'data': {'token': MockConfig.mockToken, 'expires_in': 86400},
    };
  }

  Future<Map<String, dynamic>> getProfile(String token) async {
    await _delay(ms: 400);
    return {
      'success': true,
      'data': MockConfig.mockUser(),
    };
  }

  Future<Map<String, dynamic>> updateProfile({
    required String name,
    String? email,
    String? avatarUrl,
  }) async {
    await _delay(ms: 500);
    return {
      'success': true,
      'data': MockConfig.mockUser(name: name),
    };
  }

  Future<Map<String, dynamic>> changePhone(String newPhone, String otp) async {
    await _delay(ms: 700);
    if (otp != MockConfig.mockOtp) {
      throw Exception('Invalid OTP. Use ${MockConfig.mockOtp}');
    }
    return {
      'success': true,
      'data': {'phone': newPhone, 'message': 'Phone updated (mock)'},
    };
  }

  Future<Map<String, dynamic>> logout(String token) async {
    await _delay(ms: 300);
    return {'success': true, 'message': 'Logged out (mock)'};
  }

  static Future<void> _delay({int ms = 600}) =>
      Future.delayed(Duration(milliseconds: MockConfig.enabled ? ms : 0));
}
