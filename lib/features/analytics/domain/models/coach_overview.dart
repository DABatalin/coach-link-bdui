class AthleteOverviewItem {
  const AthleteOverviewItem({
    required this.athleteId,
    required this.athleteFullName,
    required this.athleteLogin,
    required this.totalWorkouts,
    required this.completionRate,
    required this.avgRpe,
  });

  final String athleteId;
  final String athleteFullName;
  final String athleteLogin;
  final int totalWorkouts;
  final double completionRate;
  final double avgRpe;

  factory AthleteOverviewItem.fromJson(Map<String, dynamic> json) =>
      AthleteOverviewItem(
        athleteId: json['athlete_id'] as String,
        athleteFullName: json['athlete_full_name'] as String,
        athleteLogin: json['athlete_login'] as String,
        totalWorkouts: json['total_workouts'] as int,
        completionRate: (json['completion_rate'] as num).toDouble(),
        avgRpe: (json['avg_rpe'] as num).toDouble(),
      );
}

class CoachOverview {
  const CoachOverview({
    required this.totalAthletes,
    required this.totalWorkouts,
    required this.avgCompletionRate,
    required this.athletes,
  });

  final int totalAthletes;
  final int totalWorkouts;
  final double avgCompletionRate;
  final List<AthleteOverviewItem> athletes;

  factory CoachOverview.fromJson(Map<String, dynamic> json) => CoachOverview(
        totalAthletes: json['total_athletes'] as int,
        totalWorkouts: json['total_workouts'] as int,
        avgCompletionRate: (json['avg_completion_rate'] as num).toDouble(),
        athletes: (json['athletes'] as List)
            .map((e) => AthleteOverviewItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
