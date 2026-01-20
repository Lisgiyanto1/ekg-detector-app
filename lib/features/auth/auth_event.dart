import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthState {}

class AuthLoading extends AuthState {}

class AuthUnauthenticated extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;
  AuthAuthenticated(this.user);
}

class AuthEmailLinkSent extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}
