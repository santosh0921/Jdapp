import 'package:jd_style_logistics/core/auth/token_manager.dart';
import 'package:jd_style_logistics/core/network/api_client.dart';
import 'package:jd_style_logistics/core/network/api_endpoints.dart';
import 'package:jd_style_logistics/core/storage/secure_storage_service.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  // ── OTP flow ──────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> sendOtp(String phone) async {
    final r = await ApiClient.instance.post(
      ApiEndpoints.sendOtp,
      data: {'phone': phone},
    );
    return r.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> verifyOtp(String phone, String otp) async {
    final r = await ApiClient.instance.post(
      ApiEndpoints.verifyOtp,
      data: {'phone': phone, 'otp': otp},
    );
    final body = r.data as Map<String, dynamic>;
    final data = body['data'] as Map<String, dynamic>? ?? {};
    await _persistTokens(data);
    return body;
  }

  // ── Admin login (uses same OTP endpoints as customer) ────────────────────

  Future<Map<String, dynamic>> sendAdminOtp(String phone) async {
    final r = await ApiClient.instance.post(
      ApiEndpoints.sendOtp,
      data: {'phone': phone},
    );
    return r.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> verifyAdminOtp(String phone, String otp) async {
    final r = await ApiClient.instance.post(
      ApiEndpoints.verifyOtp,
      data: {'phone': phone, 'otp': otp},
    );
    final body = r.data as Map<String, dynamic>;
    final data = body['data'] as Map<String, dynamic>? ?? {};
    await _persistTokens(data);
    return body;
  }

  // ── Profile ───────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> setupProfile(String name, String? email) async {
    final r = await ApiClient.instance.post(
      ApiEndpoints.setupProfile,
      data: {'name': name, if (email != null && email.isNotEmpty) 'email': email},
    );
    return r.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getProfile() async {
    final r = await ApiClient.instance.get(ApiEndpoints.authProfile);
    return r.data as Map<String, dynamic>;
  }

  // ── Role selection ────────────────────────────────────────────────────────
  // Role is stored locally; the backend endpoint is called best-effort.

  Future<Map<String, dynamic>> selectRole(String role) async {
    try {
      final r = await ApiClient.instance.post(
        ApiEndpoints.selectService,
        data: {'role': role},
      );
      return r.data as Map<String, dynamic>;
    } catch (_) {
      return {'success': true, 'data': {'role': role}};
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    try {
      await ApiClient.instance.post(ApiEndpoints.logout);
    } catch (_) {
      // Best-effort — clear local session regardless
    }
    await TokenManager.instance.clearSession();
  }

  // ── Token refresh ─────────────────────────────────────────────────────────

  Future<bool> refreshToken() async {
    return TokenManager.instance.isTokenExpired().then((expired) async {
      if (!expired) return true;
      final storedRefresh = await SecureStorageService.instance.getRefreshToken();
      if (storedRefresh == null || storedRefresh.isEmpty) return false;
      try {
        final r = await ApiClient.instance.post(
          ApiEndpoints.refreshToken,
          data: {'refresh_token': storedRefresh},
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
    // Backend returns 'token'; standard OAuth returns 'access_token'.
    final access  = (data['access_token'] as String?) ?? (data['token'] as String?);
    final refresh = (data['refresh_token'] as String?) ?? '';
    final expires = (data['expires_in'] as num?)?.toInt() ?? 86400;
    if (access != null && access.isNotEmpty) {
      await TokenManager.instance.saveTokens(
        accessToken: access,
        refreshToken: refresh,
        expiresInSeconds: expires,
      );
    }
  }
}
