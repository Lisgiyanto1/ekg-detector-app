import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ekg_detector/features/scan/scan_bloc.dart';
import 'package:flutter_ekg_detector/features/scan/scan_event.dart';
import 'package:flutter_ekg_detector/features/scan/scan_state.dart';
import 'package:flutter_ekg_detector/screens/screen_result.dart';
import 'package:flutter_ekg_detector/widgets/alert_scan_timeout.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  bool _isAnalyzing = false;

  // Variabel kontrol animasi scanner line
  late AnimationController _animationController;

  // Variabel untuk kustomisasi ukuran frame kotak pemindai (bisa diatur user)
  double _scanWidthFactor = 0.8; // Default 80% dari lebar layar
  double _scanHeightFactor = 0.4; // Default 40% dari tinggi layar
  bool _showFrameSettings = false; // Toggle visibilitas slider pengaturan frame

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();

    // Inisialisasi controller animasi tanpa langsung menjalankannya (.repeat dihapus dari sini)
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;
    _controller = CameraController(
      cameras.first,
      ResolutionPreset.high,
      enableAudio: false,
    );
    _initializeControllerFuture = _controller!.initialize();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _captureAndAnalyze() async {
    if (_isAnalyzing ||
        _controller == null ||
        !_controller!.value.isInitialized) {
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _showFrameSettings =
          false; // Tutup pengaturan frame saat proses memindai dimulai
    });

    try {
      final image = await _controller!.takePicture();
      if (mounted) {
        context.read<ScanBloc>().add(AnalyzeImage(image.path));
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
        AlertScanTimeout.show(context, "Gagal mengambil gambar: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          context.read<ScanBloc>().add(LoadStatistics());
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: BlocListener<ScanBloc, ScanState>(
          listener: (context, state) {
            if (state is ScanLoading) {
              // Jalankan animasi laser HANYA saat state loading memindai aktif
              _animationController.repeat(reverse: true);
              setState(() {
                _isAnalyzing = true;
              });
            } else {
              // Hentikan dan reset posisi laser jika proses selesai/gagal
              _animationController.stop();
              _animationController.reset();
              setState(() {
                _isAnalyzing = false;
              });
            }

            if (state is ScanSuccess) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => ResultScreen(
                    data: state.result,
                    imagePath: state.imagePath,
                  ),
                ),
              );
            } else if (state is ScanError) {
              AlertScanTimeout.show(context, state.message);
            }
          },
          child: FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  _controller != null) {
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    CameraPreview(_controller!),

                    // Menggunakan AnimatedBuilder untuk me-rebuild gambar overlay secara smooth
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: ScannerOverlayPainter(
                            animationValue: _animationController.value,
                            scanWidthFactor: _scanWidthFactor,
                            scanHeightFactor: _scanHeightFactor,
                            showLaserLine:
                                _isAnalyzing, // Garis laser hanya tampil saat memindai
                          ),
                        );
                      },
                    ),

                    SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // --- TOP BAR BUTTONS ---
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.arrow_back,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    context.read<ScanBloc>().add(
                                      LoadStatistics(),
                                    );
                                    Navigator.pop(context);
                                  },
                                ),
                                // Tombol Pengaturan Kustomisasi Frame Kotak (Sembunyikan saat memindai)
                                if (!_isAnalyzing)
                                  IconButton(
                                    icon: Icon(
                                      _showFrameSettings
                                          ? Icons.close
                                          : Icons.tune,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _showFrameSettings =
                                            !_showFrameSettings;
                                      });
                                    },
                                  ),
                              ],
                            ),
                          ),

                          // --- SLIDER PANEL UNTUK ADJUST CUSTOM BOX FRAME ---
                          if (_showFrameSettings && !_isAnalyzing)
                            Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.75),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    "Sesuaikan Ukuran Kotak Deteksi",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.swap_horiz,
                                        color: Colors.white70,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        "Lebar: ",
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Expanded(
                                        child: Slider(
                                          value: _scanWidthFactor,
                                          min: 0.4,
                                          max: 0.95,
                                          activeColor: Colors.blueAccent,
                                          onChanged: (val) {
                                            setState(
                                              () => _scanWidthFactor = val,
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.swap_vert,
                                        color: Colors.white70,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        "Tinggi:",
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Expanded(
                                        child: Slider(
                                          value: _scanHeightFactor,
                                          min: 0.2,
                                          max: 0.65,
                                          activeColor: Colors.blueAccent,
                                          onChanged: (val) {
                                            setState(
                                              () => _scanHeightFactor = val,
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                          // --- BOTTOM SHUTTER BUTTON ---
                          Padding(
                            padding: const EdgeInsets.only(bottom: 40),
                            child: InkWell(
                              onTap: _captureAndAnalyze,
                              child: Container(
                                height: 72,
                                width: 72,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 4,
                                  ),
                                ),
                                child: Center(
                                  child: _isAnalyzing
                                      ? const CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                      : const Icon(
                                          LucideIcons.scan,
                                          color: Colors.white,
                                          size: 32,
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ],
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
        ),
      ),
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  final double animationValue;
  final double scanWidthFactor;
  final double scanHeightFactor;
  final bool showLaserLine;

  ScannerOverlayPainter({
    required this.animationValue,
    required this.scanWidthFactor,
    required this.scanHeightFactor,
    required this.showLaserLine,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Ukuran dinamis mengikuti input konfigurasi/faktor kustomisasi dari user
    final double scanWidth = size.width * scanWidthFactor;
    final double scanHeight = size.height * scanHeightFactor;

    final double left = (size.width - scanWidth) / 2;
    final double top = (size.height - scanHeight) / 2;
    final double right = left + scanWidth;
    final double bottom = top + scanHeight;
    const double radius = 20.0;

    // 1. Gambar Background Masking Gelap Gelap dengan Lubang Cutout Terbuka
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

    // 2. Gambar Sudut/Corner Siku Siku Frame Berwarna Biru Accent
    final paintBorder = Paint()
      ..color = Colors.blueAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    final double cornerLength = 30;
    final pathBorder = Path();

    // Siku Kiri Atas
    pathBorder.moveTo(left, top + cornerLength);
    pathBorder.lineTo(left, top);
    pathBorder.lineTo(left + cornerLength, top);

    // Siku Kanan Atas
    pathBorder.moveTo(right - cornerLength, top);
    pathBorder.lineTo(right, top);
    pathBorder.lineTo(right, top + cornerLength);

    // Siku Kanan Bawah
    pathBorder.moveTo(right, bottom - cornerLength);
    pathBorder.lineTo(right, bottom);
    pathBorder.lineTo(right - cornerLength, bottom);

    // Siku Kiri Bawah
    pathBorder.moveTo(left + cornerLength, bottom);
    pathBorder.lineTo(left, bottom);
    pathBorder.lineTo(left, bottom - cornerLength);

    canvas.drawPath(pathBorder, paintBorder);

    // 3. Efek Animasi Garis Laser & Gradasi Cahaya (Hanya Aktif Jika showLaserLine = true)
    if (showLaserLine) {
      final double currentY = top + (scanHeight * animationValue);
      final double glowHeight = 25.0;

      // Pendaran Cahaya Laser Gradient (Glow)
      final Rect glowRect = Rect.fromLTRB(
        left + 5,
        (currentY - glowHeight).clamp(top, bottom),
        right - 5,
        (currentY + glowHeight).clamp(top, bottom),
      );

      final paintGlow = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.blueAccent.withOpacity(0.0),
            Colors.blueAccent.withOpacity(0.35),
            Colors.blueAccent.withOpacity(0.0),
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(glowRect);

      canvas.drawRect(glowRect, paintGlow);

      // Inti Garis Laser Utama yang Tajam
      final paintLaserLine = Paint()
        ..color = Colors.blueAccent.withOpacity(0.9)
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        Offset(left + 8, currentY),
        Offset(right - 8, currentY),
        paintLaserLine,
      );
    }
  }

  @override
  bool shouldRepaint(ScannerOverlayPainter oldDelegate) {
    // Repaint dipicu apabila ada perubahan nilai animasi, modifikasi ukuran frame, maupun status laser
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.scanWidthFactor != scanWidthFactor ||
        oldDelegate.scanHeightFactor != scanHeightFactor ||
        oldDelegate.showLaserLine != showLaserLine;
  }
}
