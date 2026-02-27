import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/repository_providers.dart';
import '../../domain/models/athlete_summary.dart';
import '../../domain/models/progress_point.dart';
import '../bloc/my_stats_bloc.dart';

class MyStatsScreen extends ConsumerWidget {
  const MyStatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BlocProvider(
      create: (_) => MyStatsBloc(
        repository: ref.read(analyticsRepositoryProvider),
      )..add(const MyStatsLoadRequested()),
      child: const _MyStatsView(),
    );
  }
}

class _MyStatsView extends StatelessWidget {
  const _MyStatsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('analytics.myStats'.tr())),
      body: BlocBuilder<MyStatsBloc, MyStatsState>(
        builder: (context, state) => switch (state) {
          MyStatsInitial() ||
          MyStatsLoading() =>
            const Center(child: CircularProgressIndicator()),
          MyStatsLoaded(:final summary, :final progress, :final period) =>
            _MyStatsContent(
              summary: summary,
              progress: progress,
              period: period,
            ),
          MyStatsError(:final message) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context
                        .read<MyStatsBloc>()
                        .add(const MyStatsLoadRequested()),
                    child: Text('common.retry'.tr()),
                  ),
                ],
              ),
            ),
        },
      ),
    );
  }
}

class _MyStatsContent extends StatelessWidget {
  const _MyStatsContent({
    required this.summary,
    required this.progress,
    required this.period,
  });

  final AthleteSummary summary;
  final List<ProgressPoint> progress;
  final String period;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SummarySection(summary: summary),
        const SizedBox(height: 16),
        _PeriodSelector(current: period),
        const SizedBox(height: 16),
        _ProgressSection(points: progress),
      ],
    );
  }
}

class _SummarySection extends StatelessWidget {
  const _SummarySection({required this.summary});
  final AthleteSummary summary;

  @override
  Widget build(BuildContext context) {
    final completionPct = (summary.completionRate * 100).round();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('analytics.results'.tr(), style: Theme.of(context).textTheme.titleMedium),
            const Divider(height: 20),
            _Row(icon: Icons.fitness_center, label: 'analytics.workouts'.tr(),
                value: '${summary.totalWorkouts}'),
            _Row(icon: Icons.timer, label: 'analytics.totalMinutes'.tr(),
                value: '${summary.totalMinutes}'),
            _Row(icon: Icons.straighten, label: 'analytics.distance'.tr(),
                value: '${summary.totalDistanceKm.toStringAsFixed(1)}${'analytics.km'.tr()}'),
            _Row(icon: Icons.speed, label: 'analytics.avgRpe'.tr(),
                value: summary.avgRpe.toStringAsFixed(1)),
            if (summary.avgHeartRate != null)
              _Row(icon: Icons.favorite, label: 'analytics.avgHeartRate'.tr(),
                  value: '${summary.avgHeartRate}${'analytics.bpm'.tr()}'),
            _Row(
              icon: Icons.check_circle_outline,
              label: 'analytics.completionRate'.tr(),
              value: '$completionPct%',
              valueColor: completionPct >= 80
                  ? Colors.green
                  : completionPct >= 60
                      ? Colors.orange
                      : Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 10),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: valueColor,
                ),
          ),
        ],
      ),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({required this.current});
  final String current;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('analytics.period'.tr(), style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(width: 12),
        ChoiceChip(
          label: Text('analytics.weeks'.tr()),
          selected: current == 'week',
          onSelected: (_) => context
              .read<MyStatsBloc>()
              .add(const MyStatsPeriodChanged('week')),
        ),
        const SizedBox(width: 8),
        ChoiceChip(
          label: Text('analytics.months'.tr()),
          selected: current == 'month',
          onSelected: (_) => context
              .read<MyStatsBloc>()
              .add(const MyStatsPeriodChanged('month')),
        ),
      ],
    );
  }
}

class _ProgressSection extends StatelessWidget {
  const _ProgressSection({required this.points});
  final List<ProgressPoint> points;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return Center(child: Text('analytics.noDataForPeriod'.tr()));
    }

    final maxWorkouts =
        points.map((p) => p.workouts).reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('analytics.dynamics'.tr(), style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: points.map((point) {
                  final ratio =
                      maxWorkouts > 0 ? point.workouts / maxWorkouts : 0.0;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('${point.workouts}',
                              style: Theme.of(context).textTheme.bodySmall),
                          const SizedBox(height: 4),
                          Container(
                            height: 80 * ratio,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(4)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: points
                  .map((p) => Expanded(
                        child: Text(p.label,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
