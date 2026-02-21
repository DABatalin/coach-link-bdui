import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/repository_providers.dart';
import '../bloc/athlete_detail_bloc.dart';

class AthleteDetailScreen extends ConsumerWidget {
  const AthleteDetailScreen({
    super.key,
    required this.athleteId,
  });

  final String athleteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BlocProvider(
      create: (_) => AthleteDetailBloc(
        connectionsRepository: ref.read(connectionsRepositoryProvider),
        trainingRepository: ref.read(trainingRepositoryProvider),
      )..add(AthleteDetailLoadRequested(athleteId)),
      child: _AthleteDetailView(athleteId: athleteId),
    );
  }
}

class _AthleteDetailView extends StatelessWidget {
  const _AthleteDetailView({required this.athleteId});
  final String athleteId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AthleteDetailBloc, AthleteDetailState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              state is AthleteDetailLoaded
                  ? state.athleteInfo.fullName
                  : 'Спортсмен',
            ),
            actions: [
              if (state is AthleteDetailLoaded) ...[
                IconButton(
                  icon: const Icon(Icons.bar_chart),
                  onPressed: () =>
                      context.go('/coach/athletes/$athleteId/stats'),
                  tooltip: 'Статистика',
                ),
                IconButton(
                  icon: const Icon(Icons.psychology),
                  onPressed: () =>
                      context.go('/coach/athletes/$athleteId/ai'),
                  tooltip: 'ИИ-анализ',
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => context
                      .read<AthleteDetailBloc>()
                      .add(const AthleteDetailRefreshRequested()),
                  tooltip: 'Обновить',
                ),
              ],
            ],
          ),
          body: switch (state) {
            AthleteDetailInitial() ||
            AthleteDetailLoading() =>
              const Center(child: CircularProgressIndicator()),
            AthleteDetailLoaded(:final athleteInfo, :final assignments) =>
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Athlete info section
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 32,
                              child: Text(
                                athleteInfo.fullName.isNotEmpty
                                    ? athleteInfo.fullName[0]
                                    : '?',
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    athleteInfo.fullName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '@${athleteInfo.login}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Colors.grey[600],
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Подключён: ${_formatDate(athleteInfo.connectedAt)}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Colors.grey[600],
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Assignments section
                    Text(
                      'Задания',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    assignments.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32),
                              child: Text('Нет заданий'),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: assignments.length,
                            itemBuilder: (context, index) {
                              final assignment = assignments[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: Icon(
                                    assignment.isOverdue
                                        ? Icons.warning_amber
                                        : assignment.hasReport
                                            ? Icons.check_circle
                                            : Icons.assignment,
                                    color: assignment.isOverdue
                                        ? Colors.red
                                        : assignment.hasReport
                                            ? Colors.green
                                            : null,
                                  ),
                                  title: Text(assignment.title),
                                  subtitle: Text(
                                    '${_formatDate(assignment.scheduledDate)} · ${_getStatusText(assignment.status)}',
                                  ),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () => context.go(
                                    '/coach/assignments/${assignment.id}',
                                  ),
                                ),
                              );
                            },
                          ),
                  ],
                ),
              ),
            AthleteDetailError(:final message) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context
                          .read<AthleteDetailBloc>()
                          .add(const AthleteDetailRefreshRequested()),
                      child: const Text('Повторить'),
                    ),
                  ],
                ),
              ),
          },
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'assigned':
        return 'Назначено';
      case 'completed':
        return 'Выполнено';
      case 'archived':
        return 'В архиве';
      default:
        return status;
    }
  }
}
