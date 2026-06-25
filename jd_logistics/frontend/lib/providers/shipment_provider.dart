import 'package:flutter/material.dart';
import 'package:jd_style_logistics/models/shipment_model.dart';
import 'package:jd_style_logistics/services/shipment_service.dart';
import 'package:jd_style_logistics/services/tracking_service.dart';
import 'package:jd_style_logistics/core/network/api_exception.dart';

enum ShipmentState { idle, loading, loaded, error }

class ShipmentProvider extends ChangeNotifier {
  ShipmentState _state = ShipmentState.idle;
  List<ShipmentModel> _shipments = [];
  ShipmentModel? _activeShipment;
  List<TrackingEventModel> _trackingHistory = [];
  Map<String, dynamic> _quote = {};
  String? _error;

  ShipmentState get state => _state;
  List<ShipmentModel> get shipments => List.unmodifiable(_shipments);
  ShipmentModel? get activeShipment => _activeShipment;
  List<TrackingEventModel> get trackingHistory => List.unmodifiable(_trackingHistory);
  Map<String, dynamic> get quote => _quote;
  String? get error => _error;
  bool get isLoading => _state == ShipmentState.loading;

  List<ShipmentModel> get activeShipments =>
      _shipments.where((s) => !['delivered', 'cancelled'].contains(s.status)).toList();
  List<ShipmentModel> get completedShipments =>
      _shipments.where((s) => s.status == 'delivered').toList();
  List<ShipmentModel> get cancelledShipments =>
      _shipments.where((s) => s.status == 'cancelled').toList();

  Future<void> loadShipments() async {
    _setState(ShipmentState.loading);
    try {
      _shipments = await ShipmentService.instance.getShipments();
      _setState(ShipmentState.loaded);
    } catch (e) {
      _error = e is ApiException ? e.message : e.toString();
      _setState(ShipmentState.error);
    }
  }

  Future<bool> bookShipment(Map<String, dynamic> data) async {
    _setState(ShipmentState.loading);
    try {
      final shipment = await ShipmentService.instance.bookShipment(data);
      _shipments = [shipment, ..._shipments];
      _activeShipment = shipment;
      _setState(ShipmentState.loaded);
      return true;
    } catch (e) {
      _error = e is ApiException ? e.message : e.toString();
      _setState(ShipmentState.error);
      return false;
    }
  }

  Future<bool> getQuote(Map<String, dynamic> data) async {
    _setState(ShipmentState.loading);
    try {
      _quote = await ShipmentService.instance.getQuote(data);
      _setState(ShipmentState.loaded);
      return true;
    } catch (e) {
      _error = e is ApiException ? e.message : e.toString();
      _setState(ShipmentState.error);
      return false;
    }
  }

  Future<void> trackShipment(String trackingId) async {
    _setState(ShipmentState.loading);
    try {
      _trackingHistory = await TrackingService.instance.getEvents(trackingId);
      _setState(ShipmentState.loaded);
    } catch (e) {
      _error = e is ApiException ? e.message : e.toString();
      _setState(ShipmentState.error);
    }
  }

  Future<bool> cancelShipment(String id) async {
    try {
      await ShipmentService.instance.cancelShipment(id);
      _shipments = _shipments
          .map((s) => s.id == id
              ? ShipmentModel(
                  id: s.id,
                  trackingId: s.trackingId,
                  status: 'cancelled',
                  pickupAddress: s.pickupAddress,
                  deliveryAddress: s.deliveryAddress,
                  packageType: s.packageType,
                  weight: s.weight,
                  amount: s.amount,
                  createdAt: s.createdAt,
                )
              : s)
          .toList();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e is ApiException ? e.message : e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setState(ShipmentState s) {
    _state = s;
    notifyListeners();
  }
}
