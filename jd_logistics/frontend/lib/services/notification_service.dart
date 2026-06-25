import 'package:jd_style_logistics/core/network/api_client.dart';
import 'package:jd_style_logistics/core/network/api_endpoints.dart';
import 'package:jd_style_logistics/models/notification_model.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  Future<List<NotificationModel>> getNotifications() async {
    try {
      final r = await ApiClient.instance.get(ApiEndpoints.notifications);
      final list = (r.data['data'] as List<dynamic>?) ?? [];
      return list
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> markRead(String id) async {
    try {
      await ApiClient.instance.patch(ApiEndpoints.markRead(id));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> markAllRead() async {
    try {
      await ApiClient.instance.post(ApiEndpoints.markAllRead);
      return true;
    } catch (_) {
      return false;
    }
  }
}
