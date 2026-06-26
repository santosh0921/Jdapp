import 'package:jd_style_logistics/core/network/api_client.dart';
import 'package:jd_style_logistics/core/network/api_endpoints.dart';
import 'package:jd_style_logistics/models/shipment_model.dart';

class ShipmentService {
  ShipmentService._();
  static final ShipmentService instance = ShipmentService._();

  Future<List<ShipmentModel>> getShipments() async {
    try {
      final r = await ApiClient.instance.get(ApiEndpoints.courierOrders);
      final list = (r.data['data'] as List<dynamic>?) ?? [];
      return list
          .map((e) => ShipmentModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<ShipmentModel> getShipmentById(String id) async {
    final r = await ApiClient.instance.get(ApiEndpoints.courierOrderById(id));
    return ShipmentModel.fromJson(r.data['data'] as Map<String, dynamic>);
  }

  Future<ShipmentModel> bookShipment(Map<String, dynamic> data) async {
    final r = await ApiClient.instance.post(ApiEndpoints.courierOrders, data: data);
    return ShipmentModel.fromJson(r.data['data'] as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> getQuote(Map<String, dynamic> data) async {
    final r = await ApiClient.instance.post(ApiEndpoints.courierEstimate, data: data);
    return r.data['data'] as Map<String, dynamic>? ?? {};
  }

  Future<bool> cancelShipment(String id) async {
    await ApiClient.instance.post(ApiEndpoints.cancelCourierOrder(id));
    return true;
  }
}
