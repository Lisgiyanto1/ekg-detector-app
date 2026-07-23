import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart'; // Untuk debugPrint
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

// Model Data Sederhana
class EkgRecommendation {
  final String label;
  final String urgency;
  final String treatment;
  final String medicine;
  final String prevention;

  EkgRecommendation({
    required this.label,
    required this.urgency,
    required this.treatment,
    required this.medicine,
    required this.prevention,
  });
}

class EkgRepository {
  Interpreter? _interpreter;
  List<String>? _labels;
  final Map<String, EkgRecommendation> _csvData = {};

  static const double CONF_THRESHOLD = 0.0;

  Future<void> initialize() async {
    try {
      _interpreter = await Interpreter.fromAsset(
        'assets/model/model_ekg.tflite',
        options: InterpreterOptions()..threads = 2,
      );

      final labelStr = await rootBundle.loadString('assets/model/labels.txt');
      _labels = labelStr.split('\n').where((s) => s.trim().isNotEmpty).toList();

      final csvStr = await rootBundle.loadString(
        'assets/model/data_rekomendasi.csv',
      );

      final rows = const CsvDecoder(fieldDelimiter: ';').convert(csvStr);

      for (var i = 1; i < rows.length; i++) {
        final row = rows[i];

        final rawKey = row[0].toString();
        final cleanKey = rawKey
            .toLowerCase()
            .replaceAll('-', ' ')
            .replaceAll('_', ' ')
            .trim();

        _csvData[cleanKey] = EkgRecommendation(
          label: row[0].toString(), // ekg_result
          treatment: row[1].toString(), // tindak_lanjut 🏥
          medicine: row[2].toString(), // obat_umum 💊
          prevention: row[3].toString(), // pencegahan 🛡️
          urgency: row[4].toString(), // tingkat_kedaruratan 🚨
        );
      }

      debugPrint("✅ EKG Repository initialized");
    } catch (e) {
      debugPrint("❌ Error Init: $e");
      throw Exception("Gagal memuat aset AI");
    }
  }

  Future<EkgRecommendation?> predict(String imagePath) async {
    if (_interpreter == null) await initialize();

    // 1️⃣ LOAD IMAGE
    final bytes = await File(imagePath).readAsBytes();
    final rawImage = img.decodeImage(bytes);
    if (rawImage == null) {
      throw Exception("Gagal membaca file gambar");
    }

    // 2️⃣ BRIGHTNESS FILTER (tetap)
    if (!_checkBrightness(rawImage)) {
      throw Exception("Foto terlalu gelap. Harap nyalakan lampu atau flash.");
    }

    // 3️⃣ PREPROCESS
    final resized = img.copyResize(rawImage, width: 224, height: 224);
    final input = _imageToFloat32(resized);

    final output = List.filled(
      _labels!.length,
      0.0,
    ).reshape([1, _labels!.length]);

    // 4️⃣ INFERENCE
    _interpreter!.run(input, output);

    final probs = List<double>.from(output[0]);
    int maxIndex = 0;
    double maxProb = 0;

    for (int i = 0; i < probs.length; i++) {
      if (probs[i] > maxProb) {
        maxProb = probs[i];
        maxIndex = i;
      }
    }

    final predictedLabel = _labels![maxIndex];

    debugPrint("🔍 HASIL DETEKSI");
    debugPrint("👉 Label : $predictedLabel");
    debugPrint("📊 Confidence : ${(maxProb * 100).toStringAsFixed(2)}%");

    // 5️⃣ BACKGROUND / NON-EKG HANDLING
    if (predictedLabel.toLowerCase() == 'background') {
      throw Exception(
        "Gambar bukan grafik EKG. Silakan foto ulang grafik EKG.",
      );
    }

    // 6️⃣ CONFIDENCE FILTER
    if (maxProb < CONF_THRESHOLD) {
      throw Exception(
        "Grafik EKG tidak terbaca jelas "
        "(Akurasi: ${(maxProb * 100).toInt()}%). "
        "Coba foto lebih dekat dan lurus.",
      );
    }

    // 7️⃣ CSV LOOKUP (sinkron dash → spasi)
    final searchKey = predictedLabel
        .toLowerCase()
        .replaceAll('-', ' ')
        .replaceAll('_', ' ')
        .trim();

    final result = _csvData[searchKey];

    if (result == null) {
      debugPrint("⚠️ CSV tidak menemukan key '$searchKey'");
    }

    return result ??
        EkgRecommendation(
          label: predictedLabel,
          urgency: 'Tidak Diketahui',
          treatment: 'Hasil terdeteksi, namun belum ada rekomendasi terdaftar.',
          medicine: '-',
          prevention: '-',
        );
  }

  // =============================================================
  // HELPERS
  // =============================================================

  bool _checkBrightness(img.Image image) {
    final small = img.copyResize(image, width: 50, height: 50);
    double total = 0;

    for (var p in small) {
      // FIX: Menyesuaikan ekstraksi nilai luminance untuk library `image` v4.x
      total += p.luminance / p.maxChannelValue;
    }

    final avg = (total / (small.width * small.height)) * 255.0;

    debugPrint("💡 Rata-rata Kecerahan: ${avg.toStringAsFixed(1)}");

    return avg > 20;
  }

  List<List<List<List<double>>>> _imageToFloat32(img.Image img224) {
    return [
      List.generate(
        224,
        (y) => List.generate(224, (x) {
          final p = img224.getPixel(x, y);
          // FIX: Menyesuaikan ekstraksi warna R, G, B untuk library `image` v4.x
          return [
            p.r / p.maxChannelValue,
            p.g / p.maxChannelValue,
            p.b / p.maxChannelValue,
          ];
        }),
      ),
    ];
  }
}
