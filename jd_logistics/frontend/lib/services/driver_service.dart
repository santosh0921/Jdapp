import 'package:jd_style_logistics/core/network/api_client.dart';
import 'package:jd_style_logistics/core/network/api_endpoints.dart';
import 'package:jd_style_logistics/models/driver_model.dart';
import 'package:jd_style_logistics/models/shipment_model.dart';

class DriverService {
  DriverService._();
  static final DriverService instance = DriverService._();

  // ── Profile ───────────────────────────────────────────────────────────────

  Future<DriverModel> getProfile() async {
    final r = await ApiClient.instance.get(ApiEndpoints.driverProfile);
    return DriverModel.fromJson(r.data['data'] as Map<String, dynamic>);
  }

  Future<DriverModel> toggleOnline(bool isOnline) async {
    final r = await ApiClient.instance.post(
      ApiEndpoints.driverToggleOnline,
      data: {'is_online': isOnline},
    );
    return DriverModel.fromJson(r.data['data'] as Map<String, dynamic>);
  }

  // ── Orders ────────────────────────────────────────────────────────────────

  Future<List<ShipmentModel>> getAvailableOrders() async {
    try {
      final r = await ApiClient.instance.get(ApiEndpoints.driverAvailableOrders);
      final list = (r.data['data'] as List<dynamic>?) ?? [];
      return list
          .map((e) => ShipmentModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<ShipmentModel>> getActiveOrders() async {
    try {
      final r = await ApiClient.instance.get(ApiEndpoints.driverActiveOrders);
      final list = (r.data['data'] as List<dynamic>?) ?? [];
      return list
          .map((e) => ShipmentModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> acceptOrder(String orderId) async {
    try {
      await ApiClient.instance.post(ApiEndpoints.driverAcceptOrder(orderId));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> rejectOrder(String orderId) async {
    try {
      await ApiClient.instance.post(ApiEndpoints.driverRejectOrder(orderId));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> markPickup(String orderId) async {
    try {
      await ApiClient.instance.post(ApiEndpoints.driverPickup(orderId));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> markDelivered(String orderId) async {
    try {
      await ApiClient.instance.post(ApiEndpoints.driverDelivered(orderId));
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Location ──────────────────────────────────────────────────────────────

  Future<void> updateLocation(double lat, double lng) async {
    try {
      await ApiClient.instance.post(
        ApiEndpoints.driverLocation,
        data: {'latitude': lat, 'longitude': lng},
      );
    } catch (_) {
      // Non-critical — swallow silently
    }
  }

  // ── Navigation ────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getNavigation(String orderId) async {
    try {
      final r = await ApiClient.instance.get(ApiEndpoints.driverNavigation(orderId));
      return r.data['data'] as Map<String, dynamic>? ?? {};
    } catch (_) {
      return {};
    }
  }

  // ── Earnings ──────────────────────────────────────────────────────────────

  Future<List<EarningModel>> getEarnings() async {
    try {
      final r = await ApiClient.instance.get(ApiEndpoints.driverEarnings);
      final list = (r.data['data'] as List<dynamic>?) ?? [];
      return list
          .map((e) => EarningModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ── Wallet ────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getWallet() async {
    try {
      final r = await ApiClient.instance.get(ApiEndpoints.driverWallet);
      return r.data['data'] as Map<String, dynamic>? ?? {};
    } catch (_) {
      return {};
    }
  }

  // ── History ───────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getHistory({int page = 1}) async {
    try {
      final r = await ApiClient.instance.get(
        ApiEndpoints.driverHistory,
        params: {'page': page},
      );
      final list = (r.data['data'] as List<dynamic>?) ?? [];
      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }
}
