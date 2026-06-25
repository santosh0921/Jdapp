import 'package:jd_style_logistics/core/constants/mock_config.dart';

class MockPaymentApi {
  MockPaymentApi._();
  static final MockPaymentApi instance = MockPaymentApi._();

  Future<Map<String, dynamic>> getWallet(String userId) async {
    await _delay();
    return {
      'success': true,
      'data': {
        'balance': 1240.0,
        'obc_balance': 348,
        'obc_value_inr': 34.8,
        'cashback_pending': 120.0,
        'saved_cards': [
          {'id': 'CARD-001', 'last4': '4242', 'brand': 'Visa', 'expiry': '12/27'},
          {'id': 'CARD-002', 'last4': '1111', 'brand': 'Mastercard', 'expiry': '09/26'},
        ],
        'upi_ids': ['user@okaxis', 'user@ybl'],
        'transactions': List.generate(10, (i) => {
          'id': 'TXN-${8000 + i}',
          'type': i % 3 == 0 ? 'credit' : 'debit',
          'amount': 100.0 + (i * 85),
          'description': i % 3 == 0 ? 'Wallet top-up' : i % 3 == 1 ? 'Shipment payment' : 'OBC cashback',
          'date': '${18 - i} Jun 2025',
          'status': 'success',
          'obc_earned': i % 3 == 2 ? (i * 2) : 0,
        }),
      },
    };
  }

  Future<Map<String, dynamic>> initiatePayment({
    required double amount,
    required String method,
    required String orderId,
  }) async {
    await _delay(ms: 1000);
    return {
      'success': true,
      'data': {
        'payment_id': 'PAY-MOCK-${DateTime.now().millisecondsSinceEpoch}',
        'order_id': orderId,
        'amount': amount,
        'method': method,
        'status': 'success',
        'obc_earned': (amount * 0.01).round(),
        'receipt_url': 'https://invoice.jdlogistics.in/mock',
      },
    };
  }

  Future<Map<String, dynamic>> topUpWallet(double amount, String method) async {
    await _delay(ms: 800);
    return {
      'success': true,
      'data': {
        'transaction_id': 'TOP-MOCK-${DateTime.now().millisecondsSinceEpoch}',
        'amount': amount,
        'new_balance': 1240.0 + amount,
        'method': method,
        'bonus_obc': (amount * 0.02).round(),
      },
    };
  }

  Future<Map<String, dynamic>> redeemObc(int obcAmount) async {
    await _delay(ms: 500);
    return {
      'success': true,
      'data': {
        'obc_redeemed': obcAmount,
        'inr_credited': obcAmount * 0.10,
        'remaining_obc': 348 - obcAmount,
        'message': '$obcAmount OBC redeemed for ₹${(obcAmount * 0.10).toStringAsFixed(2)}',
      },
    };
  }

  Future<Map<String, dynamic>> getTransactionHistory({String? type, int page = 1}) async {
    await _delay();
    return {
      'success': true,
      'data': {
        'page': page,
        'total': 48,
        'transactions': List.generate(12, (i) => {
          'id': 'TXN-${8000 + (page * 12) + i}',
          'type': i % 3 == 0 ? 'credit' : 'debit',
          'amount': 100.0 + (i * 85),
          'description': ['Wallet top-up', 'Shipment #JD-IND-480$i', 'OBC cashback',
            'Refund received'][i % 4],
          'date': '${18 - (i % 18)} Jun 2025',
          'status': i == 5 ? 'pending' : 'success',
          'obc': i % 4 == 2 ? (i * 2) : 0,
        }),
      },
    };
  }

  Future<Map<String, dynamic>> getPaymentMethods(String userId) async {
    await _delay(ms: 400);
    return {
      'success': true,
      'data': {
        'cards': [
          {'id': 'CARD-001', 'last4': '4242', 'brand': 'Visa', 'expiry': '12/27', 'is_default': true},
          {'id': 'CARD-002', 'last4': '1111', 'brand': 'Mastercard', 'expiry': '09/26', 'is_default': false},
        ],
        'upi': [
          {'id': 'UPI-001', 'vpa': 'user@okaxis', 'is_default': false},
          {'id': 'UPI-002', 'vpa': 'user@ybl', 'is_default': false},
        ],
        'netbanking': [],
        'wallet_balance': 1240.0,
        'obc_balance': 348,
      },
    };
  }

  Future<Map<String, dynamic>> addCard(Map<String, String> cardData) async {
    await _delay(ms: 800);
    return {
      'success': true,
      'data': {
        'card_id': 'CARD-NEW-${DateTime.now().millisecondsSinceEpoch}',
        'last4': cardData['number']?.substring(cardData['number']!.length - 4) ?? '0000',
        'brand': 'Visa',
        'expiry': cardData['expiry'],
      },
    };
  }

  Future<Map<String, dynamic>> requestRefund(String orderId, double amount, String reason) async {
    await _delay(ms: 700);
    return {
      'success': true,
      'data': {
        'refund_id': 'REF-${DateTime.now().millisecondsSinceEpoch}',
        'order_id': orderId,
        'amount': amount,
        'status': 'processing',
        'eta': '3-5 business days',
      },
    };
  }

  static Future<void> _delay({int ms = 600}) =>
      Future.delayed(Duration(milliseconds: MockConfig.enabled ? ms : 0));
}
