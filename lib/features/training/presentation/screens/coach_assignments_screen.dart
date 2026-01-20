import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/repository_providers.dart';
import '../../../../core/navigation/routes.dart';
import '../bloc/assignments_bloc.dart';

class CoachAssignmentsScreen extends ConsumerWidget {
  const CoachAssignmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BlocProvider(
      create: (_) => AssignmentsBloc(
        repository: ref.read(trainingRepositoryProvider),
      )..add(const AssignmentsLoadRequested()),
      child: const _CoachAssignmentsView(),
    );
  }
}

class _CoachAssignmentsView extends StatelessWidget {
  const _CoachAssignmentsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Задания'),
        actions: [
          IconButton(
            icon: const Icon(Icons.archive_outlined),
            onPressed: () => context.go(AppRoutes.coachArchived),
            tooltip: 'Архив',
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_outline),
            onPressed: () => context.go(AppRoutes.coachTemplates),
            tooltip: 'Шаблоны',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go(AppRoutes.coachPlanCreate),
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<AssignmentsBloc, AssignmentsState>(
        builder: (context, state) {
          return switch (state) {
            AssignmentsInitial() || AssignmentsLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
            AssignmentsLoaded(:final assignments) => assignments.isEmpty
                ? const Center(child: Text('Нет заданий'))
                : ListView.builder(
                    itemCount: assignments.length,
                    itemBuilder: (context, index) {
                      final a = assignments[index];
                      return ListTile(
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
                        subtitle: Text(
                          '${a.athleteFullName ?? ''} · ${_formatDate(a.scheduledDate)}',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context
                            .go('/coach/assignments/${a.id}'),
                      );
                    },
                  ),
            AssignmentsError(:final message) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context
                          .read<AssignmentsBloc>()
                          .add(const AssignmentsLoadRequested()),
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

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
}
