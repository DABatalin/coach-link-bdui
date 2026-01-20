class User {
  const User({
    required this.id,
    required this.login,
    required this.email,
    required this.fullName,
    required this.role,
    required this.createdAt,
  });

  final String id;
  final String login;
  final String email;
  final String fullName;
  final String role;
  final DateTime createdAt;

  bool get isCoach => role == 'coach';
  bool get isAthlete => role == 'athlete';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      login: json['login'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      role: json['role'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'login': login,
        'email': email,
        'full_name': fullName,
        'role': role,
        'created_at': createdAt.toIso8601String(),
      };
}
