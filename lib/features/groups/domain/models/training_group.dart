class TrainingGroupSummary {
  const TrainingGroupSummary({
    required this.id,
    required this.name,
    required this.membersCount,
    required this.createdAt,
  });

  final String id;
  final String name;
  final int membersCount;
  final DateTime createdAt;

  factory TrainingGroupSummary.fromJson(Map<String, dynamic> json) {
    return TrainingGroupSummary(
      id: json['id'] as String,
      name: json['name'] as String,
      membersCount: json['members_count'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class TrainingGroupDetail {
  const TrainingGroupDetail({
    required this.id,
    required this.name,
    required this.members,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final List<GroupMember> members;
  final DateTime createdAt;
  final DateTime? updatedAt;

  factory TrainingGroupDetail.fromJson(Map<String, dynamic> json) {
    return TrainingGroupDetail(
      id: json['id'] as String,
      name: json['name'] as String,
      members: (json['members'] as List)
          .map((e) => GroupMember.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }
}

class GroupMember {
  const GroupMember({
    required this.athleteId,
    required this.login,
    required this.fullName,
    required this.addedAt,
  });

  final String athleteId;
  final String login;
  final String fullName;
  final DateTime addedAt;

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    return GroupMember(
      athleteId: json['athlete_id'] as String,
      login: json['login'] as String,
      fullName: json['full_name'] as String,
      addedAt: DateTime.parse(json['added_at'] as String),
    );
  }
}
