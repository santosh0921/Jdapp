import 'package:jd_style_logistics/core/network/api_client.dart';
import 'package:jd_style_logistics/core/network/api_endpoints.dart';
import 'package:jd_style_logistics/models/shipment_model.dart';

class TrackingService {
  TrackingService._();
  static final TrackingService instance = TrackingService._();

  // ── Track order ───────────────────────────────────────────────────────────

  Future<List<TrackingEventModel>> getEvents(String trackingId) async {
    try {
      final r = await ApiClient.instance.get(ApiEndpoints.trackOrder(trackingId));
      final list = (r.data['data'] as List<dynamic>?) ?? [];
      return list
          .map((e) => TrackingEventModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ── Update driver location (best-effort, never throws) ────────────────────

  Future<void> updateDriverLocation({
    required String orderId,
    required double lat,
    required double lng,
    double? heading,
  }) async {
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
    try {
      final r = await ApiClient.instance.get(ApiEndpoints.mapsDistance, params: {
        'from_lat': fromLat,
        'from_lng': fromLng,
        'to_lat': toLat,
        'to_lng': toLng,
      });
      return r.data['data'] as Map<String, dynamic>? ?? {};
    } catch (_) {
      return {};
    }
  }

  Future<Map<String, dynamic>> getRoute({
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
  }) async {
    try {
      final r = await ApiClient.instance.get(ApiEndpoints.mapsRoute, params: {
        'from_lat': fromLat,
        'from_lng': fromLng,
        'to_lat': toLat,
        'to_lng': toLng,
      });
      return r.data['data'] as Map<String, dynamic>? ?? {};
    } catch (_) {
      return {};
    }
  }
}
