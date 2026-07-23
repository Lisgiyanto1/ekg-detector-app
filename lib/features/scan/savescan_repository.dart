import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class SaveScanRepository {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  static const String collection = "scan_logs";

  /// ===============================
  /// SAVE SCAN RESULT
  /// ===============================
  Future<void> saveScan({
    required String label,
    required double confidence,
    required String urgency,
  }) async {
    try {
      await firestore.collection(collection).add({
        "label": label,
        "confidence": confidence,
        "urgency": urgency,
        "createdAt": FieldValue.serverTimestamp(),
      });

      debugPrint("✅ Scan saved to Firestore");
    } catch (e) {
      debugPrint("❌ Failed to save scan: $e");
      throw Exception("Failed to save scan");
    }
  }

  /// ===============================
  /// GET LAST 7 DAYS SCANS
  /// ===============================
  Future<List<Map<String, dynamic>>> getLastWeekScans() async {
    try {
      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));

      final snapshot = await firestore
          .collection(collection)
          .where(
            "createdAt",
            isGreaterThanOrEqualTo: Timestamp.fromDate(sevenDaysAgo),
          )
          .orderBy("createdAt", descending: true)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      debugPrint("❌ Error fetching weekly scans: $e");
      throw Exception("Failed to load weekly scans");
    }
  }

  /// ===============================
  /// STREAM LAST WEEK SCANS (REALTIME)
  /// ===============================
  Stream<List<Map<String, dynamic>>> streamLastWeekScans() {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));

    return firestore
        .collection(collection)
        .where(
          "createdAt",
          isGreaterThanOrEqualTo: Timestamp.fromDate(sevenDaysAgo),
        )
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => doc.data()).toList();
        });
  }

  /// ===============================
  /// GET TODAY SCANS
  /// ===============================
  Future<List<Map<String, dynamic>>> getTodayScans() async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);

      final snapshot = await firestore
          .collection(collection)
          .where(
            "createdAt",
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
          )
          .orderBy("createdAt", descending: true)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      debugPrint("❌ Error fetching today scans: $e");
      throw Exception("Failed to load today scans");
    }
  }
}
