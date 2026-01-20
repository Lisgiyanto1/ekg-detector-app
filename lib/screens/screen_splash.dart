import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ekg_detector/features/auth/auth_bloc.dart';
import 'package:flutter_ekg_detector/features/auth/auth_event.dart';
import 'package:flutter_ekg_detector/features/auth/auth_state.dart';
import 'package:flutter_ekg_detector/screens/screen_login.dart';
import 'package:flutter_ekg_detector/screens/screen_one.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  final bool isLogout;
  const SplashScreen({super.key, this.isLogout = false});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double progress = 0;
  bool _navigated = false;
  bool _handledEmailLink = false;

  Widget? _targetPage;

  @override
  void initState() {
    super.initState();

    // IMPORTANT: trigger AppStarted event
    context.read<AuthBloc>().add(AppStarted());

    _startLoading();
    _handleEmailLink();
  }

  /// ===============================
  /// PROGRESS BAR
  /// ===============================
  Future<void> _startLoading() async {
    for (int i = 0; i <= 100; i++) {
      await Future.delayed(const Duration(milliseconds: 20));

      if (!mounted) return;

      setState(() {
        progress = i / 100;
      });

      _tryNavigate();
    }
  }

  /// ===============================
  /// EMAIL LINK HANDLER
  /// ===============================
  Future<void> _handleEmailLink() async {
    if (_handledEmailLink) return;
    _handledEmailLink = true;

    final link = Uri.base.toString();
    debugPrint('[SPLASH] Incoming link: $link');

    if (FirebaseAuth.instance.isSignInWithEmailLink(link)) {
      debugPrint('[SPLASH] Detected email sign-in link');

      final email = await _getSavedEmail();

      if (email == null) {
        debugPrint('[SPLASH][ERROR] No saved email');
        return;
      }

      try {
        await FirebaseAuth.instance.signInWithEmailLink(
          email: email,
          emailLink: link,
        );

        debugPrint('[SPLASH] Email link login success');
      } catch (e) {
        debugPrint('[SPLASH][ERROR] Email link login failed');
        debugPrint(e.toString());
      }
    }
  }

  Future<String?> _getSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('emailForSignIn');
  }

  /// ===============================
  /// NAVIGATION GUARD
  /// ===============================
  void _tryNavigate() {
    if (_navigated) return;
    if (_targetPage == null) return;
    if (progress < 1.0) return;

    _navigated = true;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, __, ___) => _targetPage!,
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          debugPrint('[SPLASH] AuthState: ${state.runtimeType}');

          if (state is AuthAuthenticated) {
            _targetPage = const ScreenOne();
            _tryNavigate();
          }

          if (state is AuthUnauthenticated) {
            _targetPage = const RegisterScreen();
            _tryNavigate();
          }

          if (state is AuthError) {
            _targetPage = const RegisterScreen();
            _tryNavigate();
          }
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 160,
                height: 160,
                child: Lottie.asset(
                  widget.isLogout
                      ? 'assets/lottie/logout.json'
                      : 'assets/lottie/loading.json',
                  repeat: true,
                  animate: true,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) {
                    return const Icon(
                      Icons.health_and_safety,
                      size: 100,
                      color: Colors.white,
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Secure AI Platform',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  letterSpacing: 1.2,
                ),
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: 240,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
