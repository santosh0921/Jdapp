import 'dart:async';
import 'package:jd_style_logistics/core/storage/secure_storage_service.dart';

/// Manages token lifecycle and broadcasts session expiry.
class TokenManager {
  TokenManager._();
  static final TokenManager _instance = TokenManager._();
  static TokenManager get instance => _instance;

  // Broadcast stream — AuthProvider listens to this to trigger logout.
  static final _expiredCtrl = StreamController<String>.broadcast();
  static Stream<String> get sessionExpiredStream => _expiredCtrl.stream;

  void signalSessionExpired([String reason = 'Session expired. Please login again.']) {
    if (!_expiredCtrl.isClosed) {
      _expiredCtrl.add(reason);
    }
  }

  // ── Token persistence helpers ─────────────────────────────────────────────

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required int expiresInSeconds,
  }) async {
    final expiryMs =
        DateTime.now().millisecondsSinceEpoch + expiresInSeconds * 1000;
    final s = SecureStorageService.instance;
    await s.saveAccessToken(accessToken);
    await s.saveRefreshToken(refreshToken);
    await s.saveTokenExpiry(expiryMs.toString());
  }

  Future<String?> getAccessToken() =>
      SecureStorageService.instance.getAccessToken();

  Future<String?> getRefreshToken() =>
      SecureStorageService.instance.getRefreshToken();

  /// Returns true if the stored token is expired or will expire in < 30 s.
  Future<bool> isTokenExpired() async {
    final raw = await SecureStorageService.instance.getTokenExpiry();
    if (raw == null) return false; // no expiry stored → assume valid
    final ms = int.tryParse(raw) ?? 0;
    if (ms == 0) return false;
    return DateTime.now().millisecondsSinceEpoch >= ms - 30000;
  }

  Future<bool> isLoggedIn() async {
    final token = await SecureStorageService.instance.getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Clears auth tokens but preserves role & service selection so the login
  /// screen can pre-fill them on next open.
  Future<void> clearSession() async {
    final s = SecureStorageService.instance;
    final role    = await s.getUserRole();
    final service = await s.getSelectedService();

    await s.clearAll();

    if (role != null && role.isNotEmpty) await s.saveUserRole(role);
    if (service != null && service.isNotEmpty) await s.saveSelectedService(service);
  }
}
