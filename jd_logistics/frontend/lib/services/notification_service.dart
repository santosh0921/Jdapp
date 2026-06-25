import 'package:jd_style_logistics/core/constants/mock_config.dart';
import 'package:jd_style_logistics/core/network/api_client.dart';
import 'package:jd_style_logistics/core/network/api_endpoints.dart';
import 'package:jd_style_logistics/models/notification_model.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  Future<List<NotificationModel>> getNotifications() async {
    if (MockConfig.enabled) {
      await Future.delayed(const Duration(milliseconds: 400));
      return _mockNotifications;
    }
    try {
      final r = await ApiClient.instance.get(ApiEndpoints.notifications);
      final list = (r.data['data'] as List<dynamic>?) ?? [];
      return list
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      MockConfig.isFallbackActive = true;
      return _mockNotifications;
    }
  }

  Future<bool> markRead(String id) async {
    if (MockConfig.enabled) {
      await Future.delayed(const Duration(milliseconds: 200));
      return true;
    }
    try {
      await ApiClient.instance.patch(ApiEndpoints.markRead(id));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> markAllRead() async {
    if (MockConfig.enabled) {
      await Future.delayed(const Duration(milliseconds: 300));
      return true;
    }
    try {
      await ApiClient.instance.post(ApiEndpoints.markAllRead);
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Mock data ─────────────────────────────────────────────────────────────

  static final _mockNotifications = [
    NotificationModel(
      id: 'N001',
      title: 'Shipment In Transit',
      body: 'Your shipment JDC-2024-8821 is on the way to Kolkata.',
      type: 'shipment',
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
    NotificationModel(
      id: 'N002',
      title: 'Payment Successful',
      body: '₹1,952 paid for order JDC-2024-8821 via UPI.',
      type: 'payment',
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    NotificationModel(
      id: 'N003',
      title: 'Logistics Order Confirmed',
      body: 'Export order JDL-2024-0042 confirmed. ETA: 12 June.',
      type: 'logistics',
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    NotificationModel(
      id: 'N004',
      title: 'Driver Assigned',
      body: 'Rajesh Kumar (MH 04 AB 1234) will pick up your package.',
      type: 'driver',
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
    ),
    NotificationModel(
      id: 'N005',
      title: 'Customs Clearance',
      body: 'Import shipment JDL-2024-0031 is under customs review.',
      type: 'customs',
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];
}
