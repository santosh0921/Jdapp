import 'package:jd_style_logistics/core/network/api_client.dart';
import 'package:jd_style_logistics/core/network/api_endpoints.dart';
import 'package:jd_style_logistics/models/payment_model.dart';

class PaymentService {
  PaymentService._();
  static final PaymentService instance = PaymentService._();

  // ── Wallet ────────────────────────────────────────────────────────────────

  Future<WalletModel> getWallet() async {
    final r = await ApiClient.instance.get(ApiEndpoints.paymentBalance);
    return WalletModel.fromJson(r.data['data'] as Map<String, dynamic>);
  }

  Future<WalletModel> addMoney(double amount, String method) async {
    final r = await ApiClient.instance.post(
      ApiEndpoints.addMoney,
      data: {'amount': amount, 'method': method},
    );
    return WalletModel.fromJson(r.data['data'] as Map<String, dynamic>);
  }

  Future<WalletModel> withdraw(double amount) async {
    final r = await ApiClient.instance.post(
      ApiEndpoints.withdrawMoney,
      data: {'amount': amount},
    );
    return WalletModel.fromJson(r.data['data'] as Map<String, dynamic>);
  }

  // ── Payment history ───────────────────────────────────────────────────────

  Future<List<PaymentTransactionModel>> getHistory() async {
    try {
      final r = await ApiClient.instance.get(ApiEndpoints.paymentHistory);
      final list = (r.data['data'] as List<dynamic>?) ?? [];
      return list
          .map((e) => PaymentTransactionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ── Payment methods ───────────────────────────────────────────────────────

  Future<List<PaymentMethodModel>> getMethods() async {
    try {
      final r = await ApiClient.instance.get(ApiEndpoints.paymentMethods);
      final list = (r.data['data'] as List<dynamic>?) ?? [];
      return list
          .map((e) => PaymentMethodModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
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
  }

  // ── Verify payment ────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> verifyPayment({
    required String paymentId,
    required String orderId,
    String? signature,
  }) async {
    final r = await ApiClient.instance.post(ApiEndpoints.verifyPayment, data: {
      'payment_id': paymentId,
      'order_id': orderId,
      if (signature != null) 'signature': signature,
    });
    return r.data['data'] as Map<String, dynamic>;
  }

  // ── Invoice ───────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getInvoice(String orderId) async {
    try {
      final r = await ApiClient.instance.get(ApiEndpoints.paymentInvoice(orderId));
      return r.data['data'] as Map<String, dynamic>? ?? {};
    } catch (_) {
      return {};
    }
  }
}
