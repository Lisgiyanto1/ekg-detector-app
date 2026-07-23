import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ekg_detector/widgets/ConcaveBevelBottomLeft.dart';

class PercentageCard extends StatelessWidget {
  final Map<String, double> percentages;
  final int total;
  final bool isLoading; // Menambahkan flag loading kontrol manual

  const PercentageCard({
    super.key,
    required this.percentages,
    required this.total,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    // Skeleton aktif jika parameter isLoading bernilai true ATAU data percentages masih kosong
    final bool showSkeleton = isLoading || percentages.isEmpty;

    const diseaseColors = {
      "Normal": Color.fromARGB(255, 24, 155, 148),
      "STEMI Anterior": Color(0xFF9E9E9E),
      "STEMI-Anterior": Color(0xFF9E9E9E),
      "STEMI Inferior": Color(0xFF900000),
      "STEMI-Inferior": Color(0xFF900000),
      "STEMI Lateral": Color(0xFF000000),
      "STEMI-Lateral": Color(0xFF000000),
      "STEMI Septal": Color.fromARGB(255, 201, 64, 0),
      "STEMI-Septal": Color.fromARGB(255, 201, 64, 0),
      "Sinus Bradycardia": Color.fromARGB(255, 196, 199, 0),
      "Sinus-Bradycardia": Color.fromARGB(255, 196, 199, 0),
      "Sinus Tachycardia": Color.fromARGB(255, 99, 204, 0),
      "Sinus-Tachycardia": Color.fromARGB(255, 99, 204, 0),
    };

    Color getColor(String key) {
      if (diseaseColors.containsKey(key)) {
        return diseaseColors[key]!;
      }
      for (var entry in diseaseColors.entries) {
        if (entry.key.toLowerCase().replaceAll('-', ' ') ==
            key.toLowerCase().replaceAll('-', ' ')) {
          return entry.value;
        }
      }
      return Colors.grey;
    }

    const double cardHeight = 380.0;
    const double cutoutHeight = 50.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double currentWidth = constraints.maxWidth;
        final double cutoutWidth = currentWidth * 0.65;

        return SizedBox(
          height: cardHeight,
          width: currentWidth,
          child: Stack(
            children: [
              /// ===== BACKGROUND SHELL & GLASSMORPHISM (TETAP SAMA NYATA/SKELETON) =====
              ClipPath(
                clipper: ConcaveBottomLeftClipper(
                  cutoutWidth: cutoutWidth,
                  cutoutHeight: cutoutHeight,
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.grey.shade600.withOpacity(0.7),
                            Colors.transparent,
                          ],
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.grey.shade400.withOpacity(0.5),
                            Colors.transparent,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                    BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(color: Colors.transparent),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 20,
                        top: 20,
                        right: 20,
                        bottom: cutoutHeight + 10,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// ================= 1. HEADER ROW =================
                          showSkeleton
                              ? const _SkeletonPulse(
                                  child: Row(
                                    children: [
                                      _SkeletonBlock(width: 18, height: 18, borderRadius: 4),
                                      SizedBox(width: 8),
                                      _SkeletonBlock(width: 140, height: 16, borderRadius: 4),
                                    ],
                                  ),
                                )
                              : const Row(
                                  children: [
                                    Icon(
                                      Icons.signal_cellular_alt,
                                      size: 16,
                                      color: Colors.black87,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      "Disease Percentage",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                          const SizedBox(height: 16),

                          /// ================= 2. PIE CHART AREA =================
                          Expanded(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                if (showSkeleton) ...[
                                  /// Mock PieChart menggunakan fl_chart asli dengan warna netral skeleton
                                  _SkeletonPulse(
                                    child: PieChart(
                                      PieChartData(
                                        sectionsSpace: 0,
                                        centerSpaceRadius: 80,
                                        sections: [
                                          PieChartSectionData(value: 40, color: Colors.black12, radius: 18, showTitle: false),
                                          PieChartSectionData(value: 35, color: Colors.black26, radius: 18, showTitle: false),
                                          PieChartSectionData(value: 25, color: Colors.black12, radius: 18, showTitle: false),
                                        ],
                                      ),
                                    ),
                                  ),
                                  /// Teks tengah versi skeleton
                                  const Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _SkeletonPulse(child: _SkeletonBlock(width: 65, height: 12, borderRadius: 3)),
                                      SizedBox(height: 6),
                                      _SkeletonPulse(child: _SkeletonBlock(width: 45, height: 24, borderRadius: 4)),
                                      SizedBox(height: 8),
                                      _SkeletonPulse(child: _SkeletonBlock(width: 6, height: 6, shape: BoxShape.circle)),
                                    ],
                                  ),
                                ] else ...[
                                  /// PieChart Asli saat data termuat
                                  PieChart(
                                    PieChartData(
                                      sectionsSpace: 0,
                                      centerSpaceRadius: 80,
                                      sections: percentages.entries.map((e) {
                                        final color = getColor(e.key);
                                        return PieChartSectionData(
                                          value: e.value,
                                          color: color,
                                          radius: 18,
                                          showTitle: false,
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                  /// Teks tengah asli
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        "All Cases",
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Color.fromARGB(221, 8, 8, 8),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        "$total",
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                          color: Color.fromARGB(255, 0, 0, 0),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              /// ================= 3. LEGEND HORIZONTAL LIST =================
              Positioned(
                left: 20,
                bottom: 14,
                width: cutoutWidth - 20,
                height: 24,
                child: showSkeleton
                    ? _SkeletonPulse(
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          physics: const NeverScrollableScrollPhysics(),
                          children: List.generate(3, (index) {
                            // Menghasilkan panjang teks dummy bervariasi agar terlihat natural
                            final double dummyWidth = (index == 0) ? 60.0 : (index == 1) ? 85.0 : 50.0;
                            return Container(
                              margin: const EdgeInsets.only(right: 16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const _SkeletonBlock(width: 12, height: 12, borderRadius: 0),
                                  const SizedBox(width: 6),
                                  _SkeletonBlock(width: dummyWidth, height: 12, borderRadius: 3),
                                ],
                              ),
                            );
                          }),
                        ),
                      )
                    : ListView(
                        scrollDirection: Axis.horizontal,
                        children: percentages.entries.map((e) {
                          final color = getColor(e.key);
                          return Container(
                            margin: const EdgeInsets.only(right: 16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(width: 12, height: 12, color: color),
                                const SizedBox(width: 6),
                                Text(
                                  e.key,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// ===== HELPER WIDGETS UNTUK EFEK PULSE SKELETON (SELF-CONTAINED) =====

class _SkeletonPulse extends StatefulWidget {
  final Widget child;
  const _SkeletonPulse({required this.child});

  @override
  State<_SkeletonPulse> createState() => _SkeletonPulseState();
}

class _SkeletonPulseState extends State<_SkeletonPulse> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Menganimasikan opacity dari redup (0.3) ke agak terang (0.65) untuk simulasi shimmer premium
    return FadeTransition(
      opacity: Tween<double>(begin: 0.3, end: 0.65).animate(_controller),
      child: widget.child,
    );
  }
}

class _SkeletonBlock extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final BoxShape shape;

  const _SkeletonBlock({
    required this.width,
    required this.height,
    this.borderRadius = 0,
    this.shape = BoxShape.rectangle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.black38, // Kontras transparan pas di atas Glassmorphism background
        shape: shape,
        borderRadius: shape == BoxShape.rectangle ? BorderRadius.circular(borderRadius) : null,
      ),
    );
  }
}