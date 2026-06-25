import 'package:jd_style_logistics/core/constants/mock_config.dart';
import 'package:jd_style_logistics/core/network/api_client.dart';
import 'package:jd_style_logistics/core/network/api_endpoints.dart';
import 'package:jd_style_logistics/models/payment_model.dart';

class PaymentService {
  PaymentService._();
  static final PaymentService instance = PaymentService._();

  // ── Wallet ────────────────────────────────────────────────────────────────

  Future<WalletModel> getWallet() async {
    if (MockConfig.enabled) {
      await Future.delayed(const Duration(milliseconds: 400));
      return const WalletModel(id: 'wallet_mock', balance: 12840.50);
    }
    try {
      final r = await ApiClient.instance.get(ApiEndpoints.paymentBalance);
      return WalletModel.fromJson(r.data['data'] as Map<String, dynamic>);
    } catch (_) {
      MockConfig.isFallbackActive = true;
      return const WalletModel(id: 'wallet_mock', balance: 12840.50);
    }
  }

  Future<WalletModel> addMoney(double amount, String method) async {
    if (MockConfig.enabled) {
      await Future.delayed(const Duration(milliseconds: 600));
      return WalletModel(id: 'wallet_mock', balance: 12840.50 + amount);
    }
    final r = await ApiClient.instance.post(ApiEndpoints.addMoney,
        data: {'amount': amount, 'method': method});
    return WalletModel.fromJson(r.data['data'] as Map<String, dynamic>);
  }

  Future<WalletModel> withdraw(double amount) async {
    if (MockConfig.enabled) {
      await Future.delayed(const Duration(milliseconds: 600));
      return WalletModel(id: 'wallet_mock', balance: 12840.50 - amount);
    }
    final r = await ApiClient.instance.post(ApiEndpoints.withdrawMoney,
        data: {'amount': amount});
    return WalletModel.fromJson(r.data['data'] as Map<String, dynamic>);
  }

  // ── Payment history ───────────────────────────────────────────────────────

  Future<List<PaymentTransactionModel>> getHistory() async {
    if (MockConfig.enabled) {
      await Future.delayed(const Duration(milliseconds: 500));
      return _mockHistory;
    }
    try {
      final r = await ApiClient.instance.get(ApiEndpoints.paymentHistory);
      final list = (r.data['data'] as List<dynamic>?) ?? [];
      return list
          .map((e) =>
              PaymentTransactionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      MockConfig.isFallbackActive = true;
      return _mockHistory;
    }
  }

  // ── Payment methods ───────────────────────────────────────────────────────

  Future<List<PaymentMethodModel>> getMethods() async {
    if (MockConfig.enabled) {
      await Future.delayed(const Duration(milliseconds: 300));
      return _mockMethods;
    }
    try {
      final r = await ApiClient.instance.get(ApiEndpoints.paymentMethods);
      final list = (r.data['data'] as List<dynamic>?) ?? [];
      return list
          .map((e) =>
              PaymentMethodModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      MockConfig.isFallbackActive = true;
      return _mockMethods;
    }
  }

  // ── Create payment order ──────────────────────────────────────────────────

  Future<Map<String, dynamic>> createPaymentOrder({
    required String orderId,
    required double amount,
    required String method,
    String? couponCode,
    double? obcPointsToRedeem,
  }) async {
    if (MockConfig.enabled) {
      await Future.delayed(const Duration(milliseconds: 800));
      final payId = 'PAY${DateTime.now().millisecondsSinceEpoch}';
      return {
        'payment_id': payId,
        'order_id': orderId,
        'amount': amount,
        'method': method,
        'status': 'created',
        'upi_intent': method == 'upi'
            ? 'upi://pay?pa=jdlogistics@upi&pn=JD+Logistics&am=$amount&tr=$payId'
            : null,
        'gateway_order_id': 'RZPY${DateTime.now().millisecond}',
      };
    }
    try {
      final r = await ApiClient.instance.post(
        ApiEndpoints.createPaymentOrder,
        data: {
          'order_id': orderId,
          'amount': amount,
          'method': method,
          if (couponCode != null) 'coupon_code': couponCode,
          if (obcPointsToRedeem != null) 'obc_points': obcPointsToRedeem,
        },
      );
      return r.data['data'] as Map<String, dynamic>;
    } catch (_) {
      MockConfig.isFallbackActive = true;
      return {
        'payment_id': 'PAY_DEMO',
        'status': 'created_demo',
        'amount': amount,
        'method': method,
      };
    }
  }

  // ── Verify payment ────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> verifyPayment({
    required String paymentId,
    required String orderId,
    String? signature,
  }) async {
    if (MockConfig.enabled) {
      await Future.delayed(const Duration(milliseconds: 1000));
      return {
        'success': true,
        'payment_id': paymentId,
        'order_id': orderId,
        'status': 'paid',
        'message': 'Payment successful',
      };
    }
    try {
      final r = await ApiClient.instance.post(ApiEndpoints.verifyPayment, data: {
        'payment_id': paymentId,
        'order_id': orderId,
        if (signature != null) 'signature': signature,
      });
      return r.data['data'] as Map<String, dynamic>;
    } catch (_) {
      MockConfig.isFallbackActive = true;
      return {
        'success': true,
        'status': 'paid_demo',
        'payment_id': paymentId,
      };
    }
  }

