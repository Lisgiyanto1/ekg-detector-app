// --- STATES ---
import 'package:flutter_ekg_detector/features/scan/ekg_repository.dart';

abstract class ScanState {}

class ScanInitial extends ScanState {}

class ScanLoading extends ScanState {} // Saat model loading / processing

class ScanSuccess extends ScanState {
  final EkgRecommendation result;
  final String imagePath;
  ScanSuccess(this.result, this.imagePath);
}

class ScanError extends ScanState {
  final String message;
  ScanError(this.message);
}
