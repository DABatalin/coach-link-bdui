import 'package:dio/dio.dart';

import '../domain/analytics_repository.dart';
import '../domain/models/athlete_summary.dart';
import '../domain/models/coach_overview.dart';
import '../domain/models/progress_point.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  AnalyticsRepositoryImpl(this._dio);
  final Dio _dio;

  @override
  Future<AthleteSummary> getAthleteSummary({required String athleteId}) async {
    final response =
        await _dio.get('/api/v1/analytics/athletes/$athleteId/summary');
    return AthleteSummary.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<ProgressPoint>> getAthleteProgress({
    required String athleteId,
    required String period,
  }) async {
    final response = await _dio.get(
      '/api/v1/analytics/athletes/$athleteId/progress',
      queryParameters: {'period': period},
    );
    final data = response.data;
    final points = data is Map ? (data['points'] as List? ?? []) : data as List;
    return points
        .map((e) => ProgressPoint.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<CoachOverview> getCoachOverview() async {
    final response = await _dio.get('/api/v1/analytics/overview');
    return CoachOverview.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<AthleteSummary> getMySummary() async {
    final response = await _dio.get('/api/v1/analytics/me/summary');
    return AthleteSummary.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<ProgressPoint>> getMyProgress({required String period}) async {
    final response = await _dio.get(
      '/api/v1/analytics/me/progress',
      queryParameters: {'period': period},
    );
    final data = response.data;
    final points = data is Map ? (data['points'] as List? ?? []) : data as List;
    return points
        .map((e) => ProgressPoint.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
