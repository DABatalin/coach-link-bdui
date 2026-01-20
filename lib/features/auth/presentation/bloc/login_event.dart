sealed class LoginEvent {
  const LoginEvent();
}

class LoginSubmitted extends LoginEvent {
  const LoginSubmitted({
    required this.login,
    required this.password,
  });

  final String login;
  final String password;
}
