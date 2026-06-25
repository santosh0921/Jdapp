import 'package:jd_style_logistics/core/constants/mock_config.dart';
import 'package:jd_style_logistics/core/network/api_client.dart';
import 'package:jd_style_logistics/core/network/api_endpoints.dart';
import 'package:jd_style_logistics/models/shipment_model.dart';

class TrackingService {
  TrackingService._();
  static final TrackingService instance = TrackingService._();

  // ── Track order ───────────────────────────────────────────────────────────

  Future<List<TrackingEventModel>> getEvents(String trackingId) async {
    if (MockConfig.enabled) {
      await Future.delayed(const Duration(milliseconds: 500));
      return _mockEvents(trackingId);
    }
    try {
      final r = await ApiClient.instance.get(ApiEndpoints.trackOrder(trackingId));
      final list = (r.data['data'] as List<dynamic>?) ?? [];
      return list
          .map((e) => TrackingEventModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      MockConfig.isFallbackActive = true;
      return _mockEvents(trackingId);
    }
  }

  // ── Update driver location (best-effort, never throws) ────────────────────

  Future<void> updateDriverLocation({
    required String orderId,
    required double lat,
    required double lng,
    double? heading,
  }) async {
    if (MockConfig.enabled) return;
    try {
      await ApiClient.instance.post(
        ApiEndpoints.updateDriverLocation,
        data: {
          'order_id': orderId,
          'latitude': lat,
          'longitude': lng,
          if (heading != null) 'heading': heading,
        },
      );
    } catch (_) {
      // Non-critical — swallow silently
    }
  }

  // ── Distance / route (maps) ───────────────────────────────────────────────

  Future<Map<String, dynamic>> getDistance({
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
  }) async {
    if (MockConfig.enabled) {
      await Future.delayed(const Duration(milliseconds: 300));
      return {'distance_km': 14.8, 'duration_min': 38, 'traffic': 'moderate'};
    }
    try {
      final r = await ApiClient.instance.get(ApiEndpoints.mapsDistance, params: {
        'from_lat': fromLat,
        'from_lng': fromLng,
        'to_lat': toLat,
        'to_lng': toLng,
      });
      return r.data['data'] as Map<String, dynamic>;
    } catch (_) {
      return {'distance_km': 14.8, 'duration_min': 38, 'traffic': 'unknown'};
    }
  }

  Future<Map<String, dynamic>> getRoute({
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
  }) async {
    if (MockConfig.enabled) {
      await Future.delayed(const Duration(milliseconds: 400));
      return {
        'polyline': '',
        'distance_km': 14.8,
        'duration_min': 38,
        'waypoints': [],
      };
    }
    try {
      final r = await ApiClient.instance.get(ApiEndpoints.mapsRoute, params: {
        'from_lat': fromLat,
        'from_lng': fromLng,
        'to_lat': toLat,
        'to_lng': toLng,
      });
      return r.data['data'] as Map<String, dynamic>;
    } catch (_) {
      return {'polyline': '', 'distance_km': 14.8, 'duration_min': 38};
    }
  }

  // ── Mock data ─────────────────────────────────────────────────────────────

  List<TrackingEventModel> _mockEvents(String id) => [
        TrackingEventModel(
          id: 'EVT001',
          status: 'Order Confirmed',
          location: 'Mumbai Hub',
          note: 'Your order has been confirmed at JD Hub',
          createdAt: DateTime.now().subtract(const Duration(hours: 8)),
        ),
        TrackingEventModel(
          id: 'EVT002',
          status: 'Pickup Done',
          location: 'Sender Address',
          note: 'Package picked up from sender',
          createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        ),
        TrackingEventModel(
          id: 'EVT003',
          status: 'In Transit',
          location: 'NH4 — Maharashtra',
          note: 'Package is on the way',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        TrackingEventModel(
          id: 'EVT004',
          status: 'Out for Delivery',
          location: 'Destination Hub',
          note: 'Package will be delivered today',
          createdAt: DateTime.now().add(const Duration(hours: 4)),
        ),
        TrackingEventModel(
          id: 'EVT005',
          status: 'Delivered',
          location: 'Recipient Address',
          note: 'Package delivered successfully',
          createdAt: DateTime.now().add(const Duration(hours: 6)),
        ),
      ];
}
