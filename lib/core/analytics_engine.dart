import '../models/analytics_report.dart';

class AnalyticsEngine {
  int _totalAttempts = 0;
  final Map<String, int> _fieldFailures = {};

  void logSubmissionAttempt() {
    _totalAttempts++;
  }

  void logFieldFailure(String fieldName) {
    _fieldFailures[fieldName] = (_fieldFailures[fieldName] ?? 0) + 1;
  }

  AnalyticsReport generateReport() {
    String? mostFailed;
    int maxFailures = -1;

    _fieldFailures.forEach((field, count) {
      if (count > maxFailures) {
        maxFailures = count;
        mostFailed = field;
      }
    });

    return AnalyticsReport(
      totalAttempts: _totalAttempts,
      mostFailedField: mostFailed,
      fieldFailureCounts: Map.from(_fieldFailures),
    );
  }

  void reset() {
    _totalAttempts = 0;
    _fieldFailures.clear();
  }
}
