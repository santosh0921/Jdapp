import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  LocalStorageService._();

  static const _keyThemeMode = 'theme_mode';
  static const _keyOnboardingSeen = 'onboarding_seen';
  static const _keyFcmToken = 'fcm_token';
  static const _keyLanguage = 'language';
  static const _keyNotificationsEnabled = 'notifications_enabled';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static SharedPreferences get _p {
    if (_prefs == null) {
      throw Exception('LocalStorageService not initialized. Call LocalStorageService.init() before use.');
    }
    return _prefs!;
  }

  // Theme
  static Future<void> saveThemeMode(String mode) => _p.setString(_keyThemeMode, mode);
  static String getThemeMode() => _p.getString(_keyThemeMode) ?? 'light';

  // Onboarding
  static Future<void> setOnboardingSeen() => _p.setBool(_keyOnboardingSeen, true);
  static bool isOnboardingSeen() => _p.getBool(_keyOnboardingSeen) ?? false;

  // FCM
  static Future<void> saveFcmToken(String token) => _p.setString(_keyFcmToken, token);
  static String? getFcmToken() => _p.getString(_keyFcmToken);

  // Language
  static Future<void> saveLanguage(String lang) => _p.setString(_keyLanguage, lang);
  static String getLanguage() => _p.getString(_keyLanguage) ?? 'en';

  // Notifications
  static Future<void> setNotificationsEnabled(bool enabled) =>
      _p.setBool(_keyNotificationsEnabled, enabled);
  static bool areNotificationsEnabled() =>
      _p.getBool(_keyNotificationsEnabled) ?? true;

  static Future<void> clearAll() => _p.clear();
}
