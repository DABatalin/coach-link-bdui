import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/repository_providers.dart';
import '../../../../core/di/auth_providers.dart';
import '../../../../core/auth/auth_state.dart';
import '../../../../core/navigation/routes.dart';
import '../bloc/dashboard_bloc.dart';

class AthleteDashboardScreen extends ConsumerWidget {
  const AthleteDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authManager = ref.read(authManagerProvider);
    final authState = authManager.currentState;
    final fullName =
        authState is Authenticated ? authState.fullName : 'Спортсмен';

    return BlocProvider(
      create: (_) => DashboardBloc(
        role: 'athlete',
        connectionsRepository: ref.read(connectionsRepositoryProvider),
        trainingRepository: ref.read(trainingRepositoryProvider),
      )..add(const DashboardLoadRequested()),
      child: _AthleteDashboardView(fullName: fullName),
    );
  }
}

class _AthleteDashboardView extends StatelessWidget {
  const _AthleteDashboardView({required this.fullName});
  final String fullName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CoachLink'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.go(AppRoutes.notifications),
          ),
        ],
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          return switch (state) {
            DashboardInitial() || DashboardLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
            AthleteDashboardLoaded(
              :final upcomingAssignments,
              :final hasCoach,
              :final coachName,
            ) =>
              RefreshIndicator(
                onRefresh: () async => context
                    .read<DashboardBloc>()
                    .add(const DashboardLoadRequested()),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      'Привет, $fullName!',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),

                    // Coach info card
                    Card(
                      child: ListTile(
                        leading: Icon(
                          hasCoach ? Icons.sports : Icons.person_search,
                          color: hasCoach ? Colors.green : Colors.orange,
                        ),
                        title: Text(hasCoach
                            ? 'Тренер: $coachName'
                            : 'Тренер не назначен'),
                        subtitle: Text(hasCoach
                            ? 'Нажмите для просмотра'
                            : 'Найдите тренера'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.go(hasCoach
                            ? AppRoutes.athleteMyCoach
                            : AppRoutes.athleteFindCoach),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Upcoming assignments
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Ближайшие задания',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        TextButton(
                          onPressed: () =>
                              context.go(AppRoutes.athleteAssignments),
                          child: const Text('Все'),
                        ),
                      ],
                    ),
                    if (upcomingAssignments.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: Text('Нет заданий')),
                      )
                    else
                      ...upcomingAssignments.map((a) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(
                              a.isOverdue
                                  ? Icons.warning_amber
                                  : a.status == 'completed'
                                      ? Icons.check_circle
                                      : Icons.assignment,
                              color: a.isOverdue
                                  ? Colors.red
                                  : a.status == 'completed'
                                      ? Colors.green
                                      : null,
                            ),
                            title: Text(a.title),
                            subtitle: Text(
                              '${a.scheduledDate.day.toString().padLeft(2, '0')}.${a.scheduledDate.month.toString().padLeft(2, '0')}.${a.scheduledDate.year}',
                            ),
                            onTap: () => context
                                .go('/athlete/assignments/${a.id}'),
                          )),
                  ],
                ),
              ),
            DashboardError(:final message) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context
                          .read<DashboardBloc>()
                          .add(const DashboardLoadRequested()),
                      child: const Text('Повторить'),
                    ),
                  ],
                ),
              ),
            _ => const SizedBox.shrink(),
          };
        },
      ),
    );
  }
}
