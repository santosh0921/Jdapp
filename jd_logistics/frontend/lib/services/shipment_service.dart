import 'package:jd_style_logistics/core/network/dio_client.dart';
import 'package:jd_style_logistics/core/constants/api_constants.dart';
import 'package:jd_style_logistics/models/shipment_model.dart';

class ShipmentService {
  ShipmentService._();
  static final ShipmentService instance = ShipmentService._();

  Future<List<ShipmentModel>> getShipments() async {
    final r = await DioClient.instance.get(ApiConstants.shipments);
    final list = (r.data['data'] as List<dynamic>?) ?? [];
    return list.map((e) => ShipmentModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ShipmentModel> getShipmentById(String id) async {
    final r = await DioClient.instance.get(ApiConstants.shipmentById.replaceFirst('{id}', id));
    return ShipmentModel.fromJson(r.data['data'] as Map<String, dynamic>);
  }

  Future<ShipmentModel> bookShipment(Map<String, dynamic> data) async {
    final r = await DioClient.instance.post(ApiConstants.shipments, data: data);
    return ShipmentModel.fromJson(r.data['data'] as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> getQuote(Map<String, dynamic> data) async {
    final r = await DioClient.instance.post(ApiConstants.shipmentQuote, data: data);
    return r.data['data'] as Map<String, dynamic>? ?? {};
  }

  Future<bool> cancelShipment(String id) async {
    await DioClient.instance.post(ApiConstants.cancelShipment.replaceFirst('{id}', id));
    return true;
  }
}
