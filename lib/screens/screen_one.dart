import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ekg_detector/features/auth/auth_bloc.dart';
import 'package:flutter_ekg_detector/features/auth/auth_event.dart';
import 'package:flutter_ekg_detector/features/auth/auth_state.dart';
import 'package:flutter_ekg_detector/screens/screen_splash.dart';
import 'package:flutter_ekg_detector/widgets/LogoutModal.dart';

import '../widgets/FloatingButtons.dart';
import '../widgets/InfoCard.dart';
import 'screen_two.dart';

class ScreenOne extends StatelessWidget {
  const ScreenOne({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          /// ================= CONTENT AREA =================
          SafeArea(
            child: Padding(
              // ⬇️ Bottom padding BESAR agar area konten lega
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  /// ================= USER INFO =================
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      if (state is AuthAuthenticated) {
                        return HealthInfoCard(
                          user: state.user,
                          onLogout: () {
                            debugPrint('[UI] Logout pressed');
                            context.read<AuthBloc>().add(LogoutRequested());
                          },
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),

                  const SizedBox(height: 32),

                  /// ================= CENTER TEXT =================
                  const Expanded(
                    child: Center(
                      child: Text(
                        "INI Screen 1",
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// ================= FLOATING MENU (FIXED) =================
          GlassFloatingMenu(
            mode: FloatingMenuMode.home,
            onPrimaryAction: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ScreenTwo()),
              );
            },
            onLogout: () {
              showDialog(
                context: context,
                barrierDismissible: true,
                builder: (_) => LogoutConfirmationDialog(
                  onCancel: () => Navigator.pop(context),
                  onConfirm: () {
                    context.read<AuthBloc>().add(LogoutRequested());
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const SplashScreen(isLogout: true,)),
                      (_) => false,
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
