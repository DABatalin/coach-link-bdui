sealed class RegisterEvent {
  const RegisterEvent();
}

class RegisterSubmitted extends RegisterEvent {
  const RegisterSubmitted({
    required this.login,
    required this.email,
    required this.password,
    required this.fullName,
    required this.role,
  });

  final String login;
  final String email;
  final String password;
  final String fullName;
  final String role;
}
