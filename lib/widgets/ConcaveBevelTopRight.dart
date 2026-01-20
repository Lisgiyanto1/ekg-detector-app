import 'package:flutter/material.dart';

class ConcaveTopRightClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const double radius = 24;
    const double notchSize = 64;
    const double notchRadius = 16;

    final path = Path();

    path.moveTo(radius, 0);

    /// TOP
    path.lineTo(size.width - notchSize - notchRadius, 0);
    path.quadraticBezierTo(
      size.width - notchSize,
      0,
      size.width - notchSize,
      notchRadius,
    );

    /// CONCAVE NOTCH
    path.lineTo(size.width - notchSize, notchSize - notchRadius);
    path.quadraticBezierTo(
      size.width - notchSize,
      notchSize,
      size.width - notchSize + notchRadius,
      notchSize,
    );
    path.lineTo(size.width - notchRadius, notchSize);
    path.quadraticBezierTo(
      size.width,
      notchSize,
      size.width,
      notchSize + notchRadius,
    );

    /// RIGHT
    path.lineTo(size.width, size.height - radius);
    path.quadraticBezierTo(
      size.width,
      size.height,
      size.width - radius,
      size.height,
    );

    /// BOTTOM
    path.lineTo(radius, size.height);
    path.quadraticBezierTo(
      0,
      size.height,
      0,
      size.height - radius,
    );

    /// LEFT
    path.lineTo(0, radius);
    path.quadraticBezierTo(0, 0, radius, 0);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
