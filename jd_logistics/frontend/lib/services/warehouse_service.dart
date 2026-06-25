import 'package:jd_style_logistics/core/constants/mock_config.dart';
import 'package:jd_style_logistics/core/network/api_client.dart';
import 'package:jd_style_logistics/core/network/api_endpoints.dart';
import 'package:jd_style_logistics/models/warehouse_model.dart';

class WarehouseService {
  WarehouseService._();
  static final WarehouseService instance = WarehouseService._();

  // ── Stats ─────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getStats() async {
    if (MockConfig.enabled) {
      await Future.delayed(const Duration(milliseconds: 400));
      return _mockStats;
    }
    try {
      final r = await ApiClient.instance.get(ApiEndpoints.warehouseStats);
      return r.data['data'] as Map<String, dynamic>? ?? {};
    } catch (_) {
      MockConfig.isFallbackActive = true;
      return _mockStats;
    }
  }

  // ── Inventory ─────────────────────────────────────────────────────────────

  Future<List<ParcelModel>> getInventory() async {
    if (MockConfig.enabled) {
      await Future.delayed(const Duration(milliseconds: 600));
      return [];
    }
    try {
      final r = await ApiClient.instance.get(ApiEndpoints.warehouseInventory);
      final list = (r.data['data'] as List<dynamic>?) ?? [];
      return list
          .map((e) => ParcelModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      MockConfig.isFallbackActive = true;
      return [];
    }
  }

  // ── Scan ──────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> scan(String trackingId, String action) async {
    if (MockConfig.enabled) {
      await Future.delayed(const Duration(milliseconds: 500));
      return {
        'tracking_id': trackingId,
        'action': action,
        'status': 'success',
        'location': 'Mumbai North — Bay 3',
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
    try {
      final r = await ApiClient.instance.post(ApiEndpoints.scanParcel,
          data: {'tracking_id': trackingId, 'action': action});
      return r.data['data'] as Map<String, dynamic>? ?? {};
    } catch (_) {
      MockConfig.isFallbackActive = true;
      return {'status': 'demo', 'tracking_id': trackingId};
    }
  }

  // ── Inbound ───────────────────────────────────────────────────────────────

  Future<List<ParcelModel>> getInbound() async {
    if (MockConfig.enabled) {
      await Future.delayed(const Duration(milliseconds: 500));
      return [];
    }
    try {
      final r = await ApiClient.instance.get(ApiEndpoints.warehouseInbound);
      final list = (r.data['data'] as List<dynamic>?) ?? [];
      return list
          .map((e) => ParcelModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ── Outbound ──────────────────────────────────────────────────────────────

  Future<List<ParcelModel>> getOutbound() async {
    if (MockConfig.enabled) {
      await Future.delayed(const Duration(milliseconds: 500));
      return [];
    }
    try {
      final r = await ApiClient.instance.get(ApiEndpoints.warehouseOutbound);
      final list = (r.data['data'] as List<dynamic>?) ?? [];
      return list
          .map((e) => ParcelModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ── Returns ───────────────────────────────────────────────────────────────

  Future<List<ParcelModel>> getReturns() async {
    if (MockConfig.enabled) {
      await Future.delayed(const Duration(milliseconds: 500));
      return [];
    }
    try {
      final r = await ApiClient.instance.get(ApiEndpoints.warehouseReturns);
      final list = (r.data['data'] as List<dynamic>?) ?? [];
      return list
          .map((e) => ParcelModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ── Dispatch ──────────────────────────────────────────────────────────────

  Future<bool> dispatch(String parcelId) async {
    if (MockConfig.enabled) {
      await Future.delayed(const Duration(milliseconds: 500));
      return true;
    }
    try {
      await ApiClient.instance.post(ApiEndpoints.warehouseDispatch,
          data: {'parcel_id': parcelId});
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Reports ───────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getReports({String period = 'monthly'}) async {
    if (MockConfig.enabled) {
      await Future.delayed(const Duration(milliseconds: 600));
      return _mockReports;
    }
    try {
      final r = await ApiClient.instance.get(ApiEndpoints.warehouseReports,
          params: {'period': period});
      return r.data['data'] as Map<String, dynamic>? ?? {};
    } catch (_) {
      MockConfig.isFallbackActive = true;
      return _mockReports;
    }
  }

  // ── Mock data ─────────────────────────────────────────────────────────────

  static const _mockStats = {
    'total_parcels': 2840,
    'inbound_today': 284,
    'outbound_today': 312,
    'pending_dispatch': 48,
    'returns_pending': 12,
    'capacity_used_pct': 0.74,
    'total_sq_ft': 95000,
    'available_sq_ft': 24700,
  };

  static const _mockReports = {
    'period': 'June 2024',
    'total_processed': 8420,
    'inbound': 4210,
    'outbound': 3840,
    'returns': 370,
    'on_time_pct': 0.96,
    'accuracy_pct': 0.998,
    'top_category': 'Electronics',
    'avg_dwell_days': 2.4,
  };
}
