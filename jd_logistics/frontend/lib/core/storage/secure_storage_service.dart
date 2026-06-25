import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  SecureStorageService._();
  static final SecureStorageService _instance = SecureStorageService._();
  static SecureStorageService get instance => _instance;

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // ── Key names ─────────────────────────────────────────────────────────────
  static const _kAccessToken       = 'access_token';
  static const _kRefreshToken      = 'refresh_token';
  static const _kTokenExpiry       = 'token_expiry';
  static const _kUserId            = 'user_id';
  static const _kUserRole          = 'user_role';
  static const _kPhone             = 'user_phone';
  static const _kSelectedService   = 'selected_service';
  static const _kProfileCompleted  = 'profile_completed';

  // ── Access token ──────────────────────────────────────────────────────────
  Future<void> saveAccessToken(String token) =>
      _storage.write(key: _kAccessToken, value: token);
  Future<String?> getAccessToken() =>
      _storage.read(key: _kAccessToken);

  // ── Refresh token ─────────────────────────────────────────────────────────
  Future<void> saveRefreshToken(String token) =>
      _storage.write(key: _kRefreshToken, value: token);
  Future<String?> getRefreshToken() =>
      _storage.read(key: _kRefreshToken);

  // ── Token expiry (unix ms as string) ──────────────────────────────────────
  Future<void> saveTokenExpiry(String expiryMs) =>
      _storage.write(key: _kTokenExpiry, value: expiryMs);
  Future<String?> getTokenExpiry() =>
      _storage.read(key: _kTokenExpiry);

  // ── User identity ─────────────────────────────────────────────────────────
  Future<void> saveUserId(String id) =>
      _storage.write(key: _kUserId, value: id);
  Future<String?> getUserId() =>
      _storage.read(key: _kUserId);

  Future<void> saveUserRole(String role) =>
      _storage.write(key: _kUserRole, value: role);
  Future<String?> getUserRole() =>
      _storage.read(key: _kUserRole);

  Future<void> savePhone(String phone) =>
      _storage.write(key: _kPhone, value: phone);
  Future<String?> getPhone() =>
      _storage.read(key: _kPhone);

  // ── Selected service (courier | logistics | admin) ─────────────────────────
  Future<void> saveSelectedService(String service) =>
      _storage.write(key: _kSelectedService, value: service);
  Future<String?> getSelectedService() =>
      _storage.read(key: _kSelectedService);

  // ── Profile completion flag ───────────────────────────────────────────────
  Future<void> saveProfileCompleted(bool completed) =>
      _storage.write(key: _kProfileCompleted, value: completed.toString());
  Future<bool> isProfileCompleted() async {
    final v = await _storage.read(key: _kProfileCompleted);
    return v == 'true';
  }

  // ── Batch save on login ────────────────────────────────────────────────────
  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required int expiryMs,
    required String userId,
    required String role,
    String? phone,
    String? service,
  }) async {
    await Future.wait([
      _storage.write(key: _kAccessToken, value: accessToken),
      _storage.write(key: _kRefreshToken, value: refreshToken),
      _storage.write(key: _kTokenExpiry, value: expiryMs.toString()),
      _storage.write(key: _kUserId, value: userId),
      _storage.write(key: _kUserRole, value: role),
      if (phone != null) _storage.write(key: _kPhone, value: phone),
      if (service != null) _storage.write(key: _kSelectedService, value: service),
    ]);
  }

  // ── Clear auth tokens only (preserve role/service for next login) ──────────
  Future<void> clearAuthTokens() async {
    await Future.wait([
      _storage.delete(key: _kAccessToken),
      _storage.delete(key: _kRefreshToken),
      _storage.delete(key: _kTokenExpiry),
      _storage.delete(key: _kUserId),
      _storage.delete(key: _kPhone),
    ]);
  }

  // ── Full wipe ─────────────────────────────────────────────────────────────
  Future<void> clearAll() => _storage.deleteAll();
}
