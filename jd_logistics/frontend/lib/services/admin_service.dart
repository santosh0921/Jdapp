import 'package:jd_style_logistics/core/constants/mock_config.dart';
import 'package:jd_style_logistics/core/network/api_client.dart';
import 'package:jd_style_logistics/core/network/api_endpoints.dart';

class AdminService {
  AdminService._();
  static final AdminService instance = AdminService._();

  // ── Dashboard ─────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getDashboard() async {
    if (MockConfig.enabled) {
      await Future.delayed(const Duration(milliseconds: 700));
      return _mockDashboard;
    }
    try {
      final r = await ApiClient.instance.get(ApiEndpoints.adminDashboard);
      return r.data['data'] as Map<String, dynamic>;
    } catch (_) {
      MockConfig.isFallbackActive = true;
      return _mockDashboard;
    }
  }

  // ── Lists ─────────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getShipments({String? status, int page = 1}) async {
    if (MockConfig.enabled) {
      await Future.delayed(const Duration(milliseconds: 600));
      return _mockShipments;
    }
    try {
      final r = await ApiClient.instance.get(ApiEndpoints.adminShipments,
          params: {'status': status, 'page': page});
      return List<Map<String, dynamic>>.from(r.data['data'] as List);
    } catch (_) {
      MockConfig.isFallbackActive = true;
      return _mockShipments;
    }
  }

  Future<List<Map<String, dynamic>>> getCourierOrders({int page = 1}) async {
    if (MockConfig.enabled) {
      await Future.delayed(const Duration(milliseconds: 600));
      return _mockCourierOrders;
    }
    try {
      final r = await ApiClient.instance.get(ApiEndpoints.adminCourierOrders,
          params: {'page': page});
      return List<Map<String, dynamic>>.from(r.data['data'] as List);
    } catch (_) {
      MockConfig.isFallbackActive = true;
      return _mockCourierOrders;
    }
  }

  Future<List<Map<String, dynamic>>> getLogisticsOrders({int page = 1}) async {
    if (MockConfig.enabled) {
      await Future.delayed(const Duration(milliseconds: 600));
      return _mockLogisticsOrders;
    }
    try {
      final r = await ApiClient.instance.get(ApiEndpoints.adminLogisticsOrders,
          params: {'page': page});
      return List<Map<String, dynamic>>.from(r.data['data'] as List);
    } catch (_) {
      MockConfig.isFallbackActive = true;
      return _mockLogisticsOrders;
    }
  }

  Future<List<Map<String, dynamic>>> getUsers({String? role, int page = 1}) async {
    if (MockConfig.enabled) {
      await Future.delayed(const Duration(milliseconds: 500));
      return _mockUsers;
    }
    try {
      final r = await ApiClient.instance.get(ApiEndpoints.adminUsers,
          params: {'role': role, 'page': page});
      return List<Map<String, dynamic>>.from(r.data['data'] as List);
    } catch (_) {
      MockConfig.isFallbackActive = true;
      return _mockUsers;
    }
  }

  Future<List<Map<String, dynamic>>> getDrivers({String? status, int page = 1}) async {
    if (MockConfig.enabled) {
      await Future.delayed(const Duration(milliseconds: 500));
      return _mockDrivers;
    }
    try {
      final r = await ApiClient.instance.get(ApiEndpoints.adminDrivers,
          params: {'status': status, 'page': page});
      return List<Map<String, dynamic>>.from(r.data['data'] as List);
    } catch (_) {
      MockConfig.isFallbackActive = true;
      return _mockDrivers;
    }
  }

  Future<List<Map<String, dynamic>>> getWarehouses() async {
    if (MockConfig.enabled) {
      await Future.delayed(const Duration(milliseconds: 500));
      return _mockWarehouses;
    }
    try {
      final r = await ApiClient.instance.get(ApiEndpoints.adminWarehouses);
      return List<Map<String, dynamic>>.from(r.data['data'] as List);
    } catch (_) {
      MockConfig.isFallbackActive = true;
      return _mockWarehouses;
    }
  }

  Future<Map<String, dynamic>> getWarehouseDetails(String id) async {
    if (MockConfig.enabled) {
      await Future.delayed(const Duration(milliseconds: 400));
      return _mockWarehouses.firstWhere((w) => w['id'] == id,
          orElse: () => _mockWarehouses.first);
    }
    try {
      final r = await ApiClient.instance.get(ApiEndpoints.adminWarehouseById(id));
      return r.data['data'] as Map<String, dynamic>;
    } catch (_) {
      MockConfig.isFallbackActive = true;
      return _mockWarehouses.first;
    }
  }

  Future<List<Map<String, dynamic>>> getFleet() async {
    if (MockConfig.enabled) {
      await Future.delayed(const Duration(milliseconds: 500));
      return _mockFleet;
    }
    try {
      final r = await ApiClient.instance.get(ApiEndpoints.adminFleet);
      return List<Map<String, dynamic>>.from(r.data['data'] as List);
    } catch (_) {
      MockConfig.isFallbackActive = true;
      return _mockFleet;
    }
  }

  Future<Map<String, dynamic>> getAnalytics({String period = '30d'}) async {
    if (MockConfig.enabled) {
      await Future.delayed(const Duration(milliseconds: 700));
      return _mockAnalytics;
    }
    try {
      final r = await ApiClient.instance.get(ApiEndpoints.adminAnalytics,
          params: {'period': period});
      return r.data['data'] as Map<String, dynamic>;
    } catch (_) {
      MockConfig.isFallbackActive = true;
      return _mockAnalytics;
    }
  }

  Future<List<Map<String, dynamic>>> getAuditLogs({int page = 1}) async {
    if (MockConfig.enabled) {
      await Future.delayed(const Duration(milliseconds: 500));
      return _mockAuditLogs;
    }
    try {
      final r = await ApiClient.instance.get(ApiEndpoints.adminAuditLogs,
          params: {'page': page});
      return List<Map<String, dynamic>>.from(r.data['data'] as List);
    } catch (_) {
      MockConfig.isFallbackActive = true;
      return _mockAuditLogs;
    }
  }

  Future<Map<String, dynamic>> getSecurity() async {
    if (MockConfig.enabled) {
      await Future.delayed(const Duration(milliseconds: 500));
      return _mockSecurity;
    }
    try {
      final r = await ApiClient.instance.get(ApiEndpoints.adminSecurity);
      return r.data['data'] as Map<String, dynamic>;
    } catch (_) {
      MockConfig.isFallbackActive = true;
      return _mockSecurity;
    }
  }

  Future<Map<String, dynamic>> getReports({String type = 'monthly'}) async {
    if (MockConfig.enabled) {
      await Future.delayed(const Duration(milliseconds: 600));
      return _mockReports;
    }
    try {
      final r = await ApiClient.instance.get(ApiEndpoints.adminReports,
          params: {'type': type});
      return r.data['data'] as Map<String, dynamic>;
    } catch (_) {
      MockConfig.isFallbackActive = true;
      return _mockReports;
    }
  }

  Future<List<Map<String, dynamic>>> getPayments({int page = 1}) async {
    if (MockConfig.enabled) {
      await Future.delayed(const Duration(milliseconds: 500));
      return _mockPayments;
    }
    try {
      final r = await ApiClient.instance.get(ApiEndpoints.adminPayments,
          params: {'page': page});
      return List<Map<String, dynamic>>.from(r.data['data'] as List);
    } catch (_) {
      MockConfig.isFallbackActive = true;
      return _mockPayments;
    }
  }

  // ── Mock data ─────────────────────────────────────────────────────────────

  static final _mockDashboard = {
    'today_revenue': 284750.0,
    'revenue_trend': 14.2,
    'total_shipments_today': 1842,
    'shipments_trend': 8.7,
    'active_drivers': 342,
    'drivers_online': 284,
    'warehouses_total': 20,
    'warehouses_online': 18,
    'total_customers': 48291,
    'new_customers_today': 214,
    'obc_circulating': 1284000.0,
    'courier_orders_today': 1204,
    'logistics_orders_today': 638,
    'pending_customs': 23,
    'fleet_utilization': 0.84,
    'mtd_revenue': 28400000.0,
    'mtd_revenue_trend': 14.2,
    'mode_breakdown': {
      'road': 0.59,
      'air': 0.17,
      'sea': 0.10,
      'bike': 0.14,
    },
    'domestic_pct': 0.73,
    'international_pct': 0.27,
    'fleet_status': {
      'active': 71,
      'idle': 8,
      'maintenance': 5,
      'total': 84,
    },
    'live_alerts': [
      {'type': 'warning', 'message': 'WH-003 Mumbai North at 88% capacity'},
      {'type': 'info', 'message': '23 shipments pending customs clearance'},
      {'type': 'success', 'message': '342 drivers online — all zones covered'},
    ],
  };

  static final _mockShipments = List.generate(10, (i) => {
    'id': 'SHP${1000 + i}',
    'type': i % 2 == 0 ? 'courier' : 'logistics',
    'status': ['in_transit', 'delivered', 'pending', 'customs'][i % 4],
    'from': 'Mumbai',
    'to': 'Delhi',
    'amount': 1800.0 + i * 450,
    'created_at': '2024-06-0${(i % 9) + 1}',
  });

  static final _mockCourierOrders = List.generate(8, (i) => {
    'id': 'JDC-2024-${8800 + i}',
    'pickup': 'Address ${i + 1}, Mumbai',
    'drop': 'Address ${i + 1}, Delhi',
    'weight': '${(i + 1) * 0.5} kg',
    'status': ['confirmed', 'in_transit', 'delivered', 'pending'][i % 4],
    'amount': 320.0 + i * 180,
    'driver': 'Driver ${i + 1}',
  });

  static final _mockLogisticsOrders = List.generate(8, (i) => {
    'id': 'JDL-2024-${40 + i}',
    'shipment_type': ['export', 'import', 'domestic_bulk'][i % 3],
    'goods': 'Goods Category ${i + 1}',
    'from': 'City A',
    'to': 'City B',
    'weight_mt': '${(i + 1) * 5} MT',
    'status': ['in_transit', 'customs_clearance', 'delivered', 'pickup_scheduled'][i % 4],
    'amount': 50000.0 + i * 25000,
  });

  static final _mockUsers = List.generate(10, (i) => {
    'id': 'USR${1000 + i}',
    'name': 'User ${i + 1}',
    'phone': '+9198765${43200 + i}',
    'role': i % 3 == 0 ? 'logistics_customer' : 'courier_customer',
    'status': i % 5 == 0 ? 'inactive' : 'active',
    'orders': (i + 1) * 3,
    'joined': '2024-0${(i % 5) + 1}-01',
  });

  static final _mockDrivers = List.generate(10, (i) => {
    'id': 'DRV${1000 + i}',
    'name': 'Driver ${i + 1}',
    'phone': '+9199876${54300 + i}',
    'vehicle_type': i % 3 == 0 ? 'truck' : i % 3 == 1 ? 'mini_truck' : 'bike',
    'status': i % 4 == 0 ? 'offline' : 'online',
    'rating': 4.2 + (i % 8) * 0.1,
    'deliveries_today': i * 3,
    'earnings_today': i * 450.0,
  });

  static final _mockWarehouses = [
    {'id': 'WH001', 'name': 'Delhi West', 'code': 'WH-001', 'city': 'Delhi', 'capacity_pct': 0.61, 'status': 'active', 'total_sq_ft': 120000},
    {'id': 'WH003', 'name': 'Mumbai North', 'code': 'WH-003', 'city': 'Mumbai', 'capacity_pct': 0.88, 'status': 'active', 'total_sq_ft': 95000},
    {'id': 'WH007', 'name': 'Bengaluru East', 'code': 'WH-007', 'city': 'Bengaluru', 'capacity_pct': 0.74, 'status': 'active', 'total_sq_ft': 85000},
    {'id': 'WH009', 'name': 'Chennai South', 'code': 'WH-009', 'city': 'Chennai', 'capacity_pct': 0.40, 'status': 'maintenance', 'total_sq_ft': 75000},
    {'id': 'WH012', 'name': 'Hyderabad Central', 'code': 'WH-012', 'city': 'Hyderabad', 'capacity_pct': 0.55, 'status': 'active', 'total_sq_ft': 60000},
  ];

  static final _mockFleet = List.generate(12, (i) => {
    'id': 'VEH${100 + i}',
    'number': 'MH 04 AB ${1000 + i}',
    'type': ['truck', 'mini_truck', 'bike', 'container_truck'][i % 4],
    'driver': 'Driver ${i + 1}',
    'status': i % 5 == 0 ? 'maintenance' : i % 4 == 0 ? 'idle' : 'active',
    'location': 'Bengaluru, Karnataka',
    'last_updated': '5 min ago',
    'odometer_km': 45000 + i * 2000,
  });

  static final _mockAnalytics = {
    'revenue_mtd': 28400000.0,
    'revenue_ytd': 184200000.0,
    'shipments_mtd': 42810,
    'shipments_ytd': 284100,
    'avg_order_value': 3200.0,
    'customer_satisfaction': 4.7,
    'on_time_delivery': 0.94,
    'top_routes': [
      {'from': 'Mumbai', 'to': 'Delhi', 'volume': 8420},
      {'from': 'Chennai', 'to': 'Bengaluru', 'volume': 6840},
      {'from': 'Delhi', 'to': 'Kolkata', 'volume': 5200},
    ],
    'revenue_by_service': {
      'courier': 0.38,
      'logistics': 0.52,
      'warehouse': 0.10,
    },
  };

  static final _mockAuditLogs = List.generate(15, (i) => {
    'id': 'LOG${1000 + i}',
    'action': ['LOGIN', 'LOGOUT', 'ORDER_CREATE', 'PAYMENT', 'PROFILE_UPDATE'][i % 5],
    'user': 'admin@jdlogistics.in',
    'ip': '192.168.1.${100 + i}',
    'timestamp': '2024-06-0${(i % 9) + 1}T${(8 + i % 14).toString().padLeft(2, '0')}:30:00Z',
    'status': i % 6 == 0 ? 'failed' : 'success',
  });

  static final _mockSecurity = {
    'failed_logins_24h': 12,
    'active_sessions': 284,
    'suspicious_ips': 3,
    'api_calls_per_min': 842,
    'last_security_scan': '2024-06-01T02:00:00Z',
    'vulnerabilities': 0,
    'firewall_status': 'active',
    'ssl_expiry': '2025-12-31',
  };

  static final _mockReports = {
    'period': 'June 2024',
    'total_orders': 12840,
    'total_revenue': 28400000.0,
    'delivered': 11920,
    'cancelled': 284,
    'pending': 636,
    'top_category': 'Electronics',
    'growth_vs_last_month': 14.2,
    'customer_growth': 8.4,
    'driver_performance_avg': 4.6,
  };

  static final _mockPayments = List.generate(10, (i) => {
    'id': 'PAY${10000 + i}',
    'order_id': 'JDC-2024-${8800 + i}',
    'amount': 1200.0 + i * 380,
    'method': ['upi', 'card', 'net_banking', 'wallet'][i % 4],
    'status': i % 5 == 0 ? 'failed' : 'success',
    'date': '2024-06-0${(i % 9) + 1}',
    'customer': 'Customer ${i + 1}',
  });
}
