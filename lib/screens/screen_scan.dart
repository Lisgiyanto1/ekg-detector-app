import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ekg_detector/features/scan/scan_bloc.dart';
import 'package:flutter_ekg_detector/features/scan/scan_event.dart';
import 'package:flutter_ekg_detector/features/scan/scan_state.dart';
import 'package:flutter_ekg_detector/screens/screen_result.dart';
import 'package:flutter_ekg_detector/widgets/alert_scan_error.dart';
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

  bool _isDelayingAnimation = false;

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

  /// Fungsi Scanner yang dimodifikasi untuk BLoC
  Future<void> _handleScan(BuildContext context) async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      final XFile image = await _controller!.takePicture();

      // KIRIM EVENT KE BLOC
      context.read<ScanBloc>().add(AnalyzeImage(image.path));
    } catch (e) {
      debugPrint("Error capture: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double scanWidth = size.width * 0.75;
    final double scanHeight = size.width * 1.05;
    final double scanLeft = (size.width - scanWidth) / 2;
    final double scanTop = (size.height - scanHeight) / 2;

    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocConsumer<ScanBloc, ScanState>(
        listener: (context, state) async {
          // Ubah jadi async
          if (state is ScanSuccess) {
            // 1. Saat data sukses didapat, paksa animasi tetap tampil
            setState(() {
              _isDelayingAnimation = true;
            });

            // 2. Tahan selama durasi animasi (misal 3 detik)
            await Future.delayed(const Duration(seconds: 3));

            if (!mounted) return;

            // 3. Matikan animasi paksa sebelum navigasi
            setState(() {
              _isDelayingAnimation = false;
            });

            // 4. Navigasi ke ResultScreen
            // Gunakan 'await' agar kode di bawahnya jalan setelah user kembali (back)
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ResultScreen(
                  data: state.result,
                  imagePath: state.imagePath,
                ),
              ),
            );

            // Opsional: Reset Bloc agar bersih saat kembali
            // context.read<ScanBloc>().add(InitModel());
          } else if (state is ScanError) {
            // Pastikan animasi mati jika error
            setState(() {
              _isDelayingAnimation = false;
            });
            AlertScanError.show(context, state.message);
          }
        },
        builder: (context, state) {
          // LOGIKA PENTING:
          // Tampilkan animasi jika Bloc sedang Loading ATAU kita sedang menahan (Delaying)
          bool showLottie = state is ScanLoading || _isDelayingAnimation;

          return FutureBuilder<void>(
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

                    /// LAYER 2: ANIMASI LOTTIE
                    // Gunakan variabel showLottie yang baru
                    if (showLottie)
                      Positioned(
                        left: scanLeft,
                        top: scanTop,
                        width: scanWidth,
                        height: scanHeight,
                        child: Lottie.asset(
                          'assets/lottie/scanner.json',
                          fit: BoxFit.fill,
                          repeat: true, // Biarkan looping selama delay
                        ),
                      ),

                    /// LAYER 3: OVERLAY POLYGON
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
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
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
                    // Sembunyikan hint text jika animasi sedang jalan
                    if (!showLottie)
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
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
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
                          // Disable tombol jika sedang animasi
                          onTap: showLottie ? null : () => _handleScan(context),
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                            ),
                            child: Center(
                              child: showLottie
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
          );
        },
      ),
    );
  }
}

// ... Class ScannerOverlayPainter TETAP SAMA seperti kode Anda ...

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
