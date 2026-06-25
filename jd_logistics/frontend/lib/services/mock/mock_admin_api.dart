import 'package:jd_style_logistics/core/constants/mock_config.dart';

class MockAdminApi {
  MockAdminApi._();
  static final MockAdminApi instance = MockAdminApi._();

  Future<Map<String, dynamic>> getDashboardStats() async {
    await _delay();
    return {
      'success': true,
      'data': {
        'total_shipments': 48291,
        'active_drivers': 342,
        'warehouses_online': 18,
        'revenue_today': 284750.0,
        'obc_circulating': 1284000,
        'pending_issues': 7,
        'shipment_trend': List.generate(7, (i) => {
          'day': ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][i],
          'value': 6200 + (i * 320) - (i == 5 || i == 6 ? 1200 : 0),
        }),
        'revenue_trend': List.generate(7, (i) => {
          'day': ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][i],
          'value': 38000.0 + (i * 4200),
        }),
        'top_zones': [
          {'zone': 'Bengaluru', 'shipments': 8241, 'pct': 0.17},
          {'zone': 'Mumbai', 'shipments': 7890, 'pct': 0.16},
          {'zone': 'Delhi NCR', 'shipments': 7120, 'pct': 0.15},
          {'zone': 'Hyderabad', 'shipments': 5840, 'pct': 0.12},
          {'zone': 'Chennai', 'shipments': 4920, 'pct': 0.10},
        ],
      },
    };
  }

  Future<Map<String, dynamic>> getUsers({String? role, String? query, int page = 1}) async {
    await _delay();
    return {
      'success': true,
      'data': {
        'total': 48291,
        'page': page,
        'users': List.generate(15, (i) => {
          'id': 'USR-${1000 + i}',
          'name': 'User ${i + 1}',
          'phone': '+91 9876${500000 + i}',
          'role': ['customer', 'driver', 'warehouse', 'admin'][i % 4],
          'status': i % 9 == 0 ? 'suspended' : 'active',
          'joined': '${(i % 28) + 1} Jan 2025',
          'shipments': i * 7,
        }),
      },
    };
  }

  Future<Map<String, dynamic>> getDrivers({String? status, int page = 1}) async {
    await _delay();
    return {
      'success': true,
      'data': {
        'total': 342,
        'active': 289,
        'page': page,
        'drivers': List.generate(10, (i) => {
          'id': 'DRV-${1000 + i}',
          'name': 'Driver ${i + 1}',
          'phone': '+91 9876${600000 + i}',
          'zone': ['Bengaluru', 'Mumbai', 'Delhi', 'Hyderabad', 'Chennai',
            'Pune', 'Kolkata', 'Jaipur', 'Ahmedabad', 'Surat'][i],
          'vehicle': 'KA 0${i} MN ${1000 + i}',
          'rating': 4.2 + (i % 8) * 0.1,
          'status': i == 3 ? 'offline' : i == 7 ? 'suspended' : 'active',
          'deliveries_today': i * 2,
          'total_deliveries': 200 + i * 40,
        }),
      },
    };
  }

  Future<Map<String, dynamic>> getWarehouses({int page = 1}) async {
    await _delay();
    return {
      'success': true,
      'data': {
        'total': 18,
        'page': page,
        'warehouses': List.generate(9, (i) => {
          'id': 'WH-${1000 + i}',
          'name': 'JD Hub — ${['Bengaluru East', 'Mumbai North', 'Delhi West', 'Hyderabad Central',
            'Chennai South', 'Pune Hub', 'Kolkata East', 'Jaipur West', 'Ahmedabad North'][i]}',
          'city': ['Bengaluru', 'Mumbai', 'Delhi', 'Hyderabad', 'Chennai', 'Pune', 'Kolkata', 'Jaipur', 'Ahmedabad'][i],
          'capacity_pct': 0.5 + (i % 5) * 0.1,
          'status': i == 4 ? 'maintenance' : 'active',
          'active_parcels': 1200 + i * 150,
          'manager': 'Manager ${i + 1}',
        }),
      },
    };
  }

  Future<Map<String, dynamic>> getFleet({int page = 1}) async {
    await _delay();
    return {
      'success': true,
      'data': {
        'total': 84,
        'active': 71,
        'page': page,
        'vehicles': List.generate(10, (i) => {
          'id': 'VH-${2000 + i}',
          'reg': 'KA 0${i} JD ${3000 + i}',
          'type': ['Bike', 'Auto', 'Tempo', 'Truck', 'Van'][i % 5],
          'driver': i % 3 == 0 ? null : 'Driver ${i + 1}',
          'status': i == 2 ? 'maintenance' : i == 5 ? 'idle' : 'active',
          'fuel': 0.3 + (i % 7) * 0.1,
          'last_location': ['Bengaluru', 'Mumbai', 'Delhi', 'Hyderabad', 'Chennai',
            'Pune', 'Kolkata', 'Jaipur', 'Ahmedabad', 'Surat'][i],
        }),
      },
    };
  }

  Future<Map<String, dynamic>> getShipmentsMonitor({String? status}) async {
    await _delay();
    return {
      'success': true,
      'data': {
        'live_count': 1842,
        'delayed': 34,
        'critical': 7,
        'shipments': List.generate(15, (i) => {
          'id': 'JD-IND-${4800 + i}',
          'origin': 'Bengaluru',
          'destination': ['Mumbai', 'Delhi', 'Chennai', 'Hyderabad', 'Pune',
            'Kolkata', 'Jaipur', 'Surat', 'Ahmedabad', 'Kochi',
            'Nagpur', 'Indore', 'Bhopal', 'Chandigarh', 'Lucknow'][i],
          'status': i < 10 ? 'in_transit' : i < 13 ? 'delayed' : 'critical',
          'eta': '${19 + (i % 5)} Jun 2025',
          'driver': 'Driver ${i + 1}',
          'weight': '${(0.5 + i * 0.4).toStringAsFixed(1)} kg',
          'lat': 12.9716 + (i * 0.05),
          'lng': 77.5946 + (i * 0.04),
        }),
      },
    };
  }

  Future<Map<String, dynamic>> getPayments({String? type, int page = 1}) async {
    await _delay();
    return {
      'success': true,
      'data': {
        'total_revenue': 8472910.0,
        'total_obc_issued': 1284000,
        'pending_payouts': 142800.0,
        'page': page,
        'transactions': List.generate(12, (i) => {
          'id': 'PAY-${9000 + i}',
          'type': i % 3 == 0 ? 'payout' : i % 3 == 1 ? 'shipment' : 'obc',
          'amount': (500.0 + i * 250),
          'party': i % 2 == 0 ? 'Customer ${i}' : 'Driver ${i}',
          'date': '${18 - i} Jun 2025',
          'status': i == 3 ? 'pending' : i == 7 ? 'failed' : 'success',
        }),
      },
    };
  }

  Future<Map<String, dynamic>> getAnalytics(String period) async {
    await _delay();
    return {
      'success': true,
      'data': {
        'period': period,
        'total_revenue': 28470000.0,
        'total_shipments': 48291,
        'active_users': 18420,
        'obc_issued': 4820000,
        'growth_revenue': 0.142,
        'growth_shipments': 0.087,
        'growth_users': 0.214,
        'by_category': [
          {'label': 'Standard', 'value': 0.48},
          {'label': 'Express', 'value': 0.31},
          {'label': 'Air', 'value': 0.12},
          {'label': 'Sea', 'value': 0.09},
        ],
        'monthly': List.generate(6, (i) => {
          'month': ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'][i],
          'revenue': 3800000.0 + (i * 420000),
          'shipments': 6800 + (i * 480),
        }),
      },
    };
  }

  Future<Map<String, dynamic>> getReports(String type, String period) async {
    await _delay();
    return {
      'success': true,
      'data': {
        'type': type,
        'period': period,
        'generated_at': '2025-06-18T10:00:00Z',
        'summary': 'Mock report data for $type - $period',
        'rows': List.generate(20, (i) => {'index': i + 1, 'value': 1000 + i * 50}),
      },
    };
  }

  Future<Map<String, dynamic>> updateUserStatus(String userId, String status) async {
    await _delay(ms: 400);
    return {'success': true, 'data': {'user_id': userId, 'status': status}};
  }

  Future<Map<String, dynamic>> getAuditLogs({String? category, String? query, int page = 1}) async {
    await _delay();
    return {
      'success': true,
      'data': {
        'total': 921,
        'page': page,
        'logs': List.generate(20, (i) => {
          'id': 'AL-${900 + i}',
          'actor': i % 5 == 0 ? 'system' : 'admin@jd.in',
          'action': ['Login', 'User updated', 'Shipment cancelled', 'Report exported', 'Config changed'][i % 5],
          'category': ['Auth', 'User', 'Shipment', 'System', 'Payment'][i % 5],
          'severity': i % 9 == 0 ? 'critical' : i % 4 == 0 ? 'warning' : 'info',
          'ip': i % 5 == 0 ? 'system' : '192.168.1.42',
          'timestamp': '2025-06-${18 - (i ~/ 5)}T${10 + i % 12}:${(i * 7) % 60}:00Z',
        }),
      },
    };
  }

  static Future<void> _delay({int ms = 600}) =>
      Future.delayed(Duration(milliseconds: MockConfig.enabled ? ms : 0));
}
