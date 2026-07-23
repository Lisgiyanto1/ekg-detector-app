import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ResultCard extends StatelessWidget {
  final String title;
  final String label;
  final String textGreet;
  final String urgency;

  const ResultCard({
    super.key,
    required this.textGreet,
    required this.title,
    required this.label,
    required this.urgency,
  });

  @override
  Widget build(BuildContext context) {
    // ==========================================
    // SKEMA WARNA BERDASARKAN TINGKAT URGENSI
    // ==========================================
    final String lowerUrgency = urgency.toLowerCase();

    // Default: Rendah / Normal (Emerald / Teal)
    List<Color> cardGradient = const [
      Color(0xFF059669), // Emerald 600
      Color(0xFF047857), // Emerald 700
      Color(0xFF065F46), // Emerald 800
    ];
    Color accentColor = const Color(0xFF10B981); // Emerald 500
    Color shadowColor = const Color(0xFF059669);

    if (lowerUrgency.contains("sedang")) {
      // Sedang (Amber / Yellow-Orange)
      cardGradient = const [
        Color(0xFFD97706), // Amber 600
        Color(0xFFB45309), // Amber 700
        Color(0xFF78350F), // Amber 900
      ];
      accentColor = const Color(0xFFF59E0B); // Amber 500
      shadowColor = const Color(0xFFD97706);
    } else if (lowerUrgency.contains("tinggi") ||
        lowerUrgency.contains("darurat") ||
        lowerUrgency.contains("bahaya")) {
      // Tinggi / Bahaya (Rose / Red)
      cardGradient = const [
        Color(0xFFE11D48), // Rose 600
        Color(0xFFBE123C), // Rose 700
        Color(0xFF881337), // Rose 900
      ];
      accentColor = const Color(0xFFF43F5E); // Rose 500
      shadowColor = const Color(0xFFE11D48);
    }

    return SizedBox(
      width: double.infinity,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // =========================================================
          // 1. LINGKARAN & GLOWING EFFECT CONNECTOR
          // =========================================================
          Positioned(
            bottom: -12,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor,
                boxShadow: [
                  BoxShadow(
                    color: shadowColor.withOpacity(0.6),
                    spreadRadius: 4,
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.8),
                    spreadRadius: 1,
                    blurRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),

          // =========================================================
          // 2. KARTU HASIL / REKOMENDASI
          // =========================================================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: shadowColor.withOpacity(0.35),
                    blurRadius: 20,
                    spreadRadius: 0,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: shadowColor.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: -2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipPath(
                clipper: BottomRoundedRectClipper(),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: cardGradient,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header Card
                      Row(
                        children: const [
                          Icon(
                            LucideIcons.brainCircuit,
                            size: 22,
                            color: Colors.white,
                          ),
                          SizedBox(width: 10),
                          Text(
                            "Rekomendasi",
                            style: TextStyle(
                              fontFamily: "Montserrat",
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),

                      // Inner Card Content
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              label,
                              style: const TextStyle(
                                fontFamily: "Montserrat",
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '"$textGreet"',
                              style: const TextStyle(
                                fontFamily: "Montserrat",
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Color(0xFF475569),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Clipper dengan Notch Bawah
class BottomRoundedRectClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const double radius = 20;
    const double notchWidth = 70;
    const double notchDepth = 16;
    const double notchRadius = 12;

    final path = Path();
    final double w = size.width;
    final double h = size.height;

    path.moveTo(0, h - radius);
    path.lineTo(0, radius);
    path.quadraticBezierTo(0, 0, radius, 0);

    path.lineTo(w - radius, 0);
    path.quadraticBezierTo(w, 0, w, radius);

    path.lineTo(w, h - radius);
    path.quadraticBezierTo(w, h, w - radius, h);

    final double rightNotchX = (w / 2) + (notchWidth / 2);
    final double leftNotchX = (w / 2) - (notchWidth / 2);
    final double topNotchY = h - notchDepth;

    path.lineTo(rightNotchX + notchRadius, h);
    path.quadraticBezierTo(
      rightNotchX,
      h,
      rightNotchX,
      h - notchRadius,
    );

    path.lineTo(rightNotchX, topNotchY + notchRadius);
    path.quadraticBezierTo(
      rightNotchX,
      topNotchY,
      rightNotchX - notchRadius,
      topNotchY,
    );

    path.lineTo(leftNotchX + notchRadius, topNotchY);
    path.quadraticBezierTo(
      leftNotchX,
      topNotchY,
      leftNotchX,
      topNotchY + notchRadius,
    );

    path.lineTo(leftNotchX, h - notchRadius);
    path.quadraticBezierTo(leftNotchX, h, leftNotchX - notchRadius, h);

    path.lineTo(radius, h);
    path.quadraticBezierTo(0, h, 0, h - radius);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}