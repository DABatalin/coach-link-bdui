class ConnectionRequest {
  const ConnectionRequest({
    required this.id,
    required this.athlete,
    required this.coach,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final ConnectionUser athlete;
  final ConnectionUser coach;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isRejected => status == 'rejected';

  factory ConnectionRequest.fromJson(Map<String, dynamic> json) {
    return ConnectionRequest(
      id: json['id'] as String,
      athlete: ConnectionUser.fromJson(json['athlete'] as Map<String, dynamic>),
      coach: ConnectionUser.fromJson(json['coach'] as Map<String, dynamic>),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }
}

class ConnectionUser {
  const ConnectionUser({
    required this.id,
    required this.login,
    required this.fullName,
  });

  final String id;
  final String login;
  final String fullName;

  factory ConnectionUser.fromJson(Map<String, dynamic> json) {
    return ConnectionUser(
      id: json['id'] as String,
      login: json['login'] as String,
      fullName: json['full_name'] as String,
    );
  }
}
