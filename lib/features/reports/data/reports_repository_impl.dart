import 'package:dio/dio.dart';

import '../domain/models/training_report.dart';
import '../domain/reports_repository.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  ReportsRepositoryImpl(this._dio);
  final Dio _dio;

  @override
  Future<TrainingReport> submitReport({
    required String assignmentId,
    required String content,
    required int durationMinutes,
    required int perceivedEffort,
    int? maxHeartRate,
    int? avgHeartRate,
    double? distanceKm,
  }) async {
    final response = await _dio.post(
      '/api/v1/training/assignments/$assignmentId/report',
      data: {
        'content': content,
        'duration_minutes': durationMinutes,
        'perceived_effort': perceivedEffort,
        if (maxHeartRate != null) 'max_heart_rate': maxHeartRate,
        if (avgHeartRate != null) 'avg_heart_rate': avgHeartRate,
        if (distanceKm != null) 'distance_km': distanceKm,
      },
    );
    return TrainingReport.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<TrainingReport> getReport({required String assignmentId}) async {
    final response =
        await _dio.get('/api/v1/training/assignments/$assignmentId/report');
    return TrainingReport.fromJson(response.data as Map<String, dynamic>);
  }
}
