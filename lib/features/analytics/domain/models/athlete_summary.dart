class AthleteSummary {
  const AthleteSummary({
    required this.totalWorkouts,
    required this.totalMinutes,
    required this.avgRpe,
    required this.avgHeartRate,
    required this.totalDistanceKm,
    required this.completionRate,
  });

  final int totalWorkouts;
  final int totalMinutes;
  final double avgRpe;
  final int? avgHeartRate;
  final double totalDistanceKm;
  final double completionRate;

  factory AthleteSummary.fromJson(Map<String, dynamic> json) => AthleteSummary(
        totalWorkouts:
            (json['total_workouts'] ?? json['total_reports'] ?? 0) as int,
        totalMinutes:
            (json['total_minutes'] ?? json['total_duration_minutes'] ?? 0)
                as int,
        avgRpe:
            ((json['avg_rpe'] ?? json['avg_perceived_effort'] ?? 0) as num)
                .toDouble(),
        avgHeartRate: json['avg_heart_rate'] == 0
            ? null
            : json['avg_heart_rate'] as int?,
        totalDistanceKm:
            ((json['total_distance_km'] ?? 0) as num).toDouble(),
        completionRate:
            ((json['completion_rate'] ?? 0) as num).toDouble(),
      );
}
