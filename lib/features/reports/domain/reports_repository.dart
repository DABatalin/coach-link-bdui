import 'models/training_report.dart';

abstract class ReportsRepository {
  Future<TrainingReport> submitReport({
    required String assignmentId,
    required String content,
    required int durationMinutes,
    required int perceivedEffort,
    int? maxHeartRate,
    int? avgHeartRate,
    double? distanceKm,
  });

  Future<TrainingReport> getReport({required String assignmentId});
}
