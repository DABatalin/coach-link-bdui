sealed class RegisterState {
  const RegisterState();
}

class RegisterInitial extends RegisterState {
  const RegisterInitial();
}

class RegisterLoading extends RegisterState {
  const RegisterLoading();
}

class RegisterSuccess extends RegisterState {
  const RegisterSuccess();
}

class RegisterFailure extends RegisterState {
  const RegisterFailure({
    required this.message,
    this.fieldErrors = const {},
  });

  final String message;
  final Map<String, String> fieldErrors;
}
