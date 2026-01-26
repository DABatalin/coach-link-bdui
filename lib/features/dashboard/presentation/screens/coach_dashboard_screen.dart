import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/repository_providers.dart';
import '../../../../core/di/auth_providers.dart';
import '../../../../core/auth/auth_state.dart';
import '../../../../core/navigation/routes.dart';
import '../bloc/dashboard_bloc.dart';

class CoachDashboardScreen extends ConsumerWidget {
  const CoachDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authManager = ref.read(authManagerProvider);
    final authState = authManager.currentState;
    final fullName =
        authState is Authenticated ? authState.fullName : 'Тренер';

    return BlocProvider(
      create: (_) => DashboardBloc(
        role: 'coach',
        connectionsRepository: ref.read(connectionsRepositoryProvider),
        trainingRepository: ref.read(trainingRepositoryProvider),
      )..add(const DashboardLoadRequested()),
      child: _CoachDashboardView(fullName: fullName),
    );
  }
}

class _CoachDashboardView extends StatelessWidget {
  const _CoachDashboardView({required this.fullName});
  final String fullName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CoachLink'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.go(AppRoutes.coachNotifications),
          ),
        ],
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          return switch (state) {
            DashboardInitial() || DashboardLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
            CoachDashboardLoaded(
              :final athleteCount,
              :final pendingRequestsCount,
              :final recentAssignments,
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
                    Row(
                      children: [
                        Expanded(
                          child: _DashboardCard(
                            icon: Icons.people,
                            label: 'Спортсмены',
                            value: '$athleteCount',
                            onTap: () =>
                                context.go(AppRoutes.coachAthletes),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _DashboardCard(
                            icon: Icons.person_add,
                            label: 'Заявки',
                            value: '$pendingRequestsCount',
                            highlight: pendingRequestsCount > 0,
                            onTap: () =>
                                context.go(AppRoutes.coachRequests),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Последние задания',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        TextButton(
                          onPressed: () =>
                              context.go(AppRoutes.coachAssignments),
                          child: const Text('Все'),
                        ),
                      ],
                    ),
                    if (recentAssignments.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: Text('Нет заданий')),
                      )
                    else
                      ...recentAssignments.map((a) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(
                              a.isOverdue
                                  ? Icons.warning_amber
                                  : a.hasReport
                                      ? Icons.check_circle
                                      : Icons.assignment,
                              color: a.isOverdue
                                  ? Colors.red
                                  : a.hasReport
                                      ? Colors.green
                                      : null,
                            ),
                            title: Text(a.title),
                            subtitle: Text(a.athleteFullName ?? ''),
                            onTap: () => context
                                .go('/coach/assignments/${a.id}'),
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

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({
    required this.icon,
    required this.label,
    required this.value,
    this.highlight = false,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool highlight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: highlight ? Colors.orange[50] : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: highlight ? Colors.orange : Colors.blue),
              const SizedBox(height: 8),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
