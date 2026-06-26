import 'package:jd_style_logistics/core/network/api_client.dart';
import 'package:jd_style_logistics/core/network/api_endpoints.dart';

class LogisticsService {
  LogisticsService._();
  static final LogisticsService instance = LogisticsService._();

  // ── Price estimate ────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> estimate(Map<String, dynamic> body) async {
    final r = await ApiClient.instance.post(ApiEndpoints.logisticsEstimate, data: body);
    return r.data['data'] as Map<String, dynamic>;
  }

  // ── Create order ──────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> body) async {
    final r = await ApiClient.instance.post(ApiEndpoints.logisticsOrders, data: body);
    return r.data['data'] as Map<String, dynamic>;
  }

  // ── Get orders ────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getOrders({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final r = await ApiClient.instance.get(
        ApiEndpoints.logisticsOrders,
        params: {
          if (status != null) 'status': status,
          'page': page,
          'limit': limit,
        },
      );
      final list = (r.data['data'] as List<dynamic>?) ?? [];
      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  // ── Get single order ──────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getOrderById(String id) async {
    final r = await ApiClient.instance.get(ApiEndpoints.logisticsOrderById(id));
    return r.data['data'] as Map<String, dynamic>;
  }

  // ── Cancel order ──────────────────────────────────────────────────────────

  Future<bool> cancelOrder(String id) async {
    try {
      await ApiClient.instance.post(ApiEndpoints.cancelLogisticsOrder(id));
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Tracking events ───────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getTracking(String id) async {
    try {
      final r = await ApiClient.instance.get(ApiEndpoints.logisticsTracking(id));
      final list = (r.data['data'] as List<dynamic>?) ?? [];
      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }
}
