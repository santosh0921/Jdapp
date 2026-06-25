import 'package:jd_style_logistics/core/constants/mock_config.dart';

class MockTrackingApi {
  MockTrackingApi._();
  static final MockTrackingApi instance = MockTrackingApi._();

  Future<Map<String, dynamic>> getShipmentStatus(String id) async {
    await _delay();
    return {
      'success': true,
      'data': {
        'id': id,
        'status': 'in_transit',
        'estimated_delivery': '20 Jun 2025',
        'current_location': 'Pune Sorting Hub',
        'origin': 'Bengaluru, KA',
        'destination': 'Mumbai, MH',
        'carrier': 'BlueDart',
        'weight': '2.3 kg',
        'mode': 'road',
        'driver': {'name': 'Rajesh Kumar', 'phone': '+91 98765 43210', 'rating': 4.8},
        'timeline': [
          {'status': 'Order Placed', 'time': '18 Jun · 09:00 AM', 'done': true},
          {'status': 'Picked Up', 'time': '18 Jun · 12:30 PM', 'done': true},
          {'status': 'In Transit', 'time': '18 Jun · 04:00 PM', 'done': true},
          {'status': 'Out for Delivery', 'time': '20 Jun · 08:00 AM', 'done': false},
          {'status': 'Delivered', 'time': 'Expected 20 Jun', 'done': false},
        ],
        'current_lat': 18.5204,
        'current_lng': 73.8567,
        'dest_lat': 19.0760,
        'dest_lng': 72.8777,
      },
    };
  }

  Future<Map<String, dynamic>> getShipmentHistory(String customerId, {int page = 1}) async {
    await _delay();
    return {
      'success': true,
      'data': {
        'page': page,
        'total': 34,
        'shipments': List.generate(10, (i) => {
          'id': 'JD-IND-${4800 + i}',
          'status': i < 7 ? 'delivered' : i < 9 ? 'in_transit' : 'cancelled',
          'destination': ['Mumbai', 'Delhi', 'Chennai', 'Hyderabad', 'Pune',
            'Kolkata', 'Jaipur', 'Surat', 'Ahmedabad', 'Kochi'][i],
          'date': '${18 - i} Jun 2025',
          'amount': 180.0 + (i * 42),
          'mode': i % 3 == 0 ? 'air' : 'road',
        }),
      },
    };
  }

  Future<Map<String, dynamic>> getLiveLocation(String shipmentId) async {
    await _delay(ms: 300);
    return {
      'success': true,
      'data': {
        'shipment_id': shipmentId,
        'lat': 18.5204 + (DateTime.now().millisecondsSinceEpoch % 100) * 0.0001,
        'lng': 73.8567 + (DateTime.now().millisecondsSinceEpoch % 100) * 0.0001,
        'speed_kmh': 62,
        'heading': 320,
        'last_updated': '2 min ago',
        'waypoints': [
          {'lat': 12.9716, 'lng': 77.5946, 'label': 'Origin: Bengaluru'},
          {'lat': 15.3647, 'lng': 75.1240, 'label': 'Hubli Checkpoint'},
          {'lat': 18.5204, 'lng': 73.8567, 'label': 'Current: Pune Hub'},
          {'lat': 19.0760, 'lng': 72.8777, 'label': 'Destination: Mumbai'},
        ],
      },
    };
  }

  Future<Map<String, dynamic>> addRating(String shipmentId, double rating, String review) async {
    await _delay(ms: 400);
    return {
      'success': true,
      'data': {'shipment_id': shipmentId, 'rating': rating, 'obc_reward': 10},
    };
  }

  Future<Map<String, dynamic>> generateShareLink(String shipmentId) async {
    await _delay(ms: 300);
    return {
      'success': true,
      'data': {
        'link': 'https://track.jdlogistics.in/$shipmentId',
        'expires_in': '24 hours',
      },
    };
  }

  static Future<void> _delay({int ms = 600}) =>
      Future.delayed(Duration(milliseconds: MockConfig.enabled ? ms : 0));
}
