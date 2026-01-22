import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with WidgetsBindingObserver {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;
    if (cameraController == null || !cameraController.value.isInitialized)
      return;

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      _controller = CameraController(
        cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      _initializeControllerFuture = _controller!.initialize().then((_) {
        if (!mounted) return;
        setState(() {});
        _controller!.lockCaptureOrientation(DeviceOrientation.portraitUp);
      });
    } catch (e) {
      debugPrint("Error initializing camera: $e");
    }
  }

  /// Fungsi Scanner
  Future<void> _handleScan() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    setState(() => _isScanning = true);

    try {
      // Simulasi delay scan 2 detik
      await Future.delayed(const Duration(seconds: 2));
      final XFile image = await _controller!.takePicture();

      if (!mounted) return;
      setState(() => _isScanning = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Captured: ${image.path}"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      debugPrint("Error: $e");
      if (mounted) setState(() => _isScanning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // 1. TENTUKAN UKURAN & POSISI SECARA MATEMATIS
    // Ini memastikan Lottie dan Polygon punya koordinat pixel yang 100% sama.
    final double scanWidth = size.width * 0.75; // Lebar 75% layar
    final double scanHeight = size.width * 1.05; // Tinggi proporsional

    // Hitung titik pojok kiri atas (x, y) agar kotak berada persis di tengah
    final double scanLeft = (size.width - scanWidth) / 2;
    final double scanTop = (size.height - scanHeight) / 2;

    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              _controller != null &&
              _controller!.value.isInitialized) {
            return Stack(
              fit: StackFit.expand,
              children: [
                /// LAYER 1: KAMERA
                CameraPreview(_controller!),

                /// LAYER 2: ANIMASI LOTTIE (Posisi Presisi)
                // Menggunakan Positioned dengan koordinat yang sama persis dengan Painter
                if (_isScanning)
                  Positioned(
                    left: scanLeft,
                    top: scanTop,
                    width: scanWidth,
                    height: scanHeight,
                    child: Lottie.asset(
                      'assets/lottie/scanner.json',
                      // BoxFit.fill memaksa animasi melebar ke seluruh sudut kotak
                      fit: BoxFit.fill,
                      repeat: true,
                    ),
                  ),

                /// LAYER 3: OVERLAY POLYGON (Painter)
                CustomPaint(
                  painter: ScannerOverlayPainter(
                    scanWidth: scanWidth,
                    scanHeight: scanHeight,
                  ),
                  child: Container(),
                ),

                /// LAYER 4: HEADER
                Positioned(
                  top: MediaQuery.of(context).padding.top + 10,
                  left: 0,
                  right: 0,
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      const Spacer(),
                      const Text(
                        "Scan Grafik Elektrokardiogram",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                /// LAYER 5: HINT TEXT
                if (!_isScanning)
                  Positioned(
                    bottom: 160,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "Posisikan dengan presisi pada seluruh sisi objek",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                    ),
                  ),

                /// LAYER 6: TOMBOL SCAN
                Positioned(
                  bottom: 50,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: _isScanning ? null : _handleScan,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                        child: Center(
                          child: _isScanning
                              ? const SizedBox(
                                  width: 30,
                                  height: 30,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3,
                                  ),
                                )
                              : Container(
                                  width: 60,
                                  height: 60,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    LucideIcons.scan,
                                    color: Colors.black,
                                    size: 30,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }
        },
      ),
    );
  }
}

/// ===== CUSTOM PAINTER =====
class ScannerOverlayPainter extends CustomPainter {
  final double scanWidth;
  final double scanHeight;

  ScannerOverlayPainter({required this.scanWidth, required this.scanHeight});

  @override
  void paint(Canvas canvas, Size size) {
    // Perhitungan yang SAMA PERSIS dengan di build()
    final double left = (size.width - scanWidth) / 2;
    final double top = (size.height - scanHeight) / 2;
    final double right = left + scanWidth;
    final double bottom = top + scanHeight;
    const double radius = 20.0;

    // 1. Background Gelap (Bolong Tengah)
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final cutoutPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(left, top, right, bottom),
          const Radius.circular(radius),
        ),
      );

    final path = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );

    canvas.drawPath(path, Paint()..color = Colors.black.withOpacity(0.6));

    // 2. Border Polygon Biru
    final paintBorder = Paint()
      ..color = Colors.blueAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    final double cornerLength = 30;
    final pathBorder = Path();

    // Kiri Atas
    pathBorder.moveTo(left, top + cornerLength);
    pathBorder.lineTo(left, top);
    pathBorder.lineTo(left + cornerLength, top);
    // Kanan Atas
    pathBorder.moveTo(right - cornerLength, top);
    pathBorder.lineTo(right, top);
    pathBorder.lineTo(right, top + cornerLength);
    // Kanan Bawah
    pathBorder.moveTo(right, bottom - cornerLength);
    pathBorder.lineTo(right, bottom);
    pathBorder.lineTo(right - cornerLength, bottom);
    // Kiri Bawah
    pathBorder.moveTo(left + cornerLength, bottom);
    pathBorder.lineTo(left, bottom);
    pathBorder.lineTo(left, bottom - cornerLength);

    canvas.drawPath(pathBorder, paintBorder);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
