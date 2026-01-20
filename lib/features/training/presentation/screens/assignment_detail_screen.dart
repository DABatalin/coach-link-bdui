import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/repository_providers.dart';
import '../bloc/assignment_detail_bloc.dart';

class AssignmentDetailScreen extends ConsumerWidget {
  const AssignmentDetailScreen({
    super.key,
    required this.assignmentId,
    this.isCoach = false,
  });

  final String assignmentId;
  final bool isCoach;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BlocProvider(
      create: (_) => AssignmentDetailBloc(
        repository: ref.read(trainingRepositoryProvider),
      )..add(AssignmentDetailLoadRequested(assignmentId)),
      child: _AssignmentDetailView(
        assignmentId: assignmentId,
        isCoach: isCoach,
      ),
    );
  }
}

class _AssignmentDetailView extends StatelessWidget {
  const _AssignmentDetailView({
    required this.assignmentId,
    required this.isCoach,
  });

  final String assignmentId;
  final bool isCoach;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AssignmentDetailBloc, AssignmentDetailState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              state is AssignmentDetailLoaded
                  ? state.assignment.title
                  : 'Задание',
            ),
          ),
          body: switch (state) {
            AssignmentDetailInitial() ||
            AssignmentDetailLoading() =>
              const Center(child: CircularProgressIndicator()),
            AssignmentDetailLoaded(:final assignment) => SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status chip
                    Row(
                      children: [
                        Chip(
                          label: Text(
                            assignment.isOverdue
                                ? 'Просрочено'
                                : assignment.status == 'completed'
                                    ? 'Выполнено'
                                    : assignment.status == 'archived'
                                        ? 'В архиве'
                                        : 'Назначено',
                          ),
                          backgroundColor: assignment.isOverdue
                              ? Colors.red[50]
                              : assignment.status == 'completed'
                                  ? Colors.green[50]
                                  : Colors.blue[50],
                        ),
                        const Spacer(),
                        Text(
                          _formatDate(assignment.scheduledDate),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Athlete/Coach info
                    if (isCoach && assignment.athleteFullName != null) ...[
                      Text(
                        'Спортсмен: ${assignment.athleteFullName}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (!isCoach && assignment.coachFullName != null) ...[
                      Text(
                        'Тренер: ${assignment.coachFullName}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                    ],

                    const Divider(height: 32),

                    // Description
                    Text(
                      'Описание тренировки',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      assignment.description,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 24),

                    // Actions
                    if (!isCoach &&
                        assignment.status == 'assigned' &&
                        !assignment.hasReport)
                      ElevatedButton.icon(
                        onPressed: () => context.go(
                          '/athlete/assignments/${assignment.id}/report/submit',
                        ),
                        icon: const Icon(Icons.edit_note),
                        label: const Text('Отправить отчёт'),
                      ),
                    if (isCoach && assignment.hasReport)
                      OutlinedButton.icon(
                        onPressed: () => context.go(
                          '/coach/assignments/${assignment.id}/report',
                        ),
                        icon: const Icon(Icons.description),
                        label: const Text('Просмотреть отчёт'),
                      ),
                  ],
                ),
              ),
            AssignmentDetailError(:final message) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context
                          .read<AssignmentDetailBloc>()
                          .add(AssignmentDetailLoadRequested(assignmentId)),
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

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
}
