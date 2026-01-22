import 'package:flutter/material.dart';
import 'package:flutter_ekg_detector/screens/screen_scan.dart';
import 'package:lucide_icons/lucide_icons.dart';

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
              // Beri padding bawah agar card tidak terpotong habis oleh tombol
              // Padding ini harus <= notchDepth di clipper
              padding: const EdgeInsets.only(bottom: 0),
              child: ClipPath(
                clipper: BottomRoundedRectClipper(),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    32,
                    20,
                    60,
                  ), // Bottom padding lebih besar untuk ruang cekungan
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
                                      color: Colors.greenAccent.withOpacity(
                                        0.6,
                                      ),
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

                      // Spacing tambahan agar ilustrasi tidak terlalu dekat dengan cekungan
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
                  // UPDATE BAGIAN INI:
                  onPressed: () {
                    // 1. Tutup Modal
                    Navigator.pop(context);

                    // 2. Buka Screen Kamera
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

/// ===== CLIPPER BARU: ROUNDED RECTANGLE NOTCH =====
class BottomRoundedRectClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const double radius = 24; // Radius sudut luar kartu

    // Konfigurasi Cekungan (Notch)
    const double notchWidth =
        140; // Lebar cekungan (lebih lebar dari tombol 120)
    const double notchDepth =
        55; // Kedalaman cekungan (sedikit lebih tinggi dari tombol 48)
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
