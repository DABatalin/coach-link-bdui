import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/repository_providers.dart';
import '../bloc/notifications_bloc.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BlocProvider(
      create: (_) => NotificationsBloc(
        repository: ref.read(notificationsRepositoryProvider),
      )..add(const NotificationsLoadRequested()),
      child: const _NotificationsView(),
    );
  }
}

class _NotificationsView extends StatelessWidget {
  const _NotificationsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Уведомления'),
        actions: [
          BlocBuilder<NotificationsBloc, NotificationsState>(
            builder: (context, state) {
              if (state is NotificationsLoaded && state.unreadCount > 0) {
                return TextButton(
                  onPressed: () => context
                      .read<NotificationsBloc>()
                      .add(const AllNotificationsMarkedRead()),
                  child: const Text('Прочитать все',
                      style: TextStyle(color: Colors.white)),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationsBloc, NotificationsState>(
        builder: (context, state) {
          return switch (state) {
            NotificationsInitial() ||
            NotificationsLoading() =>
              const Center(child: CircularProgressIndicator()),
            NotificationsLoaded(:final notifications) =>
              notifications.isEmpty
                  ? const Center(child: Text('Нет уведомлений'))
                  : ListView.builder(
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final n = notifications[index];
                        return ListTile(
                          leading: Icon(
                            _iconForType(n.type),
                            color: n.isRead ? Colors.grey : Colors.blue,
                          ),
                          title: Text(
                            n.title,
                            style: TextStyle(
                              fontWeight:
                                  n.isRead ? FontWeight.normal : FontWeight.bold,
                            ),
                          ),
                          subtitle: n.body != null
                              ? Text(n.body!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis)
                              : null,
                          trailing: Text(
                            _formatTime(n.createdAt),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          onTap: () {
                            if (!n.isRead) {
                              context
                                  .read<NotificationsBloc>()
                                  .add(NotificationMarkedRead(n.id));
                            }
                          },
                        );
                      },
                    ),
            NotificationsError(:final message) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context
                          .read<NotificationsBloc>()
                          .add(const NotificationsLoadRequested()),
                      child: const Text('Повторить'),
                    ),
                  ],
                ),
              ),
          };
        },
      ),
    );
  }

  IconData _iconForType(String type) {
    return switch (type) {
      'connection_request' => Icons.person_add,
      'connection_accepted' => Icons.check_circle,
      'connection_rejected' => Icons.cancel,
      'training_assigned' => Icons.assignment,
      'training_deleted' => Icons.delete,
      'report_submitted' => Icons.description,
      'group_added' => Icons.group_add,
      'group_removed' => Icons.group_remove,
      _ => Icons.notifications,
    };
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} мин';
    if (diff.inHours < 24) return '${diff.inHours} ч';
    if (diff.inDays < 7) return '${diff.inDays} дн';
    return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}';
  }
}
