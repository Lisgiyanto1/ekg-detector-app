import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ekg_detector/features/auth/auth_bloc.dart';
import 'package:flutter_ekg_detector/features/auth/auth_event.dart';
import 'package:flutter_ekg_detector/features/auth/auth_state.dart';
import 'package:flutter_ekg_detector/features/scan/scan_bloc.dart';
import 'package:flutter_ekg_detector/features/scan/scan_event.dart';
import 'package:flutter_ekg_detector/features/scan/scan_state.dart';
import 'package:flutter_ekg_detector/screens/screen_splash.dart';
import 'package:flutter_ekg_detector/widgets/LogoutModal.dart';
import 'package:flutter_ekg_detector/widgets/precentageCard.dart';

import '../widgets/FloatingButtons.dart';
import '../widgets/InfoCard.dart';

class ScreenOne extends StatefulWidget {
  const ScreenOne({super.key});

  // Helper static method untuk membuat transisi halaman Ease In & Out secara halus
  static Route createEaseInOutRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          const ScreenOne(),
      transitionDuration: const Duration(milliseconds: 400),
      reverseTransitionDuration: const Duration(milliseconds: 350),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        );

        // Kombinasi transisi Fade (memudar) dan sedikit Scale (skala membesar halus)
        return FadeTransition(
          opacity: curvedAnimation,
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.96,
              end: 1.0,
            ).animate(curvedAnimation),
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<ScreenOne> createState() => _ScreenOneState();
}

class _ScreenOneState extends State<ScreenOne> {
  @override
  void initState() {
    super.initState();
    context.read<ScanBloc>().add(LoadStatistics());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      if (state is AuthAuthenticated) {
                        return HealthInfoCard(
                          user: state.user,
                          onLogout: () {
                            context.read<AuthBloc>().add(LogoutRequested());
                          },
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  const SizedBox(height: 20),
                  BlocBuilder<ScanBloc, ScanState>(
                    builder: (context, state) {
                      if (state is ScanLoading || state is ScanInitial) {
                        // Return skeleton while loading or initial
                        return const PercentageCardSkeleton();
                      }

                      if (state is ScanStatisticsLoaded) {
                        return PercentageCard(
                          percentages: state.percentages,
                          total: state.total,
                        );
                      }

                      // Default fallback to reload if state was wiped
                      return const PercentageCardSkeleton();
                    },
                  ),
                ],
              ),
            ),
          ),
          GlassFloatingMenu(
            mode: FloatingMenuMode.home,
            onPrimaryAction: () {
              context.read<ScanBloc>().add(ResetScan());
              // Menerapkan transisi kustom kustom kearah ScreenOne
              Navigator.pushAndRemoveUntil(
                context,
                ScreenOne.createEaseInOutRoute(),
                (route) => false,
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
                      MaterialPageRoute(
                        builder: (_) => const SplashScreen(isLogout: true),
                      ),
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

// =========================================================================
// WIDGET SKELETON LOADER DENGAN ANIMASI SHIMMER MURNI FLUTTER (NO EXTERNAL PACKAGE)
// =========================================================================
class PercentageCardSkeleton extends StatefulWidget {
  const PercentageCardSkeleton({super.key});

  @override
  State<PercentageCardSkeleton> createState() => _PercentageCardSkeletonState();
}

class _PercentageCardSkeletonState extends State<PercentageCardSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    // Menggerakkan gradasi warna horizontal secara berkelanjutan
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Container(
          height: 380.0,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6), // Base abu-abu terang
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Placeholder Judul Atas
              _buildShimmerBlock(width: 160, height: 20, borderRadius: 6),
              const SizedBox(height: 8),
              _buildShimmerBlock(width: 100, height: 14, borderRadius: 4),
              const SizedBox(height: 32),

              // 2. Placeholder Area Grafik Lingkaran (Center)
              Center(
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: _shimmerGradient(),
                  ),
                ),
              ),
              const Spacer(),

              // 3. Placeholder Keterangan/Legend bawah (Baris 1)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildShimmerBlock(width: 110, height: 16, borderRadius: 4),
                  _buildShimmerBlock(width: 50, height: 16, borderRadius: 4),
                ],
              ),
              const SizedBox(height: 12),

              // 4. Placeholder Keterangan/Legend bawah (Baris 2)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildShimmerBlock(width: 85, height: 16, borderRadius: 4),
                  _buildShimmerBlock(width: 50, height: 16, borderRadius: 4),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper untuk membuat box block shimmer
  Widget _buildShimmerBlock({
    required double width,
    required double height,
    required double borderRadius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: _shimmerGradient(),
      ),
    );
  }

  // Membuat pergeseran warna gradasi linear berdasarkan value controller animasi
  LinearGradient _shimmerGradient() {
    return LinearGradient(
      colors: const [Color(0xFFE5E7EB), Color(0xFFF3F4F6), Color(0xFFE5E7EB)],
      stops: const [0.1, 0.5, 0.9],
      begin: Alignment(-1.0 + (_shimmerController.value * 2), -0.3),
      end: Alignment(1.0 + (_shimmerController.value * 2), 0.3),
    );
  }
}
