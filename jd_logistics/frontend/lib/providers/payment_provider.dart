import 'package:flutter/material.dart';
import 'package:jd_style_logistics/models/payment_model.dart';
import 'package:jd_style_logistics/services/payment_service.dart';
import 'package:jd_style_logistics/core/network/api_exception.dart';

enum PaymentState { idle, loading, loaded, error }

class PaymentProvider extends ChangeNotifier {
  PaymentState _state = PaymentState.idle;
  List<PaymentMethodModel> _methods = [];
  List<PaymentTransactionModel> _history = [];
  WalletModel? _wallet;
  String? _error;

  PaymentState get state => _state;
  List<PaymentMethodModel> get methods => List.unmodifiable(_methods);
  List<PaymentTransactionModel> get history => List.unmodifiable(_history);
  WalletModel? get wallet => _wallet;
  double get balance => _wallet?.balance ?? 0;
  bool get isLoading => _state == PaymentState.loading;
  String? get error => _error;

  Future<void> loadWallet() async {
    _setState(PaymentState.loading);
    try {
      _wallet = await PaymentService.instance.getWallet();
      _setState(PaymentState.loaded);
    } catch (e) {
      _error = e is ApiException ? e.message : e.toString();
      _setState(PaymentState.error);
    }
  }

  Future<bool> addMoney(double amount, String method) async {
    _setState(PaymentState.loading);
    try {
      _wallet = await PaymentService.instance.addMoney(amount, method);
      _setState(PaymentState.loaded);
      return true;
    } catch (e) {
      _error = e is ApiException ? e.message : e.toString();
      _setState(PaymentState.error);
      return false;
    }
  }

  Future<bool> withdraw(double amount) async {
    _setState(PaymentState.loading);
    try {
      _wallet = await PaymentService.instance.withdraw(amount);
      _setState(PaymentState.loaded);
      return true;
    } catch (e) {
      _error = e is ApiException ? e.message : e.toString();
      _setState(PaymentState.error);
      return false;
    }
  }

  Future<void> loadHistory() async {
    _setState(PaymentState.loading);
    try {
      _history = await PaymentService.instance.getHistory();
      _setState(PaymentState.loaded);
    } catch (e) {
      _error = e is ApiException ? e.message : e.toString();
      _setState(PaymentState.error);
    }
  }

  Future<void> loadPaymentMethods() async {
    _setState(PaymentState.loading);
    try {
      _methods = await PaymentService.instance.getMethods();
      _setState(PaymentState.loaded);
    } catch (e) {
      _error = e is ApiException ? e.message : e.toString();
      _setState(PaymentState.error);
    }
  }

  Future<bool> topupWallet(double amount, String method) async {
    return addMoney(amount, method);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setState(PaymentState s) {
    _state = s;
    notifyListeners();
  }
}
