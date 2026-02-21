import 'models/ai_result.dart';

abstract class AiRepository {
  Future<AiResult> getAthleteRecommendations({
    required String athleteId,
    String? context,
  });

  Future<AiResult> getAthleteAnalysis({
    required String athleteId,
    String? context,
  });

  Future<AiResult> getCoachSummary({
    DateTime? dateFrom,
    DateTime? dateTo,
    String? context,
  });
}
