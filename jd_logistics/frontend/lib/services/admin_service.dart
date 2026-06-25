import 'package:jd_style_logistics/core/network/api_client.dart';
import 'package:jd_style_logistics/core/network/api_endpoints.dart';

class AdminService {
  AdminService._();
  static final AdminService instance = AdminService._();

  // ── Dashboard ─────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getDashboard() async {
    final r = await ApiClient.instance.get(ApiEndpoints.adminDashboard);
    return r.data['data'] as Map<String, dynamic>? ?? {};
  }

  // ── Shipment lists ────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getShipments({
    String? status,
    int page = 1,
  }) async {
    try {
      final r = await ApiClient.instance.get(
        ApiEndpoints.adminShipments,
        params: {if (status != null) 'status': status, 'page': page},
      );
      return _toList(r.data['data']);
    } catch (_) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getCourierOrders({int page = 1}) async {
    try {
      final r = await ApiClient.instance.get(
        ApiEndpoints.adminCourierOrders,
        params: {'page': page},
      );
      return _toList(r.data['data']);
    } catch (_) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getLogisticsOrders({int page = 1}) async {
    try {
      final r = await ApiClient.instance.get(
        ApiEndpoints.adminLogisticsOrders,
        params: {'page': page},
      );
      return _toList(r.data['data']);
    } catch (_) {
      return [];
    }
  }

  // ── Users ─────────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getUsers({
    String? role,
    int page = 1,
  }) async {
    try {
      final r = await ApiClient.instance.get(
        ApiEndpoints.adminUsers,
        params: {if (role != null) 'role': role, 'page': page},
      );
      return _toList(r.data['data']);
    } catch (_) {
      return [];
    }
  }

  // ── Drivers ───────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getDrivers({
    String? status,
    int page = 1,
  }) async {
    try {
      final r = await ApiClient.instance.get(
        ApiEndpoints.adminDrivers,
        params: {if (status != null) 'status': status, 'page': page},
      );
      return _toList(r.data['data']);
    } catch (_) {
      return [];
    }
  }

  // ── Warehouses ────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getWarehouses() async {
    try {
      final r = await ApiClient.instance.get(ApiEndpoints.adminWarehouses);
      return _toList(r.data['data']);
    } catch (_) {
      return [];
    }
  }

  Future<Map<String, dynamic>> getWarehouseDetails(String id) async {
    try {
      final r = await ApiClient.instance.get(ApiEndpoints.adminWarehouseById(id));
      return r.data['data'] as Map<String, dynamic>? ?? {};
    } catch (_) {
      return {};
    }
  }

  // ── Fleet ─────────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getFleet() async {
    try {
      final r = await ApiClient.instance.get(ApiEndpoints.adminFleet);
      return _toList(r.data['data']);
    } catch (_) {
      return [];
    }
  }

  // ── Analytics ─────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getAnalytics({String period = '30d'}) async {
    try {
      final r = await ApiClient.instance.get(
        ApiEndpoints.adminAnalytics,
        params: {'period': period},
      );
      return r.data['data'] as Map<String, dynamic>? ?? {};
    } catch (_) {
      return {};
    }
  }

  // ── Audit logs ────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getAuditLogs({int page = 1}) async {
    try {
      final r = await ApiClient.instance.get(
        ApiEndpoints.adminAuditLogs,
        params: {'page': page},
      );
      return _toList(r.data['data']);
    } catch (_) {
      return [];
    }
  }

  // ── Security ──────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getSecurity() async {
    try {
      final r = await ApiClient.instance.get(ApiEndpoints.adminSecurity);
      return r.data['data'] as Map<String, dynamic>? ?? {};
    } catch (_) {
      return {};
    }
  }

  // ── Reports ───────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getReports({String type = 'monthly'}) async {
    try {
      final r = await ApiClient.instance.get(
        ApiEndpoints.adminReports,
        params: {'type': type},
      );
      return r.data['data'] as Map<String, dynamic>? ?? {};
    } catch (_) {
      return {};
    }
  }

  // ── Payments ──────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getPayments({int page = 1}) async {
    try {
      final r = await ApiClient.instance.get(
        ApiEndpoints.adminPayments,
        params: {'page': page},
      );
      return _toList(r.data['data']);
    } catch (_) {
      return [];
    }
  }

  // ── Helper ────────────────────────────────────────────────────────────────

  static List<Map<String, dynamic>> _toList(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return [];
  }
}
