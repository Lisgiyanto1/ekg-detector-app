abstract class AuthEvent {}

class AppStarted extends AuthEvent {}

class LoginWithGoogle extends AuthEvent {}

class RegisterWithEmail extends AuthEvent {
  final String email;
  final String password;

  RegisterWithEmail({
    required this.email,
    required this.password,
  });
}

class LoginWithEmail extends AuthEvent {
  final String email;
  final String password;

  LoginWithEmail({
    required this.email,
    required this.password,
  });
}

class LogoutRequested extends AuthEvent {}
