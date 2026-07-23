import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AlertScanTimeout extends StatefulWidget {
  final String message;

  const AlertScanTimeout({super.key, required this.message});

  static void show(BuildContext context, String message) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: "AlertScanTimeout",
      // Menggunakan transitionDuration tunggal yang kompatibel untuk masuk & keluar
      transitionDuration: const Duration(milliseconds: 450),
      pageBuilder: (context, animation, secondaryAnimation) {
        return AlertScanTimeout(message: message);
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        // Pengecekan status ini tetap berfungsi secara dinamis saat dialog ditutup
        final curve = animation.status == AnimationStatus.reverse
            ? Curves.bounceIn
            : Curves.bounceOut;

        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: curve),
          child: child,
        );
      },
    );
  }

  @override
  State<AlertScanTimeout> createState() => _AlertScanTimeoutState();
}

class _AlertScanTimeoutState extends State<AlertScanTimeout> {
  Timer? _timer;
  int _secondsRemaining = 3;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        if (_secondsRemaining > 1) {
          setState(() {
            _secondsRemaining--;
          });
        } else {
          _timer?.cancel();
          Navigator.of(context).pop();
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
              offset: Offset(0.0, 10.0),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.alertTriangle,
                size: 40,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Gagal Memindai",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            Text(
              "Menutup otomatis dalam $_secondsRemaining detik...",
              style: const TextStyle(fontSize: 12, color: Colors.black38),
            ),
          ],
        ),
      ),
    );
  }
}
