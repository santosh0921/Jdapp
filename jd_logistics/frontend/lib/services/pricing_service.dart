import 'package:jd_style_logistics/core/constants/mock_config.dart';
import 'package:jd_style_logistics/core/data/logistics_mock_data.dart';
import 'package:jd_style_logistics/core/network/api_client.dart';
import 'package:jd_style_logistics/core/network/api_endpoints.dart';

class PricingService {
  PricingService._();
  static final PricingService instance = PricingService._();

  // ── Goods categories ──────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getGoodsCategories() async {
    if (MockConfig.enabled) {
      await Future.delayed(const Duration(milliseconds: 300));
      return LogisticsMockData.goodsCategories
          .map((c) => {'id': c, 'name': c})
          .toList();
    }
    try {
      final r = await ApiClient.instance.get(ApiEndpoints.pricingGoodsCategories);
      return List<Map<String, dynamic>>.from(r.data['data'] as List);
    } catch (_) {
      MockConfig.isFallbackActive = true;
      return LogisticsMockData.goodsCategories
          .map((c) => {'id': c, 'name': c})
          .toList();
    }
  }

  // ── Transport modes ───────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getTransportModes() async {
    if (MockConfig.enabled) {
      await Future.delayed(const Duration(milliseconds: 300));
      return _mockTransportModes;
    }
    try {
      final r = await ApiClient.instance.get(ApiEndpoints.pricingTransportModes);
      return List<Map<String, dynamic>>.from(r.data['data'] as List);
    } catch (_) {
      MockConfig.isFallbackActive = true;
      return _mockTransportModes;
    }
  }

  // ── Vehicle types ─────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getVehicleTypes() async {
    if (MockConfig.enabled) {
      await Future.delayed(const Duration(milliseconds: 300));
      return LogisticsMockData.vehicles
          .map((v) => {
                'id': v.type,
                'name': v.type,
                'min_tons': v.minTons,
                'max_tons': v.maxTons,
                'base_cost_per_km': v.baseCostPerKm,
              })
          .toList();
    }
    try {
      final r = await ApiClient.instance.get(ApiEndpoints.pricingVehicleTypes);
      return List<Map<String, dynamic>>.from(r.data['data'] as List);
    } catch (_) {
      MockConfig.isFallbackActive = true;
      return LogisticsMockData.vehicles
          .map((v) => {
                'id': v.type,
                'name': v.type,
                'min_tons': v.minTons,
                'max_tons': v.maxTons,
              })
          .toList();
    }
  }

  // ── GST rates ─────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getGstRates() async {
    if (MockConfig.enabled) {
      await Future.delayed(const Duration(milliseconds: 200));
      return _mockGstRates;
    }
    try {
      final r = await ApiClient.instance.get(ApiEndpoints.pricingGstRates);
      return List<Map<String, dynamic>>.from(r.data['data'] as List);
    } catch (_) {
      MockConfig.isFallbackActive = true;
      return _mockGstRates;
    }
  }

  // ── HSN codes ─────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getHsnCodes(String category) async {
    if (MockConfig.enabled) {
      await Future.delayed(const Duration(milliseconds: 300));
      final goods = LogisticsMockData.goodsByCategory(category);
      return goods
          .map((g) => {
                'hsn': g.hsn,
                'name': g.name,
                'gst_rate': g.gstRate,
                'category': g.category,
              })
          .toList();
    }
    try {
      final r = await ApiClient.instance
          .get(ApiEndpoints.pricingHsnCodes, params: {'category': category});
      return List<Map<String, dynamic>>.from(r.data['data'] as List);
    } catch (_) {
      MockConfig.isFallbackActive = true;
      final goods = LogisticsMockData.goodsByCategory(category);
      return goods
          .map((g) => {'hsn': g.hsn, 'name': g.name, 'gst_rate': g.gstRate})
          .toList();
    }
  }

  // ── Logistics estimate ────────────────────────────────────────────────────

  Future<Map<String, dynamic>> estimateLogistics(Map<String, dynamic> body) async {
    if (MockConfig.enabled) {
      await Future.delayed(const Duration(milliseconds: 900));
      return _mockLogisticsEstimate(body);
    }
    try {
      final r = await ApiClient.instance
          .post(ApiEndpoints.pricingLogisticsEstimate, data: body);
      return r.data['data'] as Map<String, dynamic>;
    } catch (_) {
      MockConfig.isFallbackActive = true;
      return _mockLogisticsEstimate(body);
    }
  }

  // ── Courier estimate ──────────────────────────────────────────────────────

  Future<Map<String, dynamic>> estimateCourier(Map<String, dynamic> body) async {
    if (MockConfig.enabled) {
      await Future.delayed(const Duration(milliseconds: 700));
      return _mockCourierEstimate(body);
    }
    try {
      final r = await ApiClient.instance
          .post(ApiEndpoints.pricingCourierEstimate, data: body);
      return r.data['data'] as Map<String, dynamic>;
    } catch (_) {
      MockConfig.isFallbackActive = true;
      return _mockCourierEstimate(body);
    }
  }

  // ── Multi-modal estimate ──────────────────────────────────────────────────

  Future<Map<String, dynamic>> estimateMultiModal(Map<String, dynamic> body) async {
    if (MockConfig.enabled) {
      await Future.delayed(const Duration(milliseconds: 1100));
      return _mockMultiModalEstimate(body);
    }
    try {
      final r = await ApiClient.instance
          .post(ApiEndpoints.pricingMultiModal, data: body);
      return r.data['data'] as Map<String, dynamic>;
    } catch (_) {
      MockConfig.isFallbackActive = true;
      return _mockMultiModalEstimate(body);
    }
  }

  // ── Goods intelligence (analyze goods type → suggestions) ─────────────────

  Future<Map<String, dynamic>> analyzeGoods(String goodsId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final goods = LogisticsMockData.goods
        .where((g) => g.id == goodsId)
        .firstOrNull;
    if (goods == null) return {};
    return {
      'goods_id': goods.id,
      'name': goods.name,
      'risk_level': goods.riskLevel,
      'risk_label': LogisticsMockData.riskLabel(goods.riskLevel),
      'class_type': goods.classType,
      'gst_rate': goods.gstRate,
      'hsn': goods.hsn,
      'base_rate_per_kg': goods.baseRatePerKg,
      'suggestions': _goodsSuggestions(goods.riskLevel, goods.classType),
    };
  }

  // ── Private mock builders ─────────────────────────────────────────────────

  Map<String, dynamic> _mockLogisticsEstimate(Map<String, dynamic> body) {
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
        isUrgent: isExport,
      ),
    };
  }

  Map<String, dynamic> _mockCourierEstimate(Map<String, dynamic> body) {
    final weightKg  = (body['weight_kg'] as num?)?.toDouble() ?? 0.5;
    final distance  = (body['distance_km'] as num?)?.toDouble() ?? 20.0;
    final urgency   = body['urgency'] as String? ?? 'standard';
    final insurance = body['insurance'] as bool? ?? false;

    final base       = 40.0 + distance * 0.8;
    final weightCost = weightKg * 12.0;
    final urgencyCost = urgency == 'express' ? 80.0 : urgency == 'same_day' ? 150.0 : 0.0;
    final insuranceCost = insurance ? (base + weightCost) * 0.02 : 0.0;
    final gst        = (base + weightCost + urgencyCost + insuranceCost) * 0.18;
    final total      = base + weightCost + urgencyCost + insuranceCost + gst;

    return {
      'base_charge': base,
      'weight_charge': weightCost,
      'urgency_surcharge': urgencyCost,
      'insurance_charge': insuranceCost,
      'gst': gst,
      'total': total,
      'estimated_days': urgency == 'same_day' ? 1 : urgency == 'express' ? 2 : 5,
    };
  }

  Map<String, dynamic> _mockMultiModalEstimate(Map<String, dynamic> body) {
    final segments  = body['segments'] as List<dynamic>? ?? [];
    final weightKg  = (body['weight_kg'] as num?)?.toDouble() ?? 5000.0;
    final valueDecl = (body['declared_value'] as num?)?.toDouble() ?? 500000.0;

    double pickupCost = 2500.0;
    double mainFreight = 18000.0;
    double destinationCost = 2200.0;
    double warehouseHandling = 3500.0;
    double documentCharges = 4500.0;
    double insuranceCost = valueDecl * 0.002;

    if (segments.isNotEmpty) {
      pickupCost       = weightKg * 0.5;
      mainFreight      = weightKg * 3.2;
      destinationCost  = weightKg * 0.45;
    }

    final subtotal = pickupCost + mainFreight + destinationCost +
        warehouseHandling + documentCharges + insuranceCost;
    final gst   = subtotal * 0.18;
    final total = subtotal + gst;

    return {
      'pickup_transport': pickupCost,
      'main_freight': mainFreight,
      'destination_transport': destinationCost,
      'warehouse_handling': warehouseHandling,
      'document_charges': documentCharges,
      'insurance': insuranceCost,
      'gst': gst,
      'total': total,
      'breakdown': segments.asMap().entries.map((e) => {
        'segment': e.key + 1,
        'mode': (e.value as Map<String, dynamic>)['mode'] ?? 'truck',
        'cost': (mainFreight / (segments.isEmpty ? 1 : segments.length)),
      }).toList(),
    };
  }

  Map<String, dynamic> _goodsSuggestions(String riskLevel, String classType) {
    return {
      'insurance_required': riskLevel == 'high_value' || riskLevel == 'critical',
      'temperature_control': riskLevel == 'perishable' || riskLevel == 'temperature_controlled',
      'special_handling': riskLevel == 'hazardous' || riskLevel == 'fragile',
      'documents_required': riskLevel == 'hazardous' || classType == 'export_controlled',
      'recommended_mode': riskLevel == 'perishable' ? 'Air' :
                          riskLevel == 'heavy' ? 'Rail/Truck' : 'Truck',
      'price_impact': riskLevel == 'critical' ? 'High (+35%)' :
                      riskLevel == 'hazardous' ? 'Very High (+50%)' :
                      riskLevel == 'high_value' ? 'High (+30%)' : 'Normal',
    };
  }

  static const _mockTransportModes = [
    {'id': 'truck', 'name': 'Truck', 'icon': 'truck', 'cost_per_km': 45.0},
    {'id': 'train', 'name': 'Train', 'icon': 'train', 'cost_per_km': 18.0},
    {'id': 'air', 'name': 'Air', 'icon': 'flight', 'cost_per_km': 180.0},
    {'id': 'ship', 'name': 'Ship', 'icon': 'ship', 'cost_per_km': 8.0},
    {'id': 'container_truck', 'name': 'Container Truck', 'icon': 'container', 'cost_per_km': 55.0},
    {'id': 'multi_modal', 'name': 'Multi-Modal', 'icon': 'multi', 'cost_per_km': 30.0},
  ];

  static const _mockGstRates = [
    {'goods_type': 'food_grains', 'rate': 0.0, 'description': 'Nil GST'},
    {'goods_type': 'fruits_vegetables', 'rate': 0.0, 'description': 'Nil GST'},
    {'goods_type': 'textile', 'rate': 5.0, 'description': '5% GST'},
    {'goods_type': 'electronics', 'rate': 18.0, 'description': '18% GST'},
    {'goods_type': 'metal', 'rate': 18.0, 'description': '18% GST'},
    {'goods_type': 'chemicals', 'rate': 18.0, 'description': '18% GST'},
    {'goods_type': 'pharma', 'rate': 12.0, 'description': '12% GST'},
    {'goods_type': 'automobile_parts', 'rate': 28.0, 'description': '28% GST'},
    {'goods_type': 'hazardous', 'rate': 18.0, 'description': '18% GST'},
    {'goods_type': 'furniture', 'rate': 18.0, 'description': '18% GST'},
  ];
}
