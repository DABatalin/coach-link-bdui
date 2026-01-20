import '../domain/models/app_notification.dart';
import '../domain/notifications_repository.dart';

class NotificationsRepositoryMock implements NotificationsRepository {
  final _notifications = [
    AppNotification(
      id: 'n-1',
      type: 'training_assigned',
      title: 'Новое задание от тренера',
      body: 'Тренер Сидорова М.А. назначил вам тренировку "Развивающий кросс" на завтра',
      data: const {'assignment_id': 'a-1'},
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
    AppNotification(
      id: 'n-2',
      type: 'report_submitted',
      title: 'Новый отчёт',
      body: 'Петров И.С. отправил отчёт по тренировке "Темповый бег 5 км"',
      data: const {'assignment_id': 'a-3'},
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
    ),
    AppNotification(
      id: 'n-3',
      type: 'connection_request',
      title: 'Заявка на привязку',
      body: 'Волкова Д.И. хочет стать вашим спортсменом',
      data: const {'request_id': 'req-1'},
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    AppNotification(
      id: 'n-4',
      type: 'connection_accepted',
      title: 'Заявка принята',
      body: 'Тренер Сидорова М.А. приняла вашу заявку',
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  @override
  Future<NotificationsResult> getNotifications({
    bool? isRead,
    int page = 1,
    int pageSize = 30,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    var list = _notifications;
    if (isRead != null) {
      list = list.where((n) => n.isRead == isRead).toList();
    }
    final unread = _notifications.where((n) => !n.isRead).length;
    return NotificationsResult(
      items: list,
      pagination: null,
      unreadCount: unread,
    );
  }

  @override
  Future<void> markRead({required String notificationId}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    // In a real mock we'd toggle isRead, but AppNotification is immutable.
    // For demo purposes this is enough — the list will reload.
  }

  @override
  Future<void> markAllRead() async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<void> registerDeviceToken({
    required String fcmToken,
    String? deviceInfo,
  }) async {
    // no-op in mock
  }
}
