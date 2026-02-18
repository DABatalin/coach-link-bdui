import 'package:bloc_test/bloc_test.dart';
import 'package:coach_link/features/notifications/domain/models/app_notification.dart';
import 'package:coach_link/features/notifications/domain/notifications_repository.dart';
import 'package:coach_link/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mock_repositories.dart';
import '../../helpers/test_data.dart';

void main() {
  late MockNotificationsRepository notificationsRepo;

  setUp(() {
    notificationsRepo = MockNotificationsRepository();
  });

  NotificationsBloc buildBloc() =>
      NotificationsBloc(repository: notificationsRepo);

  NotificationsResult makeResult({
    List<AppNotification>? items,
    int unreadCount = 0,
  }) =>
      NotificationsResult(
        items: items ?? [],
        pagination: null,
        unreadCount: unreadCount,
      );

  group('NotificationsBloc', () {
    test('initial state is NotificationsInitial', () {
      expect(buildBloc().state, isA<NotificationsInitial>());
    });

    blocTest<NotificationsBloc, NotificationsState>(
      'emits [Loading, Loaded] with unreadCount on load',
      build: () {
        when(() => notificationsRepo.getNotifications()).thenAnswer(
          (_) async => makeResult(
            items: [
              makeNotification(id: 'n1', isRead: false),
              makeNotification(id: 'n2', isRead: true),
            ],
            unreadCount: 1,
          ),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(const NotificationsLoadRequested()),
      expect: () => [
        isA<NotificationsLoading>(),
        isA<NotificationsLoaded>()
            .having((s) => s.notifications.length, 'length', 2)
            .having((s) => s.unreadCount, 'unreadCount', 1),
      ],
    );

    blocTest<NotificationsBloc, NotificationsState>(
      'emits [Loading, Error] when repository throws',
      build: () {
        when(() => notificationsRepo.getNotifications())
            .thenThrow(Exception('Server error'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const NotificationsLoadRequested()),
      expect: () => [isA<NotificationsLoading>(), isA<NotificationsError>()],
    );

    blocTest<NotificationsBloc, NotificationsState>(
      'NotificationMarkedRead decrements unreadCount and marks item as read',
      build: () {
        when(() => notificationsRepo.markRead(notificationId: 'n1'))
            .thenAnswer((_) async {});
        return buildBloc();
      },
      seed: () => NotificationsLoaded(
        notifications: [
          makeNotification(id: 'n1', isRead: false),
          makeNotification(id: 'n2', isRead: false),
        ],
        unreadCount: 2,
      ),
      act: (bloc) => bloc.add(const NotificationMarkedRead('n1')),
      expect: () => [
        isA<NotificationsLoaded>()
            .having((s) => s.unreadCount, 'unreadCount', 1)
            .having(
              (s) => s.notifications.firstWhere((n) => n.id == 'n1').isRead,
              'n1 isRead',
              true,
            ),
      ],
    );

    blocTest<NotificationsBloc, NotificationsState>(
      'AllNotificationsMarkedRead calls markAllRead and reloads',
      build: () {
        when(() => notificationsRepo.markAllRead()).thenAnswer((_) async {});
        when(() => notificationsRepo.getNotifications()).thenAnswer(
          (_) async => makeResult(
            items: [makeNotification(id: 'n1', isRead: true)],
            unreadCount: 0,
          ),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AllNotificationsMarkedRead()),
      expect: () => [
        isA<NotificationsLoading>(),
        isA<NotificationsLoaded>()
            .having((s) => s.unreadCount, 'unreadCount', 0),
      ],
      verify: (_) =>
          verify(() => notificationsRepo.markAllRead()).called(1),
    );
  });
}
