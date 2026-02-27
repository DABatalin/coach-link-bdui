import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../core/di/repository_providers.dart';
import '../../../../core/navigation/routes.dart';
import '../bloc/my_coach_bloc.dart';

class MyCoachScreen extends ConsumerWidget {
  const MyCoachScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BlocProvider(
      create: (_) => MyCoachBloc(
        repository: ref.read(connectionsRepositoryProvider),
      )..add(const MyCoachLoadRequested()),
      child: const _MyCoachView(),
    );
  }
}

class _MyCoachView extends StatelessWidget {
  const _MyCoachView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('connections.myCoach'.tr())),
      body: BlocBuilder<MyCoachBloc, MyCoachState>(
        builder: (context, state) {
          return switch (state) {
            MyCoachInitial() || MyCoachLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
            MyCoachConnected(:final coach) => ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const SizedBox(height: 32),
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.1),
                    child: Text(
                      coach.fullName.isNotEmpty ? coach.fullName[0] : '?',
                      style: TextStyle(
                        fontSize: 36,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    coach.fullName,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '@${coach.login}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Привязан с ${_formatDate(coach.connectedAt)}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            MyCoachPending(:final request) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.hourglass_top,
                        size: 64, color: Colors.orange),
                    const SizedBox(height: 16),
                    Text(
                      'Заявка отправлена',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text('Тренер: ${request.coach.fullName}'),
                    const Text('Ожидание ответа...'),
                  ],
                ),
              ),
            MyCoachNone() => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.person_search,
                        size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text('connections.noCoach'.tr()),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () =>
                          context.go(AppRoutes.athleteFindCoach),
                      icon: const Icon(Icons.search),
                      label: Text('connections.findCoach'.tr()),
                    ),
                  ],
                ),
              ),
            MyCoachError(:final message) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context
                          .read<MyCoachBloc>()
                          .add(const MyCoachLoadRequested()),
                      child: Text('common.retry'.tr()),
                    ),
                  ],
                ),
              ),
          };
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
}
