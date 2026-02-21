import '../domain/analytics_repository.dart';
import '../domain/models/athlete_summary.dart';
import '../domain/models/coach_overview.dart';
import '../domain/models/progress_point.dart';

class AnalyticsRepositoryMock implements AnalyticsRepository {
  static const _delay = Duration(milliseconds: 600);

  static const _athleteSummary = AthleteSummary(
    totalWorkouts: 18,
    totalMinutes: 1260,
    avgRpe: 6.4,
    avgHeartRate: 152,
    totalDistanceKm: 136.5,
    completionRate: 0.82,
  );

  static final _progress = [
    const ProgressPoint(
      label: 'Нед. 1',
      workouts: 3,
      totalMinutes: 185,
      avgRpe: 5.8,
      avgHeartRate: 145,
      totalDistanceKm: 19.2,
    ),
    const ProgressPoint(
      label: 'Нед. 2',
      workouts: 4,
      totalMinutes: 270,
      avgRpe: 6.2,
      avgHeartRate: 150,
      totalDistanceKm: 28.6,
    ),
    const ProgressPoint(
      label: 'Нед. 3',
      workouts: 5,
      totalMinutes: 350,
      avgRpe: 6.7,
      avgHeartRate: 156,
      totalDistanceKm: 38.4,
    ),
    const ProgressPoint(
      label: 'Нед. 4',
      workouts: 6,
      totalMinutes: 455,
      avgRpe: 6.8,
      avgHeartRate: 158,
      totalDistanceKm: 50.3,
    ),
  ];

  @override
  Future<AthleteSummary> getAthleteSummary({required String athleteId}) async {
    await Future.delayed(_delay);
    return _athleteSummary;
  }

  @override
  Future<List<ProgressPoint>> getAthleteProgress({
    required String athleteId,
    required String period,
  }) async {
    await Future.delayed(_delay);
    return _progress;
  }

  @override
  Future<CoachOverview> getCoachOverview() async {
    await Future.delayed(_delay);
    return const CoachOverview(
      totalAthletes: 3,
      totalWorkouts: 52,
      avgCompletionRate: 0.79,
      athletes: [
        AthleteOverviewItem(
          athleteId: '22222222-2222-2222-2222-222222222222',
          athleteFullName: 'Петров Иван Сергеевич',
          athleteLogin: 'ivan-petrov',
          totalWorkouts: 18,
          completionRate: 0.82,
          avgRpe: 6.4,
        ),
        AthleteOverviewItem(
          athleteId: '33333333-3333-3333-3333-333333333333',
          athleteFullName: 'Сидорова Мария Александровна',
          athleteLogin: 'maria-sidorova',
          totalWorkouts: 22,
          completionRate: 0.91,
          avgRpe: 5.9,
        ),
        AthleteOverviewItem(
          athleteId: '44444444-4444-4444-4444-444444444444',
          athleteFullName: 'Козлов Дмитрий Владимирович',
          athleteLogin: 'dmitry-kozlov',
          totalWorkouts: 12,
          completionRate: 0.62,
          avgRpe: 7.1,
        ),
      ],
    );
  }

  @override
  Future<AthleteSummary> getMySummary() async {
    await Future.delayed(_delay);
    return const AthleteSummary(
      totalWorkouts: 22,
      totalMinutes: 1540,
      avgRpe: 5.9,
      avgHeartRate: 148,
      totalDistanceKm: 164.0,
      completionRate: 0.91,
    );
  }

  @override
  Future<List<ProgressPoint>> getMyProgress({required String period}) async {
    await Future.delayed(_delay);
    return _progress;
  }
}
