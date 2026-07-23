import 'package:flutter/material.dart';

class ConcaveBottomLeftClipper extends CustomClipper<Path> {
  final double cutoutWidth;
  final double cutoutHeight;

  ConcaveBottomLeftClipper({
    required this.cutoutWidth,
    required this.cutoutHeight,
  });

  @override
  Path getClip(Size size) {
    const radius = 24.0; // Radius untuk sudut luar card
    const notchRadius = 16.0; // Radius untuk sudut dalam potongan (lekukan)

    final path = Path();

    // 1. Mulai dari Kiri Atas
    path.moveTo(0, radius);
    path.quadraticBezierTo(0, 0, radius, 0);

    // 2. Garis ke Kanan Atas
    path.lineTo(size.width - radius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, radius);

    // 3. Garis ke Kanan Bawah
    path.lineTo(size.width, size.height - radius);
    path.quadraticBezierTo(
      size.width,
      size.height,
      size.width - radius,
      size.height,
    );

    // 4. Garis ke Kiri Bawah (Berhenti sebelum lekukan potongan dimulai)
    path.lineTo(cutoutWidth + notchRadius, size.height);

    // 5. Lengkungan Masuk (Sudut Kanan Bawah area potongan - Concave)
    path.quadraticBezierTo(
      cutoutWidth,
      size.height,
      cutoutWidth,
      size.height - notchRadius,
    );

    // 6. Garis Naik (Dinding kanan area potongan)
    path.lineTo(cutoutWidth, size.height - cutoutHeight + notchRadius);

    // 7. Lengkungan Keluar (Sudut Kanan Atas area potongan - Convex)
    path.quadraticBezierTo(
      cutoutWidth,
      size.height - cutoutHeight,
      cutoutWidth - notchRadius,
      size.height - cutoutHeight,
    );

    // ==========================================
    // PERBAIKAN DI SINI: SUDUT KIRI ATAS POTONGAN
    // ==========================================
    
    // 8. Garis Lurus ke Kiri (Berhenti sebelum mentok ke ujung kiri layar)
    path.lineTo(radius, size.height - cutoutHeight);

    // 9. Lengkungan di Sudut Kiri (Pertemuan atap potongan dengan sisi kiri card)
    path.quadraticBezierTo(
      0, 
      size.height - cutoutHeight, // Titik sudut bayangan (tajam)
      0, 
      size.height - cutoutHeight - radius, // Titik akhir lengkungan (naik ke atas)
    );

    // 10. Garis naik menutup path ke titik awal (Kiri Atas)
    path.lineTo(0, radius);

    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant ConcaveBottomLeftClipper oldClipper) {
    return oldClipper.cutoutWidth != cutoutWidth ||
        oldClipper.cutoutHeight != cutoutHeight;
  }
}