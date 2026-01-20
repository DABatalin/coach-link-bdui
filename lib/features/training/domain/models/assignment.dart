class AssignmentListItem {
  const AssignmentListItem({
    required this.id,
    required this.planId,
    required this.title,
    required this.scheduledDate,
    required this.status,
    required this.isOverdue,
    required this.hasReport,
    required this.assignedAt,
    this.completedAt,
    this.athleteId,
    this.athleteFullName,
    this.athleteLogin,
    this.coachFullName,
    this.coachLogin,
  });

  final String id;
  final String planId;
  final String title;
  final DateTime scheduledDate;
  final String status;
  final bool isOverdue;
  final bool hasReport;
  final DateTime assignedAt;
  final DateTime? completedAt;
  final String? athleteId;
  final String? athleteFullName;
  final String? athleteLogin;
  final String? coachFullName;
  final String? coachLogin;

  factory AssignmentListItem.fromJson(Map<String, dynamic> json) {
    return AssignmentListItem(
      id: json['id'] as String,
      planId: json['plan_id'] as String,
      title: json['title'] as String,
      scheduledDate: DateTime.parse(json['scheduled_date'] as String),
      status: json['status'] as String,
      isOverdue: json['is_overdue'] as bool? ?? false,
      hasReport: json['has_report'] as bool? ?? false,
      assignedAt: DateTime.parse(json['assigned_at'] as String),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      athleteId: json['athlete_id'] as String?,
      athleteFullName: json['athlete_full_name'] as String?,
      athleteLogin: json['athlete_login'] as String?,
      coachFullName: json['coach_full_name'] as String?,
      coachLogin: json['coach_login'] as String?,
    );
  }
}

class AssignmentDetail {
  const AssignmentDetail({
    required this.id,
    required this.planId,
    required this.title,
    required this.description,
    required this.scheduledDate,
    required this.status,
    required this.isOverdue,
    required this.hasReport,
    required this.assignedAt,
    this.completedAt,
    this.athleteId,
    this.athleteFullName,
    this.athleteLogin,
    this.coachFullName,
    this.coachLogin,
  });

  final String id;
  final String planId;
  final String title;
  final String description;
  final DateTime scheduledDate;
  final String status;
  final bool isOverdue;
  final bool hasReport;
  final DateTime assignedAt;
  final DateTime? completedAt;
  final String? athleteId;
  final String? athleteFullName;
  final String? athleteLogin;
  final String? coachFullName;
  final String? coachLogin;

  factory AssignmentDetail.fromJson(Map<String, dynamic> json) {
    return AssignmentDetail(
      id: json['id'] as String,
      planId: json['plan_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      scheduledDate: DateTime.parse(json['scheduled_date'] as String),
      status: json['status'] as String,
      isOverdue: json['is_overdue'] as bool? ?? false,
      hasReport: json['has_report'] as bool? ?? false,
      assignedAt: DateTime.parse(json['assigned_at'] as String),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      athleteId: json['athlete_id'] as String?,
      athleteFullName: json['athlete_full_name'] as String?,
      athleteLogin: json['athlete_login'] as String?,
      coachFullName: json['coach_full_name'] as String?,
      coachLogin: json['coach_login'] as String?,
    );
  }
}
