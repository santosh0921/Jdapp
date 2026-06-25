import 'package:flutter/material.dart';
import 'package:jd_style_logistics/models/warehouse_model.dart';
import 'package:jd_style_logistics/services/warehouse_service.dart';
import 'package:jd_style_logistics/core/network/api_exception.dart';

enum WarehouseState { idle, loading, loaded, error }

class WarehouseProvider extends ChangeNotifier {
  WarehouseState _state = WarehouseState.idle;
  Map<String, dynamic> _stats = {};
  List<ParcelModel> _inventory = [];
  List<ParcelModel> _inbound = [];
  List<ParcelModel> _returns = [];
  Map<String, dynamic>? _lastScan;
  String? _error;

  WarehouseState get state => _state;
  Map<String, dynamic> get stats => _stats;
  List<ParcelModel> get inventory => List.unmodifiable(_inventory);
  List<ParcelModel> get inbound => List.unmodifiable(_inbound);
  List<ParcelModel> get returns => List.unmodifiable(_returns);
  Map<String, dynamic>? get lastScan => _lastScan;
  bool get isLoading => _state == WarehouseState.loading;
  String? get error => _error;

  int get pendingCount => (_stats['pending'] as int?) ?? 0;
  int get dispatchedCount => (_stats['dispatched'] as int?) ?? 0;
  int get returnsCount => (_stats['returns'] as int?) ?? 0;

  Future<void> loadStats() async {
    _setState(WarehouseState.loading);
    try {
      _stats = await WarehouseService.instance.getStats();
      _setState(WarehouseState.loaded);
    } catch (e) {
      _error = e is ApiException ? e.message : e.toString();
      _setState(WarehouseState.error);
    }
  }

  Future<void> loadInventory() async {
    _setState(WarehouseState.loading);
    try {
      _inventory = await WarehouseService.instance.getInventory();
      _setState(WarehouseState.loaded);
    } catch (e) {
      _error = e is ApiException ? e.message : e.toString();
      _setState(WarehouseState.error);
    }
  }

  Future<Map<String, dynamic>?> scanParcel(String trackingId, String action) async {
    try {
      _lastScan = await WarehouseService.instance.scan(trackingId, action);
      notifyListeners();
      return _lastScan;
    } catch (e) {
      _error = e is ApiException ? e.message : e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> dispatchParcel(String parcelId) async {
    try {
      await WarehouseService.instance.dispatch(parcelId);
      _inventory.removeWhere((p) => p.id == parcelId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e is ApiException ? e.message : e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> loadInbound() async {
    _setState(WarehouseState.loading);
    try {
      _inbound = await WarehouseService.instance.getInbound();
      _setState(WarehouseState.loaded);
    } catch (e) {
      _error = e is ApiException ? e.message : e.toString();
      _setState(WarehouseState.error);
    }
  }

  Future<void> loadReturns() async {
    _setState(WarehouseState.loading);
    try {
      _returns = await WarehouseService.instance.getReturns();
      _setState(WarehouseState.loaded);
    } catch (e) {
      _error = e is ApiException ? e.message : e.toString();
      _setState(WarehouseState.error);
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setState(WarehouseState s) {
    _state = s;
    notifyListeners();
  }
}
