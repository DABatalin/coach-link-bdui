import 'models/athlete_summary.dart';
import 'models/coach_overview.dart';
import 'models/progress_point.dart';

abstract class AnalyticsRepository {
  Future<AthleteSummary> getAthleteSummary({required String athleteId});

  Future<List<ProgressPoint>> getAthleteProgress({
    required String athleteId,
    required String period,
  });

  Future<CoachOverview> getCoachOverview();

  Future<AthleteSummary> getMySummary();

  Future<List<ProgressPoint>> getMyProgress({required String period});
}
