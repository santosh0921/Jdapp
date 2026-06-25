import 'package:jd_style_logistics/core/constants/mock_config.dart';

class MockEmailApi {
  MockEmailApi._();
  static final MockEmailApi instance = MockEmailApi._();

  Future<Map<String, dynamic>> sendOtpEmail(String email, String otp) async {
    await _delay();
    return {
      'success': true,
      'data': {'email': email, 'message': 'OTP sent (mock — no real email sent)'},
    };
  }

  Future<Map<String, dynamic>> sendInvoice(String orderId, String email) async {
    await _delay(ms: 500);
    return {
      'success': true,
      'data': {
        'order_id': orderId,
        'email': email,
        'message': 'Invoice sent to $email (mock)',
      },
    };
  }

  Future<Map<String, dynamic>> sendShipmentUpdate(
      String shipmentId, String email, String status) async {
    await _delay(ms: 400);
    return {
      'success': true,
      'data': {'shipment_id': shipmentId, 'email': email, 'status': status},
    };
  }

  Future<Map<String, dynamic>> sendSupportTicket({
    required String userId,
    required String email,
    required String subject,
    required String body,
  }) async {
    await _delay(ms: 600);
    return {
      'success': true,
      'data': {
        'ticket_id': 'TKT-${DateTime.now().millisecondsSinceEpoch % 10000}',
        'status': 'open',
        'estimated_reply': '24 hours',
      },
    };
  }

  Future<Map<String, dynamic>> sendDriverPayout(String driverId, double amount, String email) async {
    await _delay(ms: 500);
    return {
      'success': true,
      'data': {
        'driver_id': driverId,
        'amount': amount,
        'email': email,
        'message': 'Payout confirmation sent (mock)',
      },
    };
  }

  static Future<void> _delay({int ms = 600}) =>
      Future.delayed(Duration(milliseconds: MockConfig.enabled ? ms : 0));
}
