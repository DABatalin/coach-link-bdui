sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class Authenticated extends AuthState {
  const Authenticated({
    required this.userId,
    required this.login,
    required this.fullName,
    required this.role,
  });

  final String userId;
  final String login;
  final String fullName;
  final String role;

  bool get isCoach => role == 'coach';
  bool get isAthlete => role == 'athlete';
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}
