import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/repository_providers.dart';
import '../bloc/assignments_bloc.dart';

class AthleteAssignmentsScreen extends ConsumerWidget {
  const AthleteAssignmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BlocProvider(
      create: (_) => AssignmentsBloc(
        repository: ref.read(trainingRepositoryProvider),
      )..add(const AssignmentsLoadRequested()),
      child: const _AthleteAssignmentsView(),
    );
  }
}

class _AthleteAssignmentsView extends StatelessWidget {
  const _AthleteAssignmentsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Мои задания')),
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
                          '${_formatDate(a.scheduledDate)} · ${a.coachFullName ?? ''}',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () =>
                            context.go('/athlete/assignments/${a.id}'),
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
