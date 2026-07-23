class StatisticsService {
  Map<String, double> calculateDiseasePercentage(
    List<Map<String, dynamic>> scans,
  ) {
    Map<String, int> counter = {};

    for (var scan in scans) {
      final label = scan["label"];

      counter[label] = (counter[label] ?? 0) + 1;
    }

    final total = scans.length;

    Map<String, double> percentage = {};

    counter.forEach((label, count) {
      percentage[label] = (count / total) * 100;
    });

    return percentage;
  }
}
