import 'package:jd_style_logistics/core/network/api_client.dart';
import 'package:jd_style_logistics/core/network/api_endpoints.dart';

class PricingService {
  PricingService._();
  static final PricingService instance = PricingService._();

  // ── Master data ───────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getGoodsCategories() async {
    try {
      final r = await ApiClient.instance.get(ApiEndpoints.masterGoodsCategories);
      final list = (r.data['data'] as List<dynamic>?) ?? [];
      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getTransportModes() async {
    try {
      final r = await ApiClient.instance.get(ApiEndpoints.masterTransportModes);
      final list = (r.data['data'] as List<dynamic>?) ?? [];
      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getVehicleTypes() async {
    try {
      final r = await ApiClient.instance.get(ApiEndpoints.masterVehicleTypes);
      final list = (r.data['data'] as List<dynamic>?) ?? [];
      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getGstRates() async {
    try {
      final r = await ApiClient.instance.get(ApiEndpoints.masterGSTRates);
      final list = (r.data['data'] as List<dynamic>?) ?? [];
      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getHsnCodes(String category) async {
    try {
      final r = await ApiClient.instance.get(
        ApiEndpoints.masterHSNCodes,
        params: {'category': category},
      );
      final list = (r.data['data'] as List<dynamic>?) ?? [];
      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  // ── Pricing estimates ─────────────────────────────────────────────────────

  Future<Map<String, dynamic>> estimateLogistics(Map<String, dynamic> body) async {
    final r = await ApiClient.instance.post(ApiEndpoints.pricingLogisticsEstimate, data: body);
    return r.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> estimateCourier(Map<String, dynamic> body) async {
    final r = await ApiClient.instance.post(ApiEndpoints.pricingCourierEstimate, data: body);
    return r.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> estimateMultiModal(Map<String, dynamic> body) async {
    final r = await ApiClient.instance.post(ApiEndpoints.pricingMultiModal, data: body);
    return r.data['data'] as Map<String, dynamic>;
  }

  // ── Goods intelligence ────────────────────────────────────────────────────
  // Analyzes goods type and provides handling/insurance/routing suggestions.
  // Calls backend first; falls back to local rule-based analysis.

  Future<Map<String, dynamic>> analyzeGoods(String goodsId) async {
    try {
      final r = await ApiClient.instance.get(
        ApiEndpoints.masterGoodsCategories,
        params: {'id': goodsId},
      );
      final data = r.data['data'];
      if (data is Map && data.isNotEmpty) return Map<String, dynamic>.from(data);
    } catch (_) {}
    return _analyzeGoodsLocally(goodsId);
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  Map<String, dynamic> _analyzeGoodsLocally(String goodsId) {
    final id = goodsId.toLowerCase();
    String riskLevel = 'normal';
    String classType = 'standard';
    double gstRate = 18.0;

    if (id.contains('food') || id.contains('grain') || id.contains('vegetable') ||
        id.contains('fruit') || id.contains('dairy') || id.contains('meat')) {
      riskLevel = 'perishable'; classType = 'perishable'; gstRate = 0.0;
    } else if (id.contains('hazard') || id.contains('chemical') || id.contains('acid') ||
        id.contains('explosive') || id.contains('flammable')) {
      riskLevel = 'hazardous'; classType = 'hazardous'; gstRate = 18.0;
    } else if (id.contains('pharma') || id.contains('medicine') || id.contains('drug') ||
        id.contains('medical')) {
      gstRate = 12.0;
    } else if (id.contains('textile') || id.contains('fabric') || id.contains('cloth') ||
        id.contains('garment') || id.contains('apparel')) {
      gstRate = 5.0;
    } else if (id.contains('automobile') || id.contains('vehicle') || id.contains('car') ||
        id.contains('motor')) {
      gstRate = 28.0;
    } else if (id.contains('glass') || id.contains('ceramic') || id.contains('crystal') ||
        id.contains('fragile')) {
      riskLevel = 'fragile'; classType = 'fragile';
    } else if (id.contains('gold') || id.contains('silver') || id.contains('jewel') ||
        id.contains('diamond') || id.contains('precious')) {
      riskLevel = 'high_value'; classType = 'high_value'; gstRate = 3.0;
    } else if (id.contains('steel') || id.contains('iron') || id.contains('metal') ||
        id.contains('copper') || id.contains('aluminum')) {
      riskLevel = 'heavy'; classType = 'heavy'; gstRate = 18.0;
    } else if (id.contains('frozen') || id.contains('cold') || id.contains('temperature')) {
      riskLevel = 'temperature_controlled'; classType = 'temp_controlled'; gstRate = 0.0;
    }

    return {
      'goods_id': goodsId,
      'risk_level': riskLevel,
      'class_type': classType,
      'gst_rate': gstRate,
      'suggestions': _goodsSuggestions(riskLevel, classType),
    };
  }

  Map<String, dynamic> _goodsSuggestions(String riskLevel, String classType) {
    return {
      'insurance_required': riskLevel == 'high_value' || riskLevel == 'critical',
      'temperature_control': riskLevel == 'perishable' || riskLevel == 'temperature_controlled',
      'special_handling': riskLevel == 'hazardous' || riskLevel == 'fragile',
      'documents_required': riskLevel == 'hazardous' || classType == 'export_controlled',
      'recommended_mode': riskLevel == 'perishable'
          ? 'Air'
          : riskLevel == 'heavy'
              ? 'Rail/Truck'
              : 'Truck',
      'price_impact': riskLevel == 'critical'
          ? 'High (+35%)'
          : riskLevel == 'hazardous'
              ? 'Very High (+50%)'
              : riskLevel == 'high_value'
                  ? 'High (+30%)'
                  : 'Normal',
    };
  }
}
