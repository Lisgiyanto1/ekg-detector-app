// --- EVENTS ---
abstract class ScanEvent {}

class InitModel extends ScanEvent {}

class AnalyzeImage extends ScanEvent {
  final String imagePath;
  AnalyzeImage(this.imagePath);
}
