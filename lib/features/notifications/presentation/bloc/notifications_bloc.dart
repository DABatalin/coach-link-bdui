import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/api/api_exceptions.dart';
import '../../domain/models/app_notification.dart';
import '../../domain/notifications_repository.dart';

// Events
sealed class NotificationsEvent {
  const NotificationsEvent();
}

class NotificationsLoadRequested extends NotificationsEvent {
  const NotificationsLoadRequested();
}

class NotificationMarkedRead extends NotificationsEvent {
  const NotificationMarkedRead(this.notificationId);
  final String notificationId;
}

class AllNotificationsMarkedRead extends NotificationsEvent {
  const AllNotificationsMarkedRead();
}

// States
sealed class NotificationsState {
  const NotificationsState();
}

class NotificationsInitial extends NotificationsState {
  const NotificationsInitial();
}

class NotificationsLoading extends NotificationsState {
  const NotificationsLoading();
}

class NotificationsLoaded extends NotificationsState {
  const NotificationsLoaded({
    required this.notifications,
    required this.unreadCount,
  });

  final List<AppNotification> notifications;
  final int unreadCount;
}

class NotificationsError extends NotificationsState {
  const NotificationsError(this.message);
  final String message;
}

// Bloc
class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  NotificationsBloc({required NotificationsRepository repository})
      : _repository = repository,
        super(const NotificationsInitial()) {
    on<NotificationsLoadRequested>(_onLoad);
    on<NotificationMarkedRead>(_onMarkedRead);
    on<AllNotificationsMarkedRead>(_onAllMarkedRead);
  }

  final NotificationsRepository _repository;

  Future<void> _onLoad(
    NotificationsLoadRequested event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(const NotificationsLoading());
    try {
      final result = await _repository.getNotifications();
      emit(NotificationsLoaded(
        notifications: result.items,
        unreadCount: result.unreadCount,
      ));
    } on DioException catch (e) {
      final error = e.error;
      emit(NotificationsError(
        error is AppException
            ? error.message
            : 'Не удалось загрузить уведомления',
      ));
    } catch (_) {
      emit(const NotificationsError('Произошла ошибка'));
    }
  }

  Future<void> _onMarkedRead(
    NotificationMarkedRead event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      await _repository.markRead(notificationId: event.notificationId);
      final current = state;
      if (current is NotificationsLoaded) {
        final updated = current.notifications.map((n) {
          if (n.id != event.notificationId) return n;
          return AppNotification(
            id: n.id,
            type: n.type,
            title: n.title,
            body: n.body,
            data: n.data,
            isRead: true,
            createdAt: n.createdAt,
          );
        }).toList();
        emit(NotificationsLoaded(
          notifications: updated,
          unreadCount: current.unreadCount > 0 ? current.unreadCount - 1 : 0,
        ));
      }
    } catch (_) {}
  }

  Future<void> _onAllMarkedRead(
    AllNotificationsMarkedRead event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      await _repository.markAllRead();
      add(const NotificationsLoadRequested());
    } catch (_) {}
  }
}
