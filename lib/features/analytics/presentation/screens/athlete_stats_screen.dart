import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/repository_providers.dart';
import '../../domain/models/athlete_summary.dart';
import '../../domain/models/progress_point.dart';
import '../bloc/athlete_stats_bloc.dart';

class AthleteStatsScreen extends ConsumerWidget {
  const AthleteStatsScreen({super.key, required this.athleteId});
  final String athleteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BlocProvider(
      create: (_) => AthleteStatsBloc(
        repository: ref.read(analyticsRepositoryProvider),
      )..add(AthleteStatsLoadRequested(athleteId)),
      child: _AthleteStatsView(athleteId: athleteId),
    );
  }
}

class _AthleteStatsView extends StatelessWidget {
  const _AthleteStatsView({required this.athleteId});
  final String athleteId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Статистика')),
      body: BlocBuilder<AthleteStatsBloc, AthleteStatsState>(
        builder: (context, state) => switch (state) {
          AthleteStatsInitial() ||
          AthleteStatsLoading() =>
            const Center(child: CircularProgressIndicator()),
          AthleteStatsLoaded(:final summary, :final progress, :final period) =>
            _StatsContent(
              summary: summary,
              progress: progress,
              period: period,
              athleteId: athleteId,
            ),
          AthleteStatsError(:final message) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context
                        .read<AthleteStatsBloc>()
                        .add(AthleteStatsLoadRequested(athleteId)),
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            ),
        },
      ),
    );
  }
}

class _StatsContent extends StatelessWidget {
  const _StatsContent({
    required this.summary,
    required this.progress,
    required this.period,
    required this.athleteId,
  });

  final AthleteSummary summary;
  final List<ProgressPoint> progress;
  final String period;
  final String athleteId;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SummaryCard(summary: summary),
        const SizedBox(height: 16),
        _PeriodSelector(current: period, athleteId: athleteId),
        const SizedBox(height: 16),
        _ProgressChart(points: progress),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary});
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
            Text('Сводка', style: Theme.of(context).textTheme.titleMedium),
            const Divider(height: 20),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              children: [
                _StatChip(
                  icon: Icons.fitness_center,
                  label: 'Тренировок',
                  value: '${summary.totalWorkouts}',
                ),
                _StatChip(
                  icon: Icons.timer,
                  label: 'Всего минут',
                  value: '${summary.totalMinutes}',
                ),
                _StatChip(
                  icon: Icons.speed,
                  label: 'Ср. RPE',
                  value: summary.avgRpe.toStringAsFixed(1),
                ),
                if (summary.avgHeartRate != null)
                  _StatChip(
                    icon: Icons.favorite,
                    label: 'Ср. пульс',
                    value: '${summary.avgHeartRate} уд/мин',
                  ),
                _StatChip(
                  icon: Icons.straighten,
                  label: 'Дистанция',
                  value: '${summary.totalDistanceKm.toStringAsFixed(1)} км',
                ),
                _StatChip(
                  icon: Icons.check_circle_outline,
                  label: 'Выполнение',
                  value: '$completionPct%',
                  color: completionPct >= 80
                      ? Colors.green
                      : completionPct >= 60
                          ? Colors.orange
                          : Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.primary;
    return SizedBox(
      width: 140,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: effectiveColor),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        )),
                Text(value,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({required this.current, required this.athleteId});
  final String current;
  final String athleteId;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('Период:', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(width: 12),
        ChoiceChip(
          label: const Text('Недели'),
          selected: current == 'week',
          onSelected: (_) => context
              .read<AthleteStatsBloc>()
              .add(AthleteStatsPeriodChanged(athleteId, 'week')),
        ),
        const SizedBox(width: 8),
        ChoiceChip(
          label: const Text('Месяцы'),
          selected: current == 'month',
          onSelected: (_) => context
              .read<AthleteStatsBloc>()
              .add(AthleteStatsPeriodChanged(athleteId, 'month')),
        ),
      ],
    );
  }
}

class _ProgressChart extends StatelessWidget {
  const _ProgressChart({required this.points});
  final List<ProgressPoint> points;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const Center(child: Text('Нет данных за период'));
    }

    final maxWorkouts =
        points.map((p) => p.workouts).reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Прогресс (тренировки)',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: points.map((point) {
                  final ratio = maxWorkouts > 0 ? point.workouts / maxWorkouts : 0.0;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '${point.workouts}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
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
                        child: Text(
                          p.label,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ))
                  .toList(),
            ),
            const Divider(height: 24),
            ...points.map((p) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      SizedBox(
                          width: 60,
                          child: Text(p.label,
                              style: Theme.of(context).textTheme.bodySmall)),
                      Expanded(
                          child: Text(
                              '${p.totalMinutes} мин · RPE ${p.avgRpe.toStringAsFixed(1)} · ${p.totalDistanceKm.toStringAsFixed(1)} км',
                              style: Theme.of(context).textTheme.bodySmall)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
