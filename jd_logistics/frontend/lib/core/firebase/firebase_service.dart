import 'package:flutter/foundation.dart';

// Firebase is intentionally stubbed. To enable:
// 1. Add firebase_core, firebase_messaging, firebase_crashlytics, firebase_analytics to pubspec.yaml
// 2. Run: flutterfire configure
// 3. Replace this stub with real initialization calls.

class FirebaseService {
  FirebaseService._();
  static final FirebaseService instance = FirebaseService._();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      // await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(!kDebugMode);
      // FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
      _initialized = true;
      debugPrint('FirebaseService: stub — real init commented out');
    } catch (e) {
      debugPrint('FirebaseService: init skipped — $e');
    }
  }

  Future<String?> getFcmToken() async {
    // return await FirebaseMessaging.instance.getToken();
    return null;
  }

  void recordError(Object error, StackTrace? stack) {
    // FirebaseCrashlytics.instance.recordError(error, stack);
    debugPrint('FirebaseService.recordError: $error');
  }

  void logEvent(String name, [Map<String, Object>? params]) {
    // FirebaseAnalytics.instance.logEvent(name: name, parameters: params);
    debugPrint('FirebaseService.logEvent: $name $params');
  }
}
