// --- EVENTS ---
abstract class ScanEvent {}

class InitModel extends ScanEvent {}

class AnalyzeImage extends ScanEvent {
  final String imagePath;
  AnalyzeImage(this.imagePath);
}

class LoadStatistics extends ScanEvent {}

// Tambahkan ini
class ResetScan extends ScanEvent {}