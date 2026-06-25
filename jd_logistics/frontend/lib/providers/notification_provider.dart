import 'package:flutter/material.dart';
import 'package:jd_style_logistics/models/notification_model.dart';
import 'package:jd_style_logistics/services/notification_service.dart';
import 'package:jd_style_logistics/core/network/api_exception.dart';

class NotificationProvider extends ChangeNotifier {
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _error;

  List<NotificationModel> get notifications => List.unmodifiable(_notifications);
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    try {
      _notifications = await NotificationService.instance.getNotifications();
    } catch (e) {
      _error = e is ApiException ? e.message : e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markRead(String id) async {
    try {
      await NotificationService.instance.markRead(id);
      _notifications = _notifications
          .map((n) => n.id == id ? n.copyWith(isRead: true) : n)
          .toList();
      notifyListeners();
    } catch (e) {
      _error = e is ApiException ? e.message : e.toString();
      notifyListeners();
    }
  }

  Future<void> markAllRead() async {
    try {
      await NotificationService.instance.markAllRead();
      _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
      notifyListeners();
    } catch (e) {
      _error = e is ApiException ? e.message : e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
