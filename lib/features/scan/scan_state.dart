import 'package:flutter_ekg_detector/features/scan/ekg_repository.dart';

abstract class ScanState {}

class ScanInitial extends ScanState {}

class ScanLoading extends ScanState {}

// Error global (misal gagal memuat model / database di awal)
class ScanError extends ScanState {
  final String message;
  ScanError(this.message);
}

// BARU: Error khusus proses deteksi kamera agar tidak memicu listener di halaman lain
class ScanDetectionError extends ScanState {
  final String message;
  ScanDetectionError(this.message);
}

class ScanSuccess extends ScanState {
  final EkgRecommendation result;
  final String imagePath;
  final Map<String, double> percentage;

  ScanSuccess(this.result, this.imagePath, this.percentage);
}

/// STATE KHUSUS UNTUK DASHBOARD
class ScanStatisticsLoaded extends ScanState {
  final Map<String, double> percentages;
  final int total;

  ScanStatisticsLoaded(this.percentages, this.total);
}