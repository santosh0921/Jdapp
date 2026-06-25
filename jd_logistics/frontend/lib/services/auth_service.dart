import 'package:jd_style_logistics/core/auth/token_manager.dart';
import 'package:jd_style_logistics/core/constants/mock_config.dart';
import 'package:jd_style_logistics/core/network/api_client.dart';
import 'package:jd_style_logistics/core/network/api_endpoints.dart';
import 'package:jd_style_logistics/core/storage/secure_storage_service.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  // ── OTP flow ──────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> sendOtp(String phone) async {
    if (MockConfig.enabled) {
      await Future.delayed(const Duration(milliseconds: 600));
      return {'success': true, 'message': 'OTP sent (mock)'};
    }
    final r = await ApiClient.instance.post(
      ApiEndpoints.sendOtp,
      data: {'phone': phone},
    );
    return r.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> verifyOtp(String phone, String otp) async {
    if (MockConfig.enabled) {
      await Future.delayed(const Duration(milliseconds: 800));
      if (otp != MockConfig.mockOtp) {
        throw Exception('Invalid OTP. Hint: ${MockConfig.mockOtp}');
      }
      final now = DateTime.now().millisecondsSinceEpoch;
      return {
        'success': true,
        'data': {
          'access_token': MockConfig.mockToken,
          'refresh_token': '${MockConfig.mockToken}_refresh',
          'expires_in': 3600,
          'token_expiry': now + 3600 * 1000,
          'token': MockConfig.mockToken,
          'user': MockConfig.mockUser(phone: phone),
        },
      };
    }
    final r = await ApiClient.instance.post(
      ApiEndpoints.verifyOtp,
      data: {'phone': phone, 'otp': otp},
    );
    final body = r.data as Map<String, dynamic>;
    // Persist tokens right after verification
    final data = body['data'] as Map<String, dynamic>? ?? {};
    await _persistTokens(data);
    return body;
  }

  // ── Admin login ──────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> sendAdminOtp(String phone) async {
    if (MockConfig.enabled) {
      await Future.delayed(const Duration(milliseconds: 600));
      return {'success': true, 'message': 'Admin OTP sent (mock)'};
    }
    final r = await ApiClient.instance.post(
      ApiEndpoints.adminLogin,
      data: {'phone': phone},
    );
    return r.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> verifyAdminOtp(String phone, String otp) async {
    if (MockConfig.enabled) {
      await Future.delayed(const Duration(milliseconds: 800));
      if (otp != MockConfig.mockOtp) {
        throw Exception('Invalid OTP. Hint: ${MockConfig.mockOtp}');
      }
      final now = DateTime.now().millisecondsSinceEpoch;
      return {
        'success': true,
        'data': {
          'access_token': MockConfig.mockToken,
          'refresh_token': '${MockConfig.mockToken}_refresh',
          'expires_in': 3600,
          'token_expiry': now + 3600 * 1000,
          'token': MockConfig.mockToken,
          'user': MockConfig.mockUser(phone: phone, role: 'admin'),
        },
      };
    }
    final r = await ApiClient.instance.post(
      ApiEndpoints.adminVerifyOtp,
      data: {'phone': phone, 'otp': otp},
    );
    final body = r.data as Map<String, dynamic>;
    final data = body['data'] as Map<String, dynamic>? ?? {};
    await _persistTokens(data);
    return body;
  }

  // ── Profile ───────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> setupProfile(String name, String? email) async {
    if (MockConfig.enabled) {
      await Future.delayed(const Duration(milliseconds: 500));
      return {'success': true, 'data': MockConfig.mockUser(name: name)};
    }
    final r = await ApiClient.instance.post(
      ApiEndpoints.setupProfile,
      data: {'name': name, 'email': email},
    );
    return r.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getProfile() async {
    if (MockConfig.enabled) {
      await Future.delayed(const Duration(milliseconds: 300));
      return {'success': true, 'data': MockConfig.mockUser()};
    }
    final r = await ApiClient.instance.get(ApiEndpoints.authProfile);
    return r.data as Map<String, dynamic>;
  }

  // ── Role / service selection ──────────────────────────────────────────────

  Future<Map<String, dynamic>> selectRole(String role) async {
    if (MockConfig.enabled) {
      await Future.delayed(const Duration(milliseconds: 400));
      return {
        'success': true,
        'data': {'token': MockConfig.mockToken, 'user': MockConfig.mockUser(role: role)},
      };
    }
    final r = await ApiClient.instance.post(
      ApiEndpoints.selectService,
      data: {'role': role},
    );
    return r.data as Map<String, dynamic>;
  }

  // ── Logout ────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    if (!MockConfig.enabled) {
      try {
        await ApiClient.instance.post(ApiEndpoints.logout);
      } catch (_) {
        // Best-effort — clear session regardless
      }
    }
    await TokenManager.instance.clearSession();
  }

  // ── Token refresh (called by AuthProvider on app resume) ──────────────────

  Future<bool> refreshToken() async {
    if (MockConfig.enabled) return true;
    return TokenManager.instance.isTokenExpired().then((expired) async {
      if (!expired) return true;
      final refreshToken = await SecureStorageService.instance.getRefreshToken();
      if (refreshToken == null) return false;
      try {
        final r = await ApiClient.instance.post(
          ApiEndpoints.refreshToken,
          data: {'refresh_token': refreshToken},
        );
        final data = (r.data['data'] as Map<String, dynamic>?) ?? {};
        await _persistTokens(data);
        return true;
      } catch (_) {
        return false;
      }
    });
  }

  // ── Internal helpers ──────────────────────────────────────────────────────

  Future<void> _persistTokens(Map<String, dynamic> data) async {
    final access  = data['access_token'] as String?;
    final refresh = data['refresh_token'] as String?;
    final expires = (data['expires_in'] as num?)?.toInt() ?? 3600;
    if (access != null) {
      await TokenManager.instance.saveTokens(
        accessToken: access,
        refreshToken: refresh ?? '',
        expiresInSeconds: expires,
      );
    }
  }
}
