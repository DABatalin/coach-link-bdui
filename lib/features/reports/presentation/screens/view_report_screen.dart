import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/repository_providers.dart';
import '../bloc/view_report_bloc.dart';

class ViewReportScreen extends ConsumerWidget {
  const ViewReportScreen({super.key, required this.assignmentId});
  final String assignmentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BlocProvider(
      create: (_) => ViewReportBloc(
        repository: ref.read(reportsRepositoryProvider),
      )..add(ViewReportLoadRequested(assignmentId)),
      child: _ViewReportView(assignmentId: assignmentId),
    );
  }
}

class _ViewReportView extends StatelessWidget {
  const _ViewReportView({required this.assignmentId});
  final String assignmentId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Отчёт')),
      body: BlocBuilder<ViewReportBloc, ViewReportState>(
        builder: (context, state) {
          return switch (state) {
            ViewReportInitial() || ViewReportLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
            ViewReportLoaded(:final report) => ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (report.athleteFullName != null) ...[
                    Text(
                      report.athleteFullName!,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    if (report.athleteLogin != null)
                      Text(
                        '@${report.athleteLogin}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    const Divider(height: 24),
                  ],
                  _InfoRow(
                    icon: Icons.timer,
                    label: 'Длительность',
                    value: '${report.durationMinutes} мин',
                  ),
                  _InfoRow(
                    icon: Icons.speed,
                    label: 'RPE (самочувствие)',
                    value: '${report.perceivedEffort} / 10',
                  ),
                  if (report.maxHeartRate != null)
                    _InfoRow(
                      icon: Icons.favorite,
                      label: 'Макс. пульс',
                      value: '${report.maxHeartRate} уд/мин',
                    ),
                  if (report.avgHeartRate != null)
                    _InfoRow(
                      icon: Icons.favorite_border,
                      label: 'Сред. пульс',
                      value: '${report.avgHeartRate} уд/мин',
                    ),
                  if (report.distanceKm != null)
                    _InfoRow(
                      icon: Icons.straighten,
                      label: 'Дистанция',
                      value: '${report.distanceKm} км',
                    ),
                  const Divider(height: 24),
                  Text(
                    'Комментарий',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    report.content,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ViewReportError(:final message) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context
                          .read<ViewReportBloc>()
                          .add(ViewReportLoadRequested(assignmentId)),
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
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const Spacer(),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
