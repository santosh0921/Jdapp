import 'package:jd_style_logistics/core/constants/mock_config.dart';

class MockAiMlApi {
  MockAiMlApi._();
  static final MockAiMlApi instance = MockAiMlApi._();

  Future<Map<String, dynamic>> getPriceEstimate({
    required String origin,
    required String destination,
    required double weightKg,
    required String mode,
  }) async {
    await _delay();
    final base = mode == 'air' ? 280.0 : mode == 'sea' ? 120.0 : 95.0;
    final estimate = base + (weightKg * 42) + (origin.length * 3.0);
    return {
      'success': true,
      'data': {
        'estimated_price': estimate.roundToDouble(),
        'breakdown': {
          'base_fare': base,
          'weight_charge': weightKg * 42,
          'fuel_surcharge': estimate * 0.08,
          'gst': estimate * 0.18,
        },
        'alternatives': [
          {'mode': 'road', 'price': 95.0 + (weightKg * 38), 'eta': '3-5 days'},
          {'mode': 'air', 'price': 280.0 + (weightKg * 65), 'eta': '1-2 days'},
        ],
        'confidence': 0.92,
        'factors': ['distance', 'weight', 'mode', 'demand'],
      },
    };
  }

  Future<Map<String, dynamic>> getEtaPrediction(String shipmentId) async {
    await _delay(ms: 400);
    return {
      'success': true,
      'data': {
        'shipment_id': shipmentId,
        'predicted_eta': '20 Jun 2025, 5:00 PM',
        'confidence': 0.87,
        'delay_risk': 'low',
        'factors': ['weather_clear', 'route_normal', 'driver_on_time'],
        'alternative_eta': '21 Jun 2025, 11:00 AM',
      },
    };
  }

  Future<Map<String, dynamic>> getRouteOptimization({
    required String driverId,
    required List<String> orderIds,
  }) async {
    await _delay(ms: 800);
    return {
      'success': true,
      'data': {
        'driver_id': driverId,
        'optimized_sequence': orderIds.reversed.toList(),
        'total_distance_km': 24.8,
        'estimated_time_min': 82,
        'fuel_savings_pct': 0.14,
        'stops': orderIds.asMap().entries.map((e) => {
          'sequence': e.key + 1,
          'order_id': e.value,
          'eta': '${11 + e.key}:${e.key * 15 % 60 < 10 ? "0${e.key * 15 % 60}" : e.key * 15 % 60} AM',
        }).toList(),
      },
    };
  }

  Future<Map<String, dynamic>> getAnomalyDetection(String warehouseId) async {
    await _delay();
    return {
      'success': true,
      'data': {
        'warehouse_id': warehouseId,
        'anomalies': [
          {
            'type': 'inventory_shrinkage',
            'severity': 'medium',
            'sku': 'SKU-0041',
            'expected': 120,
            'actual': 98,
            'delta': -22,
          },
        ],
        'health_score': 0.94,
        'recommendations': [
          'Run physical count for Zone B Rack 7',
          'Review outbound logs for SKU-0041',
        ],
      },
    };
  }

  Future<Map<String, dynamic>> getDemandForecast({
    required String warehouseId,
    required String period,
  }) async {
    await _delay();
    return {
      'success': true,
      'data': {
        'warehouse_id': warehouseId,
        'period': period,
        'forecast': List.generate(7, (i) => {
          'day': ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][i],
          'inbound_predicted': 120 + (i * 18),
          'outbound_predicted': 100 + (i * 15),
          'confidence': 0.82 + (i * 0.01),
        }),
        'top_skus': ['SKU-0001', 'SKU-0004', 'SKU-0009'],
      },
    };
  }

  Future<Map<String, dynamic>> getObcRewardSuggestion(String userId, String action) async {
    await _delay(ms: 300);
    final rewards = {
      'shipment_booked': 10,
      'delivery_confirmed': 15,
      'rating_given': 5,
      'referral': 50,
      'monthly_milestone': 100,
    };
    return {
      'success': true,
      'data': {
        'action': action,
        'obc_reward': rewards[action] ?? 5,
        'reason': 'Standard OBC reward for $action',
        'total_after': 348 + (rewards[action] ?? 5),
      },
    };
  }

  Future<Map<String, dynamic>> getFraudScore(String transactionId) async {
    await _delay(ms: 500);
    return {
      'success': true,
      'data': {
        'transaction_id': transactionId,
        'fraud_score': 0.04,
        'risk_level': 'low',
        'signals': ['device_trusted', 'location_consistent', 'amount_normal'],
        'decision': 'approved',
      },
    };
  }

  static Future<void> _delay({int ms = 600}) =>
      Future.delayed(Duration(milliseconds: MockConfig.enabled ? ms : 0));
}
