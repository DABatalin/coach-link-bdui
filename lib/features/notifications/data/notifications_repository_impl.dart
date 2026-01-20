import 'package:dio/dio.dart';

import '../domain/models/app_notification.dart';
import '../domain/notifications_repository.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  NotificationsRepositoryImpl(this._dio);
  final Dio _dio;

  @override
  Future<NotificationsResult> getNotifications({
    bool? isRead,
    int page = 1,
    int pageSize = 30,
  }) async {
    final response =
        await _dio.get('/api/v1/notifications', queryParameters: {
      if (isRead != null) 'is_read': isRead,
      'page': page,
      'page_size': pageSize,
    });
    final data = response.data as Map<String, dynamic>;
    return NotificationsResult(
      items: (data['items'] as List)
          .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: data['pagination'],
      unreadCount: data['unread_count'] as int,
    );
  }

  @override
  Future<void> markRead({required String notificationId}) async {
    await _dio.put('/api/v1/notifications/$notificationId/read');
  }

  @override
  Future<void> markAllRead() async {
    await _dio.put('/api/v1/notifications/read-all');
  }

  @override
  Future<void> registerDeviceToken({
    required String fcmToken,
    String? deviceInfo,
  }) async {
    await _dio.post('/api/v1/notifications/device-token', data: {
      'fcm_token': fcmToken,
      if (deviceInfo != null) 'device_info': deviceInfo,
    });
  }
}
