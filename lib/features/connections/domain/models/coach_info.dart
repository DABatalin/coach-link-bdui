class CoachInfo {
  const CoachInfo({
    required this.id,
    required this.login,
    required this.fullName,
    required this.connectedAt,
  });

  final String id;
  final String login;
  final String fullName;
  final DateTime connectedAt;

  factory CoachInfo.fromJson(Map<String, dynamic> json) {
    return CoachInfo(
      id: json['id'] as String,
      login: json['login'] as String,
      fullName: json['full_name'] as String,
      connectedAt: DateTime.parse(json['connected_at'] as String),
    );
  }
}
