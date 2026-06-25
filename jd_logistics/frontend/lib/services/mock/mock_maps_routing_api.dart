import 'package:jd_style_logistics/core/constants/mock_config.dart';

class MockMapsRoutingApi {
  MockMapsRoutingApi._();
  static final MockMapsRoutingApi instance = MockMapsRoutingApi._();

  Future<Map<String, dynamic>> getRoute(
    double fromLat, double fromLng,
    double toLat, double toLng,
  ) async {
    await _delay();
    return {
      'success': true,
      'data': {
        'distance_km': 8.4,
        'duration_min': 22,
        'polyline': _mockPolyline(fromLat, fromLng, toLat, toLng),
        'steps': [
          {'instruction': 'Head north on MG Road', 'distance': '1.2 km'},
          {'instruction': 'Turn right onto Brigade Road', 'distance': '0.8 km'},
          {'instruction': 'Continue on Residency Road', 'distance': '2.1 km'},
          {'instruction': 'Turn left onto Lavelle Road', 'distance': '0.5 km'},
          {'instruction': 'Arrive at destination', 'distance': '0 m'},
        ],
        'traffic': 'moderate',
        'toll': false,
        'via': 'Fastest route via MG Road',
      },
    };
  }

  Future<Map<String, dynamic>> geocode(String address) async {
    await _delay(ms: 400);
    return {
      'success': true,
      'data': {
        'address': address,
        'lat': 12.9716 + (address.length % 10) * 0.01,
        'lng': 77.5946 + (address.length % 10) * 0.01,
        'formatted': address.trim(),
        'pincode': '56000${address.length % 10}',
        'city': 'Bengaluru',
        'state': 'Karnataka',
      },
    };
  }

  Future<Map<String, dynamic>> reverseGeocode(double lat, double lng) async {
    await _delay(ms: 300);
    return {
      'success': true,
      'data': {
        'lat': lat,
        'lng': lng,
        'address': '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)} — Mock Address, Bengaluru, KA 560001',
        'city': 'Bengaluru',
        'state': 'Karnataka',
      },
    };
  }

  Future<Map<String, dynamic>> searchNearby(double lat, double lng, String type) async {
    await _delay();
    return {
      'success': true,
      'data': List.generate(5, (i) => {
        'name': '$type Location ${i + 1}',
        'address': '${i + 1}, Sample Street, Bengaluru',
        'distance_km': 0.5 + i * 0.8,
        'lat': lat + (i * 0.005),
        'lng': lng + (i * 0.004),
      }),
    };
  }

  List<Map<String, double>> _mockPolyline(
      double fromLat, double fromLng, double toLat, double toLng) {
    const steps = 10;
    return List.generate(steps + 1, (i) => {
      'lat': fromLat + (toLat - fromLat) * i / steps,
      'lng': fromLng + (toLng - fromLng) * i / steps,
    });
  }

  static Future<void> _delay({int ms = 600}) =>
      Future.delayed(Duration(milliseconds: MockConfig.enabled ? ms : 0));
}
