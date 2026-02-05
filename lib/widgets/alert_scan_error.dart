import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AlertScanError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const AlertScanError({
    super.key,
    required this.message,
    required this.onRetry,
  });

  /// Helper static method agar pemanggilannya singkat di ScanScreen
  static void show(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false, // User harus klik tombol untuk tutup
      builder: (context) => AlertScanError(
        message: message,
        onRetry: () => Navigator.pop(context),
      ),
    );
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
            // Icon Error
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

            // Title
            const Text(
              "Gagal Memindai",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),

            // Message (Pesan dari Repository)
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 24),

            // Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Coba Lagi"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
