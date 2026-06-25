import 'package:jd_style_logistics/core/constants/mock_config.dart';
import 'package:jd_style_logistics/core/network/api_client.dart';
import 'package:jd_style_logistics/core/network/api_endpoints.dart';
import 'package:jd_style_logistics/models/driver_model.dart';
import 'package:jd_style_logistics/models/shipment_model.dart';

class DriverService {
  DriverService._();
  static final DriverService instance = DriverService._();

  // ── Profile ───────────────────────────────────────────────────────────────

  Future<DriverModel> getProfile() async {
    if (MockConfig.enabled) {
      await Future.delayed(const Duration(milliseconds: 400));
      return _mockDriver;
    }
    try {
      final r = await ApiClient.instance.get(ApiEndpoints.driverProfile);
      return DriverModel.fromJson(r.data['data'] as Map<String, dynamic>);
    } catch (_) {
      MockConfig.isFallbackActive = true;
      return _mockDriver;
    }
  }

  Future<DriverModel> toggleOnline(bool isOnline) async {
    if (MockConfig.enabled) {
      await Future.delayed(const Duration(milliseconds: 400));
      return _mockDriver;
    }
    final r = await ApiClient.instance.post(
      ApiEndpoints.driverToggleOnline,
      data: {'is_online': isOnline},
    );
    return DriverModel.fromJson(r.data['data'] as Map<String, dynamic>);
  }

  // ── Orders ────────────────────────────────────────────────────────────────

  Future<List<ShipmentModel>> getAvailableOrders() async {
    if (MockConfig.enabled) {
      await Future.delayed(const Duration(milliseconds: 600));
      return [];
    }
    try {
      final r = await ApiClient.instance.get(ApiEndpoints.driverAvailableOrders);
      final list = (r.data['data'] as List<dynamic>?) ?? [];
      return list
          .map((e) => ShipmentModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      MockConfig.isFallbackActive = true;
      return [];
    }
  }

  Future<List<ShipmentModel>> getActiveOrders() async {
    if (MockConfig.enabled) {
      await Future.delayed(const Duration(milliseconds: 500));
      return [];
    }
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
    if (MockConfig.enabled) {
      await Future.delayed(const Duration(milliseconds: 500));
      return true;
    }
    try {
      await ApiClient.instance.post(ApiEndpoints.driverAcceptOrder(orderId));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> rejectOrder(String orderId) async {
    if (MockConfig.enabled) {
      await Future.delayed(const Duration(milliseconds: 400));
      return true;
    }
    try {
      await ApiClient.instance.post(ApiEndpoints.driverRejectOrder(orderId));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> markPickup(String orderId) async {
    if (MockConfig.enabled) {
      await Future.delayed(const Duration(milliseconds: 500));
      return true;
    }
    try {
      await ApiClient.instance.post(ApiEndpoints.driverPickup(orderId));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> markDelivered(String orderId) async {
    if (MockConfig.enabled) {
      await Future.delayed(const Duration(milliseconds: 500));
      return true;
    }
    try {
      await ApiClient.instance.post(ApiEndpoints.driverDelivered(orderId));
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Location ──────────────────────────────────────────────────────────────

  Future<void> updateLocation(double lat, double lng) async {
    if (MockConfig.enabled) return;
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
    if (MockConfig.enabled) {
      await Future.delayed(const Duration(milliseconds: 400));
      return {
        'pickup_lat': 12.9716,
        'pickup_lng': 77.5946,
        'drop_lat': 12.9352,
        'drop_lng': 77.6245,
        'distance_km': 14.8,
        'eta_minutes': 38,
        'route_polyline': '',
      };
    }
    try {
      final r = await ApiClient.instance.get(ApiEndpoints.driverNavigation(orderId));
      return r.data['data'] as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  // ── Earnings ──────────────────────────────────────────────────────────────

  Future<List<EarningModel>> getEarnings() async {
    if (MockConfig.enabled) {
      await Future.delayed(const Duration(milliseconds: 500));
      return _mockEarnings;
    }
    try {
      final r = await ApiClient.instance.get(ApiEndpoints.driverEarnings);
      final list = (r.data['data'] as List<dynamic>?) ?? [];
      return list
          .map((e) => EarningModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      MockConfig.isFallbackActive = true;
      return _mockEarnings;
    }
  }

  // ── Wallet ────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getWallet() async {
    if (MockConfig.enabled) {
      await Future.delayed(const Duration(milliseconds: 400));
      return {
        'balance': 18420.0,
        'total_earned': 284200.0,
        'withdrawable': 18420.0,
        'pending_settlement': 2400.0,
      };
    }
    try {
      final r = await ApiClient.instance.get(ApiEndpoints.driverWallet);
      return r.data['data'] as Map<String, dynamic>;
    } catch (_) {
      MockConfig.isFallbackActive = true;
      return {'balance': 18420.0, 'total_earned': 284200.0};
    }
  }

  // ── History ───────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getHistory({int page = 1}) async {
    if (MockConfig.enabled) {
      await Future.delayed(const Duration(milliseconds: 500));
      return _mockDeliveryHistory;
    }
    try {
      final r = await ApiClient.instance.get(ApiEndpoints.driverHistory,
          params: {'page': page});
      return List<Map<String, dynamic>>.from(r.data['data'] as List);
    } catch (_) {
      MockConfig.isFallbackActive = true;
      return _mockDeliveryHistory;
    }
  }

  // ── Mock data ─────────────────────────────────────────────────────────────

  static const _mockDriver = DriverModel(
    id: 'DRV001',
    userId: 'USR001',
    vehicleType: 'mini_truck',
    vehicleNumber: 'MH 04 AB 1234',
    rating: 4.8,
    totalDeliveries: 1284,
    totalEarnings: 284200.0,
    isOnline: true,
    isVerified: true,
  );

  static final _mockEarnings = List.generate(7, (i) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return EarningModel(
      id: 'ERN00${i + 1}',
      amount: 800.0 + i * 120 + (i % 3) * 200,
      type: 'credit',
      description: '${8 + i} deliveries on ${days[i]}',
      createdAt: DateTime.now().subtract(Duration(days: 6 - i)),
    );
  });

  static final _mockDeliveryHistory = List.generate(10, (i) => {
    'id': 'JDC-2024-${8800 - i}',
    'pickup': 'Address ${i + 1}, Mumbai',
    'drop': 'Destination ${i + 1}, Pune',
    'date': '2024-06-0${(i % 9) + 1}',
    'amount': 320.0 + i * 80,
    'status': 'delivered',
    'rating': 4.5 + (i % 5) * 0.1,
  });
}
