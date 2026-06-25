import 'package:jd_style_logistics/core/constants/mock_config.dart';
import 'package:jd_style_logistics/core/network/api_client.dart';
import 'package:jd_style_logistics/core/network/api_endpoints.dart';

class CourierService {
  CourierService._();
  static final CourierService instance = CourierService._();

  // ── Estimate ──────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> estimate(Map<String, dynamic> body) async {
    if (MockConfig.enabled) {
      await Future.delayed(const Duration(milliseconds: 700));
      return _mockEstimate(body);
    }
    try {
      final r = await ApiClient.instance.post(ApiEndpoints.courierEstimate, data: body);
      return r.data['data'] as Map<String, dynamic>;
    } catch (_) {
      MockConfig.isFallbackActive = true;
      return _mockEstimate(body);
    }
  }

  // ── Create order ──────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> body) async {
    if (MockConfig.enabled) {
      await Future.delayed(const Duration(milliseconds: 800));
      final id = 'JDC-${DateTime.now().year}-${DateTime.now().millisecond.toString().padLeft(4, '0')}';
      return {
        'order_id': id,
        'tracking_id': 'TRK${DateTime.now().millisecondsSinceEpoch}',
        'status': 'confirmed',
        'pickup_eta': '30–45 minutes',
        ...body,
      };
    }
    try {
      final r = await ApiClient.instance.post(ApiEndpoints.courierOrders, data: body);
      return r.data['data'] as Map<String, dynamic>;
    } catch (_) {
      MockConfig.isFallbackActive = true;
      return {'order_id': 'JDC-DEMO-${DateTime.now().millisecond}', 'status': 'confirmed_demo'};
    }
  }

  // ── Get orders ────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getOrders({String? status, int page = 1, int limit = 20}) async {
    if (MockConfig.enabled) {
      await Future.delayed(const Duration(milliseconds: 500));
      return _mockOrders;
    }
    try {
      final r = await ApiClient.instance.get(
        ApiEndpoints.courierOrders,
        params: {'status': status, 'page': page, 'limit': limit},
      );
      return List<Map<String, dynamic>>.from(r.data['data'] as List);
    } catch (_) {
      MockConfig.isFallbackActive = true;
      return _mockOrders;
    }
  }

  // ── Get single order ──────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getOrderById(String id) async {
    if (MockConfig.enabled) {
      await Future.delayed(const Duration(milliseconds: 400));
      return _mockOrders.firstWhere((o) => o['order_id'] == id, orElse: () => _mockOrders.first);
    }
    try {
      final r = await ApiClient.instance.get(ApiEndpoints.courierOrderById(id));
      return r.data['data'] as Map<String, dynamic>;
    } catch (_) {
      MockConfig.isFallbackActive = true;
      return _mockOrders.first;
    }
  }

  // ── Cancel order ──────────────────────────────────────────────────────────

  Future<bool> cancelOrder(String id) async {
    if (MockConfig.enabled) {
      await Future.delayed(const Duration(milliseconds: 500));
      return true;
    }
    try {
      await ApiClient.instance.post(ApiEndpoints.cancelCourierOrder(id));
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Tracking ──────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getTracking(String id) async {
    if (MockConfig.enabled) {
      await Future.delayed(const Duration(milliseconds: 400));
      return _mockTrackingEvents;
    }
    try {
      final r = await ApiClient.instance.get(ApiEndpoints.courierTracking(id));
      return List<Map<String, dynamic>>.from(r.data['data'] as List);
    } catch (_) {
      MockConfig.isFallbackActive = true;
      return _mockTrackingEvents;
    }
  }

  // ── Mock builders ─────────────────────────────────────────────────────────

  Map<String, dynamic> _mockEstimate(Map<String, dynamic> body) {
    final weightKg  = (body['weight_kg'] as num?)?.toDouble() ?? 0.5;
    final distance  = (body['distance_km'] as num?)?.toDouble() ?? 15.0;
    final urgency   = body['urgency'] as String? ?? 'standard';
    final insurance = body['insurance'] as bool? ?? false;
    final vehicle   = body['vehicle_type'] as String? ?? 'bike';

    final base       = vehicle == 'mini_truck' ? 80.0 : vehicle == 'truck' ? 150.0 : 40.0;
    final distCost   = distance * (vehicle == 'truck' ? 1.8 : vehicle == 'mini_truck' ? 1.2 : 0.9);
    final weightCost = weightKg * 12.0;
    final urgencyCost = urgency == 'express' ? 80.0 : urgency == 'same_day' ? 150.0 : 0.0;
    final insuranceCost = insurance ? (base + distCost + weightCost) * 0.02 : 0.0;
    final subtotal   = base + distCost + weightCost + urgencyCost + insuranceCost;
    final gst        = subtotal * 0.18;
    final total      = subtotal + gst;

    return {
      'base_charge': base,
      'distance_charge': distCost,
      'weight_charge': weightCost,
      'urgency_surcharge': urgencyCost,
      'insurance_charge': insuranceCost,
      'gst': gst,
      'total': total,
      'estimated_days': urgency == 'same_day' ? 1 : urgency == 'express' ? 2 : 5,
      'partner': 'JD Express',
    };
  }

  static final _mockOrders = [
    {
      'order_id': 'JDC-2024-8821',
      'tracking_id': 'JDTRK882100',
      'pickup': '14, MG Road, Bengaluru',
      'drop': '22, Park Street, Kolkata',
      'weight_kg': 2.5,
      'status': 'in_transit',
      'vehicle_type': 'mini_truck',
      'total': 1952.0,
      'created_at': '2024-06-01',
      'eta': '2024-06-05',
    },
    {
      'order_id': 'JDC-2024-8819',
      'tracking_id': 'JDTRK881900',
      'pickup': '5, Connaught Place, Delhi',
      'drop': '8, FC Road, Pune',
      'weight_kg': 0.8,
      'status': 'delivered',
      'vehicle_type': 'bike',
      'total': 320.0,
      'created_at': '2024-05-30',
      'eta': '2024-06-01',
    },
    {
      'order_id': 'JDC-2024-8802',
      'tracking_id': 'JDTRK880200',
      'pickup': '12, Anna Salai, Chennai',
      'drop': '45, Brigade Road, Bengaluru',
      'weight_kg': 12.0,
      'status': 'pickup_scheduled',
      'vehicle_type': 'truck',
      'total': 3840.0,
      'created_at': '2024-06-02',
      'eta': '2024-06-04',
    },
  ];

  static const _mockTrackingEvents = [
    {
      'event': 'Order Confirmed',
      'location': 'JD Hub — Bengaluru',
      'timestamp': '2024-06-01T10:30:00Z',
      'status': 'completed',
    },
    {
      'event': 'Pickup Done',
      'location': '14, MG Road, Bengaluru',
      'timestamp': '2024-06-01T13:00:00Z',
      'status': 'completed',
    },
    {
      'event': 'In Transit',
      'location': 'NH4 — Maharashtra',
      'timestamp': '2024-06-02T08:00:00Z',
      'status': 'active',
    },
    {
      'event': 'Out for Delivery',
      'location': 'Kolkata Hub',
      'timestamp': null,
      'status': 'pending',
    },
    {
      'event': 'Delivered',
      'location': '22, Park Street, Kolkata',
      'timestamp': null,
      'status': 'pending',
    },
  ];
}
