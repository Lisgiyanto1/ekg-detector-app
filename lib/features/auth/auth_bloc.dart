import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ekg_detector/features/auth/auth_error_mapper.dart';
import 'package:flutter_ekg_detector/features/auth/auth_event.dart';
import 'package:flutter_ekg_detector/features/auth/auth_repositorie.dart';
import 'package:flutter_ekg_detector/features/auth/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repo;

  AuthBloc(this.repo) : super(AuthUnauthenticated()) {
    on<AppStarted>(_onAppStarted);
    on<LoginWithGoogle>(_onGoogleLogin);
    on<RegisterWithEmail>(_onRegisterWithEmail);
    on<LoginWithEmail>(_onLoginWithEmail);
    on<LogoutRequested>(_onLogout);
  }

  void _onAppStarted(AppStarted event, Emitter<AuthState> emit) {
    final user = repo.currentUser;

    if (user != null) {
      emit(AuthAuthenticated(user));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onGoogleLogin(
    LoginWithGoogle event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());
      final user = await repo.signInWithGoogle();
      emit(AuthAuthenticated(user));
    } catch (_) {
      emit(AuthError('Login Google dibatalkan'));
    }
  }

  Future<void> _onRegisterWithEmail(
    RegisterWithEmail event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());
      final user = await repo.registerWithEmail(
        email: event.email,
        password: event.password,
      );
      emit(AuthAuthenticated(user));
    } catch (e) {
      final message = AuthErrorMapper.map(e);
      emit(AuthError(message));
    }
  }

  Future<void> _onLoginWithEmail(
    LoginWithEmail event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final user = await repo.loginWithEmail(
        email: event.email,
        password: event.password,
      );

      emit(AuthAuthenticated(user));
    } catch (e) {
      final message = AuthErrorMapper.map(e);
      emit(AuthError(message));
    }
  }

  Future<void> _onLogout(LogoutRequested event, Emitter<AuthState> emit) async {
    await repo.signOut();
    emit(AuthUnauthenticated());
  }
}
