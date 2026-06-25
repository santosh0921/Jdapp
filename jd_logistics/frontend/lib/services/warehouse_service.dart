import 'package:jd_style_logistics/core/network/api_client.dart';
import 'package:jd_style_logistics/core/network/api_endpoints.dart';
import 'package:jd_style_logistics/models/warehouse_model.dart';

class WarehouseService {
  WarehouseService._();
  static final WarehouseService instance = WarehouseService._();

  // ── Stats ─────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getStats() async {
    try {
      final r = await ApiClient.instance.get(ApiEndpoints.warehouseStats);
      return r.data['data'] as Map<String, dynamic>? ?? {};
    } catch (_) {
      return {};
    }
  }

  // ── Inventory ─────────────────────────────────────────────────────────────

  Future<List<ParcelModel>> getInventory() async {
    try {
      final r = await ApiClient.instance.get(ApiEndpoints.warehouseInventory);
      final list = (r.data['data'] as List<dynamic>?) ?? [];
      return list
          .map((e) => ParcelModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ── Scan ──────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> scan(String trackingId, String action) async {
    final r = await ApiClient.instance.post(
      ApiEndpoints.scanParcel,
      data: {'tracking_id': trackingId, 'action': action},
    );
    return r.data['data'] as Map<String, dynamic>? ?? {};
  }

  // ── Inbound ───────────────────────────────────────────────────────────────

  Future<List<ParcelModel>> getInbound() async {
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
    try {
      await ApiClient.instance.post(
        ApiEndpoints.warehouseDispatch,
        data: {'parcel_id': parcelId},
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Reports ───────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getReports({String period = 'monthly'}) async {
    try {
      final r = await ApiClient.instance.get(
        ApiEndpoints.warehouseReports,
        params: {'period': period},
      );
      return r.data['data'] as Map<String, dynamic>? ?? {};
    } catch (_) {
      return {};
    }
  }
}
