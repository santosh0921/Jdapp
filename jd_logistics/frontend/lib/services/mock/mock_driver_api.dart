import 'package:jd_style_logistics/core/constants/mock_config.dart';

class MockDriverApi {
  MockDriverApi._();
  static final MockDriverApi instance = MockDriverApi._();

  Future<Map<String, dynamic>> getHomeStats(String driverId) async {
    await _delay();
    return {
      'success': true,
      'data': {
        'today_deliveries': 8,
        'today_earnings': 642.0,
        'obc_balance': 184,
        'rating': 4.8,
        'completed_this_week': 41,
        'active_order': {
          'id': 'JD-DL-4822',
          'recipient': 'Arjun Mehta',
          'address': '17, Brigade Road, Bengaluru, KA 560025',
          'distance_remaining': '2.3 km',
          'eta': '12 min',
          'status': 'en_route',
        },
        'current_location': {'lat': 12.9716, 'lng': 77.5946},
      },
    };
  }

  Future<Map<String, dynamic>> getAvailableOrders(String driverId) async {
    await _delay();
    return {
      'success': true,
      'data': [
        {
          'id': 'JD-AV-1041',
          'pickup': 'Koramangala Hub, Bengaluru',
          'dropoff': '22, MG Road, Bengaluru, KA 560001',
          'distance': '5.4 km',
          'weight': '2.1 kg',
          'pay_mode': 'Prepaid',
          'earnings': 112.0,
          'obc_reward': 11,
          'priority': 'express',
          'expires_in': 180,
        },
        {
          'id': 'JD-AV-1042',
          'pickup': 'Whitefield Hub, Bengaluru',
          'dropoff': '7, Indiranagar, Bengaluru, KA 560038',
          'distance': '8.9 km',
          'weight': '0.8 kg',
          'pay_mode': 'COD',
          'earnings': 88.0,
          'obc_reward': 8,
          'priority': 'standard',
          'expires_in': 300,
        },
        {
          'id': 'JD-AV-1043',
          'pickup': 'HSR Hub, Bengaluru',
          'dropoff': '3, Sarjapur Road, Bengaluru, KA 560035',
          'distance': '3.2 km',
          'weight': '4.5 kg',
          'pay_mode': 'Prepaid',
          'earnings': 78.0,
          'obc_reward': 7,
          'priority': 'standard',
          'expires_in': 420,
        },
      ],
    };
  }

  Future<Map<String, dynamic>> acceptOrder(String driverId, String orderId) async {
    await _delay();
    return {
      'success': true,
      'data': {
        'order_id': orderId,
        'status': 'accepted',
        'pickup_otp': '7291',
        'pickup_address': 'Koramangala Hub, Bengaluru',
        'pickup_lat': 12.9352,
        'pickup_lng': 77.6245,
      },
    };
  }

  Future<Map<String, dynamic>> updateDeliveryStatus(
      String driverId, String orderId, String status) async {
    await _delay(ms: 400);
    return {'success': true, 'data': {'order_id': orderId, 'status': status}};
  }

  Future<Map<String, dynamic>> getEarnings(String driverId, String period) async {
    await _delay();
    return {
      'success': true,
      'data': {
        'period': period,
        'total_earnings': 14820.0,
        'total_obc': 1482,
        'deliveries': 124,
        'avg_per_delivery': 119.5,
        'weekly_breakdown': [
          {'week': 'W1', 'amount': 3240.0},
          {'week': 'W2', 'amount': 3890.0},
          {'week': 'W3', 'amount': 3620.0},
          {'week': 'W4', 'amount': 4070.0},
        ],
        'daily_breakdown': [
          {'day': 'Mon', 'amount': 580.0},
          {'day': 'Tue', 'amount': 820.0},
          {'day': 'Wed', 'amount': 640.0},
          {'day': 'Thu', 'amount': 920.0},
          {'day': 'Fri', 'amount': 760.0},
          {'day': 'Sat', 'amount': 1040.0},
          {'day': 'Sun', 'amount': 420.0},
        ],
      },
    };
  }

  Future<Map<String, dynamic>> getDeliveryHistory(String driverId, {int page = 1}) async {
    await _delay();
    return {
      'success': true,
      'data': {
        'page': page,
        'total': 124,
        'deliveries': List.generate(10, (i) => {
          'id': 'JD-DL-${4800 + i}',
          'recipient': ['Priya S.', 'Rahul V.', 'Ankit G.', 'Neha P.', 'Ravi K.',
            'Sonal M.', 'Kavya N.', 'Deepak S.', 'Arun R.', 'Sneha T.'][i],
          'status': i == 2 ? 'failed' : i == 4 ? 'returned' : 'delivered',
          'earnings': i == 2 ? 0.0 : 80.0 + (i * 12.0),
          'obc': i == 2 ? 0 : 8 + i,
          'date': '${18 - i} Jun 2025',
        }),
      },
    };
  }

  Future<Map<String, dynamic>> getProfile(String driverId) async {
    await _delay();
    return {
      'success': true,
      'data': {
        'id': driverId,
        'name': 'Rajesh Kumar',
        'phone': '+91 98765 43210',
        'email': 'rajesh@jdlogistics.in',
        'vehicle': 'Mahindra Bolero · KA 05 MN 7842',
        'license': 'KA-07-20190012345',
        'rating': 4.8,
        'total_deliveries': 1240,
        'obc_balance': 184,
        'joined': 'January 2023',
        'zone': 'Bengaluru Central',
      },
    };
  }

  Future<Map<String, dynamic>> getWallet(String driverId) async {
    await _delay();
    return {
      'success': true,
      'data': {
        'obc_balance': 184,
        'cash_balance': 1250.0,
        'total_obc_earned': 1482,
        'obc_redeemed': 1298,
        'transactions': List.generate(8, (i) => {
          'id': 'TXN-${9000 + i}',
          'type': i.isEven ? 'credit' : 'debit',
          'amount': i.isEven ? (50 + i * 10) : (100 + i * 15),
          'description': i.isEven ? 'Delivery reward' : 'OBC redeemed',
          'date': '${18 - i} Jun 2025',
          'obc': i.isEven,
        }),
      },
    };
  }

  static Future<void> _delay({int ms = 600}) =>
      Future.delayed(Duration(milliseconds: MockConfig.enabled ? ms : 0));
}
