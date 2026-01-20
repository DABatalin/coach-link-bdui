class TrainingReport {
  const TrainingReport({
    required this.id,
    required this.assignmentId,
    required this.athleteId,
    this.athleteFullName,
    this.athleteLogin,
    required this.content,
    required this.durationMinutes,
    required this.perceivedEffort,
    this.maxHeartRate,
    this.avgHeartRate,
    this.distanceKm,
    required this.createdAt,
  });

  final String id;
  final String assignmentId;
  final String athleteId;
  final String? athleteFullName;
  final String? athleteLogin;
  final String content;
  final int durationMinutes;
  final int perceivedEffort;
  final int? maxHeartRate;
  final int? avgHeartRate;
  final double? distanceKm;
  final DateTime createdAt;

  factory TrainingReport.fromJson(Map<String, dynamic> json) {
    return TrainingReport(
      id: json['id'] as String,
      assignmentId: json['assignment_id'] as String,
      athleteId: json['athlete_id'] as String,
      athleteFullName: json['athlete_full_name'] as String?,
      athleteLogin: json['athlete_login'] as String?,
      content: json['content'] as String,
      durationMinutes: json['duration_minutes'] as int,
      perceivedEffort: json['perceived_effort'] as int,
      maxHeartRate: json['max_heart_rate'] as int?,
      avgHeartRate: json['avg_heart_rate'] as int?,
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
