import 'package:jd_style_logistics/core/constants/mock_config.dart';
import 'package:jd_style_logistics/core/data/logistics_mock_data.dart';
import 'package:jd_style_logistics/core/network/api_client.dart';
import 'package:jd_style_logistics/core/network/api_endpoints.dart';

class LogisticsService {
  LogisticsService._();
  static final LogisticsService instance = LogisticsService._();

  // ── Estimate ──────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> estimate(Map<String, dynamic> body) async {
    if (MockConfig.enabled) {
      await Future.delayed(const Duration(milliseconds: 900));
      return _mockEstimate(body);
    }
    try {
      final r = await ApiClient.instance
          .post(ApiEndpoints.logisticsEstimate, data: body);
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
      final id = 'JDL-${DateTime.now().year}-${DateTime.now().millisecond.toString().padLeft(4, '0')}';
      return {
        'order_id': id,
        'status': 'confirmed',
        'message': 'Order placed successfully',
        'estimated_pickup': '2–4 hours',
        ...body,
      };
    }
    try {
      final r = await ApiClient.instance
          .post(ApiEndpoints.logisticsOrders, data: body);
      return r.data['data'] as Map<String, dynamic>;
    } catch (_) {
      MockConfig.isFallbackActive = true;
      final id = 'JDL-DEMO-${DateTime.now().millisecond}';
      return {'order_id': id, 'status': 'confirmed_demo'};
    }
  }

  // ── Get orders ────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getOrders({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    if (MockConfig.enabled) {
      await Future.delayed(const Duration(milliseconds: 500));
      return _mockOrders;
    }
    try {
      final r = await ApiClient.instance.get(
        ApiEndpoints.logisticsOrders,
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
      return _mockOrders.firstWhere(
        (o) => o['order_id'] == id,
        orElse: () => _mockOrders.first,
      );
    }
    try {
      final r = await ApiClient.instance
          .get(ApiEndpoints.logisticsOrderById(id));
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
      await ApiClient.instance.post(ApiEndpoints.cancelLogisticsOrder(id));
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Tracking ──────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getTracking(String id) async {
    if (MockConfig.enabled) {
      await Future.delayed(const Duration(milliseconds: 400));
      return _mockTrackingEvents(id);
    }
    try {
      final r = await ApiClient.instance
          .get(ApiEndpoints.logisticsTracking(id));
      return List<Map<String, dynamic>>.from(r.data['data'] as List);
    } catch (_) {
      MockConfig.isFallbackActive = true;
      return _mockTrackingEvents(id);
    }
  }

  // ── Mock data ─────────────────────────────────────────────────────────────

  Map<String, dynamic> _mockEstimate(Map<String, dynamic> body) {
    final weightKg       = (body['weight_kg'] as num?)?.toDouble() ?? 1000.0;
    final fromCity       = body['from_city'] as String? ?? 'Mumbai';
    final toCity         = body['to_city'] as String? ?? 'Delhi';
    final goodsId        = body['goods_id'] as String? ?? 'metal_steel_bars';
    final isExport       = body['shipment_type'] == 'export';
    final needsWarehouse = body['needs_warehouse'] as bool? ?? false;
    final goodsValue     = (body['goods_value'] as num?)?.toDouble() ?? 500000.0;
    final mode           = body['transport_mode'] as String? ?? 'road';

    final goods = LogisticsMockData.goods
        .where((g) => g.id == goodsId)
        .firstOrNull ?? LogisticsMockData.goods.first;

    final distanceKm = LogisticsMockData.estimateDistance(fromCity, toCity);
    final weightTons = LogisticsMockData.toTons(weightKg);

    final vehicle = LogisticsMockData.recommendVehicle(
      weightTons: weightTons,
      shipmentType: mode,
      classType: goods.classType,
      isUrgent: false,
    );

    final result = LogisticsMockData.calculateFreight(
      goods: goods,
      weightKg: weightKg,
      distanceKm: distanceKm,
      vehicle: vehicle,
      isExport: isExport,
      needsWarehouse: needsWarehouse,
      goodsValue: goodsValue,
    );

    return {
      'base_freight': result.baseFreight,
      'distance_cost': result.distanceCost,
      'weight_cost': result.weightCost,
      'vehicle_cost': result.vehicleCost,
      'risk_cost': result.riskCost,
      'handling_charges': result.handlingCharges,
      'insurance_premium': result.insurancePremium,
      'warehouse_charges': result.warehouseCharges,
      'documentation_charges': result.documentationCharges,
      'customs_charges': result.customsCharges,
      'gst_amount': result.gstAmount,
      'total_amount': result.totalAmount,
      'insurance_coverage': result.insuranceCoverage,
      'recommended_vehicle': vehicle.type,
      'distance_km': distanceKm,
      'ai_recommendations': LogisticsMockData.aiRecommendations(
        goods: goods,
        weightKg: weightKg,
        shipmentType: mode,
        isUrgent: false,
      ),
    };
  }

  static final List<Map<String, dynamic>> _mockOrders = [
    {
      'order_id': 'JDL-2024-0042',
      'shipment_type': 'export',
      'goods': 'Steel Bars',
      'from_city': 'Mumbai',
      'to_city': 'Jebel Ali, UAE',
      'weight_kg': 15000,
      'total_amount': 284750.0,
      'status': 'in_transit',
      'created_at': '2024-06-01T09:00:00Z',
      'eta': '2024-06-12',
    },
    {
      'order_id': 'JDL-2024-0039',
      'shipment_type': 'domestic_bulk',
      'goods': 'Electronics',
      'from_city': 'Chennai',
      'to_city': 'Delhi',
      'weight_kg': 3200,
      'total_amount': 48200.0,
      'status': 'pickup_scheduled',
      'created_at': '2024-06-02T11:30:00Z',
      'eta': '2024-06-07',
    },
    {
      'order_id': 'JDL-2024-0031',
      'shipment_type': 'import',
      'goods': 'Machinery Parts',
      'from_city': 'Rotterdam, NL',
      'to_city': 'Mumbai',
      'weight_kg': 28000,
      'total_amount': 512400.0,
      'status': 'customs_clearance',
      'created_at': '2024-05-28T07:00:00Z',
      'eta': '2024-06-15',
    },
    {
      'order_id': 'JDL-2024-0018',
      'shipment_type': 'warehouse_transfer',
      'goods': 'Food Grains',
      'from_city': 'Ludhiana',
      'to_city': 'Hyderabad',
      'weight_kg': 50000,
      'total_amount': 128000.0,
      'status': 'delivered',
      'created_at': '2024-05-20T08:00:00Z',
      'eta': '2024-05-27',
    },
  ];

  List<Map<String, dynamic>> _mockTrackingEvents(String id) => [
    {
      'event': 'Order Confirmed',
      'location': 'Mumbai Hub',
      'timestamp': '2024-06-01T09:00:00Z',
      'status': 'completed',
      'icon': 'check_circle',
    },
    {
      'event': 'Pickup Scheduled',
      'location': 'Pickup Address',
      'timestamp': '2024-06-01T14:00:00Z',
      'status': 'completed',
      'icon': 'local_shipping',
    },
    {
      'event': 'In Transit',
      'location': 'JNPT Port, Nhava Sheva',
      'timestamp': '2024-06-02T06:00:00Z',
      'status': 'active',
      'icon': 'directions_boat',
    },
    {
      'event': 'Customs Clearance',
      'location': 'Destination Port',
      'timestamp': null,
      'status': 'pending',
      'icon': 'description',
    },
    {
      'event': 'Out for Delivery',
      'location': 'Destination City',
      'timestamp': null,
      'status': 'pending',
      'icon': 'local_shipping',
    },
    {
      'event': 'Delivered',
      'location': 'Destination Address',
      'timestamp': null,
      'status': 'pending',
      'icon': 'inventory_2',
    },
  ];
}
