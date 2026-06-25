import 'package:jd_style_logistics/core/constants/mock_config.dart';

class MockNotificationApi {
  MockNotificationApi._();
  static final MockNotificationApi instance = MockNotificationApi._();

  Future<Map<String, dynamic>> getNotifications(String userId, {int page = 1}) async {
    await _delay();
    return {
      'success': true,
      'data': {
        'unread_count': 4,
        'page': page,
        'notifications': List.generate(15, (i) => {
          'id': 'NOTIF-${5000 + i}',
          'type': ['shipment', 'payment', 'promo', 'system', 'obc'][i % 5],
          'title': [
            'Your shipment is out for delivery',
            'Payment of ₹842 confirmed',
            'Weekend offer: 20% off on air shipments',
            'App update available',
            'You earned 15 OBC coins!',
          ][i % 5],
          'body': [
            'JD-IND-4822 will be delivered today by 6 PM.',
            'Order JD-2025-9183 payment received.',
            'Book before Sunday. Use code AIRJD20.',
            'Update to v2.4.1 for new features.',
            'Keep shipping to earn more OBC rewards.',
          ][i % 5],
          'is_read': i >= 4,
          'timestamp': '${18 - (i ~/ 3)} Jun 2025 · ${10 + i}:${(i * 7) % 60 < 10 ? "0${(i * 7) % 60}" : (i * 7) % 60} AM',
          'action': i % 5 == 0 ? '/shipment/details?id=JD-IND-4822' : null,
        }),
      },
    };
  }

  Future<Map<String, dynamic>> markAsRead(String notifId) async {
    await _delay(ms: 200);
    return {'success': true, 'data': {'id': notifId, 'is_read': true}};
  }

  Future<Map<String, dynamic>> markAllAsRead(String userId) async {
    await _delay(ms: 300);
    return {'success': true, 'data': {'unread_count': 0}};
  }

  Future<Map<String, dynamic>> getPreferences(String userId) async {
    await _delay(ms: 400);
    return {
      'success': true,
      'data': {
        'push_enabled': true,
        'email_enabled': true,
        'sms_enabled': false,
        'types': {
          'shipment': true,
          'payment': true,
          'promo': false,
          'system': true,
          'obc': true,
        },
      },
    };
  }

  Future<Map<String, dynamic>> updatePreferences(
      String userId, Map<String, dynamic> prefs) async {
    await _delay(ms: 400);
    return {'success': true, 'data': prefs};
  }

  Future<Map<String, dynamic>> sendPushToken(String userId, String token) async {
    await _delay(ms: 300);
    return {'success': true, 'data': {'token_registered': true}};
  }

  static Future<void> _delay({int ms = 600}) =>
      Future.delayed(Duration(milliseconds: MockConfig.enabled ? ms : 0));
}
