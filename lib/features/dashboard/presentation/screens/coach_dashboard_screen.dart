import 'package:bdui_kit/bdui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../core/bdui/bdui_action_handler.dart';
import '../../../../core/bdui/bdui_providers.dart';
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
        authState is Authenticated ? authState.fullName : 'profile.coach'.tr();

    final actionHandler = ref.read(bduiActionHandlerProvider);

    return BlocProvider(
      create: (_) => DashboardBloc(
        role: 'coach',
        connectionsRepository: ref.read(connectionsRepositoryProvider),
        trainingRepository: ref.read(trainingRepositoryProvider),
        bduiDataProvider: ref.read(bduiDataProviderProvider),
      )..add(const DashboardLoadRequested()),
      child: _CoachDashboardView(
        fullName: fullName,
        actionHandler: actionHandler,
      ),
    );
  }
}

class _CoachDashboardView extends StatelessWidget {
  const _CoachDashboardView({
    required this.fullName,
    required this.actionHandler,
  });
  final String fullName;
  final BduiActionHandler actionHandler;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('app.name'.tr()),
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
            DashboardBduiLoaded(:final schema) => RefreshIndicator(
                onRefresh: () async => context
                    .read<DashboardBloc>()
                    .add(const DashboardLoadRequested()),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: BduiRenderer(
                    registry: ComponentRegistry.defaults(),
                    onAction: (action) {
                      if (action is RefreshAction) {
                        context
                            .read<DashboardBloc>()
                            .add(const DashboardLoadRequested());
                      } else {
                        actionHandler.handle(action);
                      }
                    },
                  ).buildSchema(schema),
                ),
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
                          child: Text('dashboard.all'.tr()),
                        ),
                      ],
                    ),
                    if (recentAssignments.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: Text('dashboard.noAssignments'.tr())),
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
                      child: Text('common.retry'.tr()),
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
