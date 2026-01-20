import '../domain/models/training_report.dart';
import '../domain/reports_repository.dart';

class ReportsRepositoryMock implements ReportsRepository {
  final _reports = <String, TrainingReport>{};

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
    await Future.delayed(const Duration(milliseconds: 400));
    final report = TrainingReport(
      id: 'r-${_reports.length + 1}',
      assignmentId: assignmentId,
      athleteId: '22222222-2222-2222-2222-222222222222',
      athleteFullName: 'Петров Иван Сергеевич',
      athleteLogin: 'ivan-petrov',
      content: content,
      durationMinutes: durationMinutes,
      perceivedEffort: perceivedEffort,
      maxHeartRate: maxHeartRate,
      avgHeartRate: avgHeartRate,
      distanceKm: distanceKm,
      createdAt: DateTime.now(),
    );
    _reports[assignmentId] = report;
    return report;
  }

  @override
  Future<TrainingReport> getReport({required String assignmentId}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (_reports.containsKey(assignmentId)) {
      return _reports[assignmentId]!;
    }
    // Return a pre-filled report for assignments that "already have" one
    return TrainingReport(
      id: 'r-existing',
      assignmentId: assignmentId,
      athleteId: '22222222-2222-2222-2222-222222222222',
      athleteFullName: 'Петров Иван Сергеевич',
      athleteLogin: 'ivan-petrov',
      content:
          'Чувствовал себя хорошо. Первые 3 км бежал легко, после 5 км начал уставать. Средний темп 4:40/км.',
      durationMinutes: 45,
      perceivedEffort: 6,
      maxHeartRate: 172,
      avgHeartRate: 148,
      distanceKm: 8.2,
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
    );
  }
}
