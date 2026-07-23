import 'package:flutter/material.dart';
import 'package:flutter_ekg_detector/screens/screen_scan.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ScanModal extends StatelessWidget {
  const ScanModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        child: Stack(
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.none,
          children: [
            /// ===== 1. CARD BACKGROUND (DIPOTONG) =====
            Padding(
              padding: const EdgeInsets.only(bottom: 0),
              child: ClipPath(
                clipper: BottomRoundedRectClipper(),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 32, 20, 60),
                  decoration: const BoxDecoration(color: Color(0xFFE5E7EB)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      /// TITLE
                      RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                          ),
                          children: [
                            TextSpan(
                              text: 'Scan First',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(text: ' to get a\nRecommendation'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),

                      /// ILLUSTRATION
                      SizedBox(
                        height: 180,
                        width: 180,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 180,
                              height: 180,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Container(
                              width: 80,
                              height: 120,
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.blue.shade200),
                              ),
                              child: const Center(
                                child: Icon(
                                  LucideIcons.fileText,
                                  color: Colors.blueGrey,
                                ),
                              ),
                            ),
                            Positioned(
                              child: Container(
                                width: 2,
                                height: 140,
                                decoration: BoxDecoration(
                                  color: Colors.greenAccent,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.greenAccent.withOpacity(0.6),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 100,
                              height: 140,
                              child: CustomPaint(painter: _CornerPainter()),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),

            /// ===== 2. BUTTON OK =====
            Positioned(
              bottom: 0,
              child: SizedBox(
                width: 120,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ScanScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD1D5DB),
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "OK",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BottomRoundedRectClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const double radius = 24;
    const double notchWidth = 140;
    const double notchDepth = 55;
    const double notchRadius = 16;

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

class _CornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black54
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const double cornerSize = 10;

    canvas.drawPath(
      Path()
        ..moveTo(0, cornerSize)
        ..lineTo(0, 0)
        ..lineTo(cornerSize, 0),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width - cornerSize, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width, cornerSize),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height - cornerSize)
        ..lineTo(0, size.height)
        ..lineTo(cornerSize, size.height),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width - cornerSize, size.height)
        ..lineTo(size.width, size.height)
        ..lineTo(size.width, size.height - cornerSize),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}