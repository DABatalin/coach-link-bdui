import 'models/app_notification.dart';

class NotificationsResult {
  const NotificationsResult({
    required this.items,
    required this.pagination,
    required this.unreadCount,
  });

  final List<AppNotification> items;
  final dynamic pagination;
  final int unreadCount;
}

abstract class NotificationsRepository {
  Future<NotificationsResult> getNotifications({
    bool? isRead,
    int page = 1,
    int pageSize = 30,
  });

  Future<void> markRead({required String notificationId});

  Future<void> markAllRead();

  Future<void> registerDeviceToken({
    required String fcmToken,
    String? deviceInfo,
  });
}
