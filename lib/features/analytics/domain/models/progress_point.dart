class ProgressPoint {
  const ProgressPoint({
    required this.label,
    required this.workouts,
    required this.totalMinutes,
    required this.avgRpe,
    this.avgHeartRate,
    required this.totalDistanceKm,
  });

  final String label;
  final int workouts;
  final int totalMinutes;
  final double avgRpe;
  final int? avgHeartRate;
  final double totalDistanceKm;

  factory ProgressPoint.fromJson(Map<String, dynamic> json) => ProgressPoint(
        label: json['label'] as String,
        workouts: json['workouts'] as int,
        totalMinutes: json['total_minutes'] as int,
        avgRpe: (json['avg_rpe'] as num).toDouble(),
        avgHeartRate: json['avg_heart_rate'] as int?,
        totalDistanceKm: (json['total_distance_km'] as num).toDouble(),
      );
}