  // ── Invoice ───────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getInvoice(String orderId) async {
    if (MockConfig.enabled) {
      await Future.delayed(const Duration(milliseconds: 400));
      return _mockInvoice(orderId);
    }
    try {
      final r = await ApiClient.instance.get(ApiEndpoints.paymentInvoice(orderId));
      return r.data['data'] as Map<String, dynamic>;
    } catch (_) {
      MockConfig.isFallbackActive = true;
      return _mockInvoice(orderId);
    }
  }

  // ── Mock data ─────────────────────────────────────────────────────────────

  static Map<String, dynamic> _mockInvoice(String orderId) => {
        'order_id': orderId,
        'invoice_number':
            'INV-2024-${orderId.hashCode.abs() % 9999 + 1000}',
        'date': DateTime.now().toIso8601String(),
        'gstin': '27AABCJ1234M1Z5',
        'items': [
          {'description': 'Freight Charges', 'amount': 48200.0, 'gst_rate': 18.0},
          {'description': 'Documentation', 'amount': 2500.0, 'gst_rate': 18.0},
          {'description': 'Insurance Premium', 'amount': 1200.0, 'gst_rate': 18.0},
        ],
        'subtotal': 51900.0,
        'gst_total': 9342.0,
        'grand_total': 61242.0,
      };

  static final _mockHistory = [
    PaymentTransactionModel(
      id: 'TXN001',
      shipmentId: 'JDC-2024-8821',
      amount: 1952.0,
      status: 'success',
      method: 'upi',
      type: 'debit',
      description: 'Courier — Bengaluru to Kolkata',
      createdAt: DateTime(2024, 6, 1),
    ),
    PaymentTransactionModel(
      id: 'TXN002',
      shipmentId: 'JDL-2024-0042',
      amount: 284750.0,
      status: 'success',
      method: 'net_banking',
      type: 'debit',
      description: 'Logistics Export — UAE',
      createdAt: DateTime(2024, 6, 1),
    ),
    PaymentTransactionModel(
      id: 'TXN003',
      shipmentId: 'JDC-2024-8802',
      amount: 3840.0,
      status: 'pending',
      method: 'card',
      type: 'debit',
      description: 'Courier — Chennai to Bengaluru',
      createdAt: DateTime(2024, 6, 2),
    ),
    PaymentTransactionModel(
      id: 'TXN004',
      shipmentId: null,
      amount: 5000.0,
      status: 'success',
      method: 'upi',
      type: 'credit',
      description: 'Wallet Top-up',
      createdAt: DateTime(2024, 5, 28),
    ),
  ];

  static final _mockMethods = [
    const PaymentMethodModel(
      id: 'pm_upi', type: 'upi', displayName: 'UPI', isDefault: true),
    const PaymentMethodModel(
      id: 'pm_card', type: 'card', displayName: 'Visa •••• 4242',
      last4: '4242', cardBrand: 'visa'),
    const PaymentMethodModel(
      id: 'pm_nb', type: 'net_banking', displayName: 'Net Banking',
      bankName: 'HDFC Bank'),
    const PaymentMethodModel(
      id: 'pm_wallet', type: 'wallet', displayName: 'JD Wallet'),
    const PaymentMethodModel(
      id: 'pm_obc', type: 'obc', displayName: 'OBC Points'),
  ];
}
