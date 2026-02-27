import 'package:bdui_kit/bdui_kit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/bdui/bdui_action_handler.dart';
import '../../../../core/bdui/bdui_providers.dart';
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
    final actionHandler = ref.read(bduiActionHandlerProvider);

    return BlocProvider(
      create: (_) => AssignmentDetailBloc(
        repository: ref.read(trainingRepositoryProvider),
        bduiDataProvider: ref.read(bduiDataProviderProvider),
      )..add(AssignmentDetailLoadRequested(assignmentId)),
      child: _AssignmentDetailView(
        assignmentId: assignmentId,
        isCoach: isCoach,
        actionHandler: actionHandler,
      ),
    );
  }
}

class _AssignmentDetailView extends StatelessWidget {
  const _AssignmentDetailView({
    required this.assignmentId,
    required this.isCoach,
    required this.actionHandler,
  });

  final String assignmentId;
  final bool isCoach;
  final BduiActionHandler actionHandler;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AssignmentDetailBloc, AssignmentDetailState>(
      builder: (context, state) {
        final title = switch (state) {
          AssignmentDetailLoaded(:final assignment) => assignment.title,
          AssignmentDetailWithBdui(:final assignment) => assignment.title,
          _ => 'training.assignment'.tr(),
        };

        return Scaffold(
          appBar: AppBar(title: Text(title)),
          body: switch (state) {
            AssignmentDetailInitial() ||
            AssignmentDetailLoading() =>
              const Center(child: CircularProgressIndicator()),
            AssignmentDetailWithBdui(
              :final assignment,
              :final descriptionSchema,
            ) =>
              _buildDetailBody(context, assignment,
                  bduiSchema: descriptionSchema),
            AssignmentDetailLoaded(:final assignment) =>
              _buildDetailBody(context, assignment),
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
                      child: Text('common.retry'.tr()),
                    ),
                  ],
                ),
              ),
          },
        );
      },
    );
  }

  Widget _buildDetailBody(
    BuildContext context,
    dynamic assignment, {
    BduiSchema? bduiSchema,
  }) {
    return SingleChildScrollView(
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
                      ? 'training.overdue'.tr()
                      : assignment.status == 'completed'
                          ? 'training.completed'.tr()
                          : assignment.status == 'archived'
                              ? 'training.inArchive'.tr()
                              : 'training.assigned'.tr(),
                ),
                backgroundColor: assignment.isOverdue
                    ? const Color.fromARGB(255, 165, 79, 92)
                    : assignment.status == 'completed'
                        ? const Color.fromARGB(255, 100, 158, 105)
                        : const Color.fromARGB(255, 116, 162, 196),
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
              '${'training.athlete'.tr()} ${assignment.athleteFullName}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
          ],
          if (!isCoach && assignment.coachFullName != null) ...[
            Text(
              '${'training.coach'.tr()} ${assignment.coachFullName}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
          ],

          const Divider(height: 32),

          // Description
          Text(
            'training.trainingDescription'.tr(),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),

          // BDUI-описание или plain-text
          if (bduiSchema != null)
            BduiRenderer(
              registry: ComponentRegistry.defaults(),
              onAction: (action) {
                if (action is RefreshAction) {
                  context
                      .read<AssignmentDetailBloc>()
                      .add(AssignmentDetailLoadRequested(assignment.id));
                } else {
                  actionHandler.handle(action);
                }
              },
            ).buildSchema(bduiSchema)
          else
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
              label: Text('training.submitReport'.tr()),
            ),
          if (isCoach && assignment.hasReport)
            OutlinedButton.icon(
              onPressed: () => context.go(
                '/coach/assignments/${assignment.id}/report',
              ),
              icon: const Icon(Icons.description),
              label: Text('training.viewReport'.tr()),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
}
