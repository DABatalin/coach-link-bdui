import 'package:dio/dio.dart';

import '../domain/ai_repository.dart';
import '../domain/models/ai_result.dart';

class AiRepositoryImpl implements AiRepository {
  AiRepositoryImpl(this._dio);
  final Dio _dio;

  @override
  Future<AiResult> getAthleteRecommendations({
    required String athleteId,
    String? context,
  }) async {
    final response = await _dio.post(
      '/api/v1/ai/athletes/$athleteId/recommendations',
      data: context != null ? {'context': context} : null,
    );
    return AiResult.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<AiResult> getAthleteAnalysis({
    required String athleteId,
    String? context,
  }) async {
    final response = await _dio.post(
      '/api/v1/ai/athletes/$athleteId/analysis',
      data: context != null ? {'context': context} : null,
    );
    return AiResult.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<AiResult> getCoachSummary({
    DateTime? dateFrom,
    DateTime? dateTo,
    String? context,
  }) async {
    final response = await _dio.post(
      '/api/v1/ai/coach/summary',
      data: {
        if (dateFrom != null)
          'date_from': dateFrom.toIso8601String().substring(0, 10),
        if (dateTo != null)
          'date_to': dateTo.toIso8601String().substring(0, 10),
        if (context != null) 'context': context,
      },
    );
    return AiResult.fromJson(response.data as Map<String, dynamic>);
  }
}
