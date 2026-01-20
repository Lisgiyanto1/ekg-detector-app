import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ekg_detector/features/auth/auth_bloc.dart';
import 'package:flutter_ekg_detector/features/auth/auth_state.dart';
import 'package:flutter_ekg_detector/screens/screen_login.dart';
import 'package:flutter_ekg_detector/screens/screen_one.dart';
import 'package:flutter_ekg_detector/widgets/LogoutModal.dart';

import '../widgets/FloatingButtons.dart';

class ScreenTwo extends StatelessWidget {
  const ScreenTwo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Center(
            child: Text("Ini adalah screen 2", style: TextStyle(fontSize: 24)),
          ),
          GlassFloatingMenu(
            mode: FloatingMenuMode.result,
            onPrimaryAction: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ScreenOne()),
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
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
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
