import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ResultCard extends StatelessWidget {
  final String title;
  final String label;
  final String textGreet;
  const ResultCard({
    super.key,
    required this.textGreet,
    required this.title,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            child: SizedBox(
              width: 20,
              height: 50,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(150, 158, 158, 158),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -10,
            child: SizedBox(
              width: 40,
              height: 40,
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(148, 0, 120, 150),
                      spreadRadius: 10,
                      blurRadius: 40,
                      offset: Offset(0, 0),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(30),
                  color: const Color.fromARGB(255, 3, 97, 134),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Positioned(
              child: ClipPath(
                clipper: BottomRoundedRectClipper(),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                    top: 20,
                    left: 20,
                    right: 20,
                    bottom: 20,
                  ),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color.fromARGB(0, 158, 158, 158),
                        Color.fromARGB(255, 136, 136, 136),
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        spacing: 10,
                        children: [
                          Icon(
                            LucideIcons.brainCircuit,
                            fontWeight: FontWeight.w600,
                            color: const Color.fromARGB(255, 61, 61, 61),
                          ),

                          Text(
                            "Rekomendasi",
                            style: TextStyle(
                              fontFamily: "Montserrat",
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: const Color.fromARGB(255, 73, 73, 73),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.0),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),

                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),

                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.22),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.25),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                spacing: 10,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        label,
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontFamily: "Montserrat",
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: const Color.fromARGB(
                                            255,
                                            65,
                                            65,
                                            65,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  Center(
                                    child: Text(
                                      '"$textGreet"',
                                      style: TextStyle(
                                        fontFamily: "Montserrat",
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: const Color.fromARGB(
                                          255,
                                          82,
                                          82,
                                          82,
                                        ),
                                      ),
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
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

class BottomRoundedRectClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const double radius = 20; // Radius sudut luar kartu

    // Konfigurasi Cekungan (Notch)
    const double notchWidth =
        100; // Lebar cekungan (lebih lebar dari tombol 120)
    const double notchDepth =
        20; // Kedalaman cekungan (sedikit lebih tinggi dari tombol 48)
    const double notchRadius = 16; // Kelengkungan sudut-sudut dalam cekungan

    final path = Path();
    final double w = size.width;
    final double h = size.height;

    // --- MULAI GAMBAR KARTU ---

    // 1. Garis Kiri Bawah (Start point: kiri cekungan)
    path.moveTo(0, h - radius);

    // 2. Sudut Kiri Atas
    path.lineTo(0, radius);
    path.quadraticBezierTo(0, 0, radius, 0);

    // 3. Sudut Kanan Atas
    path.lineTo(w - radius, 0);
    path.quadraticBezierTo(w, 0, w, radius);

    // 4. Garis Sisi Kanan ke Bawah
    path.lineTo(w, h - radius);
    path.quadraticBezierTo(w, h, w - radius, h);

    // --- MULAI MEMBUAT CEKUNGAN (Dari Kanan ke Kiri) ---

    // Titik referensi sisi kanan cekungan
    final double rightNotchX = (w / 2) + (notchWidth / 2);
    // Titik referensi sisi kiri cekungan
    final double leftNotchX = (w / 2) - (notchWidth / 2);
    // Titik Y teratas di dalam cekungan
    final double topNotchY = h - notchDepth;

    // 5. Garis bawah kanan menuju mulut cekungan
    path.lineTo(rightNotchX + notchRadius, h);

    // 6. Sudut membulat MASUK ke cekungan (Kanan Bawah)
    path.quadraticBezierTo(
      rightNotchX,
      h, // Control Point (Sudut siku)
      rightNotchX,
      h - notchRadius, // End Point (Mulai naik)
    );

    // 7. Garis vertikal NAIK (Dinding kanan cekungan)
    path.lineTo(rightNotchX, topNotchY + notchRadius);

    // 8. Sudut membulat DALAM (Kanan Atas)
    path.quadraticBezierTo(
      rightNotchX,
      topNotchY, // Control Point
      rightNotchX - notchRadius,
      topNotchY, // End Point
    );

    // 9. Garis horizontal DATAR (Atap cekungan)
    path.lineTo(leftNotchX + notchRadius, topNotchY);

    // 10. Sudut membulat DALAM (Kiri Atas)
    path.quadraticBezierTo(
      leftNotchX,
      topNotchY,
      leftNotchX,
      topNotchY + notchRadius,
    );

    // 11. Garis vertikal TURUN (Dinding kiri cekungan)
    path.lineTo(leftNotchX, h - notchRadius);

    // 12. Sudut membulat KELUAR dari cekungan (Kiri Bawah)
    path.quadraticBezierTo(leftNotchX, h, leftNotchX - notchRadius, h);

    // 13. Kembali ke garis bawah kiri & Sudut Kiri Bawah Utama
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
