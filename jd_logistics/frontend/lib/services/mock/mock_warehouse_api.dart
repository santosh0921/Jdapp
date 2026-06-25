import 'package:jd_style_logistics/core/constants/mock_config.dart';

class MockWarehouseApi {
  MockWarehouseApi._();
  static final MockWarehouseApi instance = MockWarehouseApi._();

  Future<Map<String, dynamic>> getHomeStats(String warehouseId) async {
    await _delay();
    return {
      'success': true,
      'data': {
        'total_parcels': 3241,
        'inbound_today': 127,
        'outbound_today': 94,
        'pending_scan': 18,
        'returns_today': 12,
        'capacity_used': 0.74,
        'alerts': [
          {'type': 'low_stock', 'sku': 'SKU-0021', 'message': 'Below threshold'},
          {'type': 'overdue', 'id': 'JD-IND-4091', 'message': 'Dispatch overdue 2h'},
        ],
      },
    };
  }

  Future<Map<String, dynamic>> getInventory(String warehouseId, {String? query}) async {
    await _delay();
    final items = List.generate(20, (i) => {
      'sku': 'SKU-${1000 + i}',
      'name': ['Electronics', 'Apparel', 'FMCG', 'Books', 'Pharma',
        'Furniture', 'Toys', 'Sports', 'Automotive', 'Garden',
        'Office', 'Kitchen', 'Baby', 'Beauty', 'Food',
        'Jewelry', 'Pet', 'Music', 'Art', 'Tools'][i],
      'quantity': 50 + (i * 17),
      'zone': 'Zone ${String.fromCharCode(65 + (i % 5))}',
      'last_updated': '${18 - (i % 7)} Jun 2025',
      'status': i % 7 == 0 ? 'low_stock' : 'ok',
    });
    return {'success': true, 'data': items};
  }

  Future<Map<String, dynamic>> scanParcel(String barcode) async {
    await _delay(ms: 800);
    return {
      'success': true,
      'data': {
        'id': barcode.isEmpty ? 'JD-IND-4822' : barcode,
        'status': 'inbound',
        'sender': 'Flipkart Warehouse, Bengaluru',
        'recipient': 'Priya Sharma, 12 MG Road, Bengaluru',
        'weight': '1.4 kg',
        'dimensions': '30×20×15 cm',
        'zone': 'Zone B · Rack 14',
        'action_required': 'shelve',
      },
    };
  }

  Future<Map<String, dynamic>> getDispatchQueue(String warehouseId) async {
    await _delay();
    return {
      'success': true,
      'data': List.generate(12, (i) => {
        'id': 'JD-IND-${4800 + i}',
        'recipient': 'Recipient ${i + 1}',
        'destination': ['Mumbai', 'Delhi', 'Chennai', 'Hyderabad', 'Pune',
          'Kolkata', 'Ahmedabad', 'Jaipur', 'Surat', 'Kochi',
          'Nagpur', 'Indore'][i],
        'weight': '${(0.5 + i * 0.3).toStringAsFixed(1)} kg',
        'ready': i % 3 != 2,
        'carrier': i % 2 == 0 ? 'BlueDart' : 'Delhivery',
        'due': '${i < 6 ? "Today" : "Tomorrow"} ${14 + i}:00',
      }),
    };
  }

  Future<Map<String, dynamic>> getInbound(String warehouseId) async {
    await _delay();
    return {
      'success': true,
      'data': List.generate(8, (i) => {
        'id': 'IN-${5000 + i}',
        'carrier': i % 2 == 0 ? 'Delhivery' : 'Ekart',
        'parcels': 10 + (i * 3),
        'weight': '${(5.0 + i * 1.2).toStringAsFixed(1)} kg',
        'eta': '${10 + i}:${i % 2 == 0 ? "00" : "30"} AM',
        'status': i < 3 ? 'arrived' : 'in_transit',
        'origin': ['Delhi', 'Mumbai', 'Chennai', 'Kolkata', 'Pune', 'Surat', 'Jaipur', 'Indore'][i],
      }),
    };
  }

  Future<Map<String, dynamic>> getOutbound(String warehouseId) async {
    await _delay();
    return {
      'success': true,
      'data': List.generate(6, (i) => {
        'id': 'OUT-${6000 + i}',
        'carrier': ['BlueDart', 'DTDC', 'Delhivery', 'FedEx', 'Xpressbees', 'Ecom'][i],
        'parcels': 15 + (i * 5),
        'weight': '${(10.0 + i * 2.5).toStringAsFixed(1)} kg',
        'departure': '${14 + i}:00',
        'status': i < 2 ? 'loaded' : 'pending',
        'destination': ['Mumbai', 'Delhi', 'Chennai', 'Hyderabad', 'Pune', 'Kolkata'][i],
      }),
    };
  }

  Future<Map<String, dynamic>> getReturns(String warehouseId) async {
    await _delay();
    return {
      'success': true,
      'data': List.generate(10, (i) => {
        'id': 'RET-${3000 + i}',
        'original_order': 'JD-IND-${4000 + i}',
        'reason': ['Customer refused', 'Wrong item', 'Damaged', 'Not home',
          'Address issue', 'Quality issue', 'Late delivery', 'Changed mind',
          'Duplicate order', 'Out of stock'][i],
        'received_date': '${16 - i} Jun 2025',
        'status': i < 4 ? 'processed' : i < 7 ? 'inspecting' : 'pending',
        'refund_amount': (200.0 + i * 50).toStringAsFixed(0),
      }),
    };
  }

  Future<Map<String, dynamic>> getReports(String warehouseId, String period) async {
    await _delay();
    return {
      'success': true,
      'data': {
        'period': period,
        'total_processed': 2841,
        'inbound': 1420,
        'outbound': 1280,
        'returns': 141,
        'accuracy_rate': 0.987,
        'avg_dwell_time': '1.4 days',
        'chart_data': List.generate(7, (i) => {
          'label': ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][i],
          'inbound': 180 + (i * 12),
          'outbound': 160 + (i * 10),
        }),
      },
    };
  }

  static Future<void> _delay({int ms = 600}) =>
      Future.delayed(Duration(milliseconds: MockConfig.enabled ? ms : 0));
}
