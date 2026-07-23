import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ekg_detector/features/auth/auth_bloc.dart';
import 'package:flutter_ekg_detector/features/auth/auth_state.dart';
import 'package:flutter_ekg_detector/features/scan/ekg_repository.dart';
import 'package:flutter_ekg_detector/features/scan/scan_bloc.dart';
import 'package:flutter_ekg_detector/features/scan/scan_event.dart';
import 'package:flutter_ekg_detector/screens/screen_one.dart';
import 'package:flutter_ekg_detector/screens/screen_splash.dart';
import 'package:flutter_ekg_detector/widgets/FloatingButtons.dart';
import 'package:flutter_ekg_detector/widgets/LogoutModal.dart';
import 'package:flutter_ekg_detector/widgets/dropDown.dart';
import 'package:flutter_ekg_detector/widgets/result_card.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ResultScreen extends StatefulWidget {
  final EkgRecommendation data;
  final String imagePath;

  const ResultScreen({super.key, required this.data, required this.imagePath});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _blur;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _scale = Tween<double>(
      begin: 1.0,
      end: 3.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _blur = Tween<double>(
      begin: 1.0,
      end: 3.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const expandHeight = 220.0;
    final String lowerUrgency = widget.data.urgency.toLowerCase();

    // Default: Rendah / Normal (Emerald Tone)
    Color statusColor = const Color(0xFF10B981);
    String text = "Hasil Sehat, Selamat Pertahankan dan Jaga Kesehatan Ya ....";
    List<Color> bgGradient = const [
      Color(0xFFECFDF5),
      Color(0xFFF4FBF7),
      Color(0xFFF4F5F7),
    ];

    if (lowerUrgency.contains("sedang")) {
      // Sedang (Amber Tone)
      statusColor = const Color(0xFFF59E0B);
      text = "Hasil Lumayan Sehat Tetap Perhatikan Pola Hidup Sehat.";
      bgGradient = const [
        Color(0xFFFFFBEB),
        Color(0xFFFFFBF0),
        Color(0xFFF4F5F7),
      ];
    } else if (lowerUrgency.contains("tinggi") ||
        lowerUrgency.contains("darurat") ||
        lowerUrgency.contains("bahaya")) {
      // Tinggi / Darurat (Red Tone)
      statusColor = const Color(0xFFF43F5E);
      text = "Hasil Bahaya. Harap Perhatikan Rekomendasi di Bawah ini";
      bgGradient = const [
        Color(0xFFFF1F2F2),
        Color(0xFFFFF1F1),
        Color(0xFFF4F5F7),
      ];
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: bgGradient,
          ),
        ),
        child: Stack(
          children: [
            CustomScrollView(
              slivers: <Widget>[
                // Header Gambar EKG
                SliverAppBar(
                  pinned: true,
                  floating: false,
                  automaticallyImplyLeading: false,
                  expandedHeight: expandHeight,
                  backgroundColor: Colors.black,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Padding(
                      padding: const EdgeInsets.only(left: 16, bottom: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedBuilder(
                            animation: _controller,
                            builder: (context, child) {
                              return Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: statusColor,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      spreadRadius: _scale.value,
                                      blurRadius: _blur.value,
                                      color: statusColor.withOpacity(0.8),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 10),
                          Text(
                            widget.data.urgency.toUpperCase(),
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(File(widget.imagePath), fit: BoxFit.cover),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Konten Utama
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 100),
                    child: Column(
                      children: [
                        // 1. Result Card
                        ResultCard(
                          title: widget.data.label,
                          label: widget.data.label,
                          textGreet: text,
                          urgency: widget.data.urgency,
                        ),

                        const SizedBox(height: 12),

                        // 2. Container Anjuran
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 24,
                                horizontal: 16,
                              ),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 12,
                                      bottom: 16,
                                    ),
                                    child: Row(
                                      children: const [
                                        Icon(
                                          Icons.medical_services_outlined,
                                          size: 26,
                                          color: Color(0xFF1E293B),
                                        ),
                                        SizedBox(width: 12),
                                        Text(
                                          "Anjuran",
                                          style: TextStyle(
                                            color: Color(0xFF1E293B),
                                            fontFamily: "Montserrat",
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  CustomDropdownCard(
                                    iconcheck: LucideIcons.checkCircle,
                                    title: const Text(
                                      "Tindak Lanjut",
                                      style: TextStyle(
                                        fontFamily: "Montserrat",
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                    recommendation: widget.data.treatment,
                                  ),
                                  const SizedBox(height: 12),
                                  CustomDropdownCard(
                                    iconcheck: LucideIcons.checkCircle,
                                    title: const Text(
                                      "Rekomendasi Obat",
                                      style: TextStyle(
                                        fontFamily: "Montserrat",
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                    recommendation: widget.data.medicine,
                                  ),
                                  const SizedBox(height: 12),
                                  CustomDropdownCard(
                                    iconcheck: LucideIcons.checkCircle,
                                    title: const Text(
                                      "Pencegahan",
                                      style: TextStyle(
                                        fontFamily: "Montserrat",
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                    recommendation: widget.data.prevention,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Floating Navigation
            GlassFloatingMenu(
              mode: FloatingMenuMode.result,
              onPrimaryAction: () {
                final scanBloc = context.read<ScanBloc>();
                scanBloc.add(ResetScan());
                scanBloc.add(LoadStatistics());

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
      ),
    );
  }
}
