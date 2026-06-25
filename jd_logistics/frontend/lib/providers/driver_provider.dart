import 'package:flutter/material.dart';
import 'package:jd_style_logistics/models/driver_model.dart';
import 'package:jd_style_logistics/models/shipment_model.dart';
import 'package:jd_style_logistics/services/driver_service.dart';
import 'package:jd_style_logistics/core/network/api_exception.dart';

enum DriverState { idle, loading, loaded, error }

class DriverProvider extends ChangeNotifier {
  DriverState _state = DriverState.idle;
  DriverModel? _driver;
  List<ShipmentModel> _availableOrders = [];
  ShipmentModel? _activeDelivery;
  List<EarningModel> _earnings = [];
  String? _error;

  DriverState get state => _state;
  DriverModel? get driver => _driver;
  List<ShipmentModel> get availableOrders => List.unmodifiable(_availableOrders);
  ShipmentModel? get activeDelivery => _activeDelivery;
  List<EarningModel> get earnings => List.unmodifiable(_earnings);
  bool get isOnline => _driver?.isOnline ?? false;
  bool get isLoading => _state == DriverState.loading;
  String? get error => _error;

  Future<void> loadProfile() async {
    _setState(DriverState.loading);
    try {
      _driver = await DriverService.instance.getProfile();
      _setState(DriverState.loaded);
    } catch (e) {
      _error = e is ApiException ? e.message : e.toString();
      _setState(DriverState.error);
    }
  }

  Future<void> toggleOnlineStatus() async {
    final newStatus = !isOnline;
    try {
      _driver = await DriverService.instance.toggleOnline(newStatus);
      notifyListeners();
    } catch (e) {
      _error = e is ApiException ? e.message : e.toString();
      notifyListeners();
    }
  }

  Future<void> loadAvailableOrders() async {
    _setState(DriverState.loading);
    try {
      _availableOrders = await DriverService.instance.getAvailableOrders();
      _setState(DriverState.loaded);
    } catch (e) {
      _error = e is ApiException ? e.message : e.toString();
      _setState(DriverState.error);
    }
  }

  Future<bool> acceptOrder(String orderId) async {
    try {
      await DriverService.instance.acceptOrder(orderId);
      final order = _availableOrders.firstWhere((o) => o.id == orderId);
      _activeDelivery = order;
      _availableOrders.removeWhere((o) => o.id == orderId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e is ApiException ? e.message : e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> rejectOrder(String orderId) async {
    try {
      await DriverService.instance.rejectOrder(orderId);
      _availableOrders.removeWhere((o) => o.id == orderId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e is ApiException ? e.message : e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> updateLocation(double lat, double lng) async {
    try {
      await DriverService.instance.updateLocation(lat, lng);
    } catch (_) {}
  }

  Future<void> loadEarnings() async {
    _setState(DriverState.loading);
    try {
      _earnings = await DriverService.instance.getEarnings();
      _setState(DriverState.loaded);
    } catch (e) {
      _error = e is ApiException ? e.message : e.toString();
      _setState(DriverState.error);
    }
  }

  void clearActiveDelivery() {
    _activeDelivery = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setState(DriverState s) {
    _state = s;
    notifyListeners();
  }
}
