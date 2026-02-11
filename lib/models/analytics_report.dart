class AnalyticsReport {
  final int totalAttempts;
  final String? mostFailedField;
  final Map<String, int> fieldFailureCounts;

  const AnalyticsReport({
    this.totalAttempts = 0,
    this.mostFailedField,
    this.fieldFailureCounts = const {},
  });

  @override
  String toString() {
    return 'AnalyticsReport(totalAttempts: $totalAttempts, mostFailedField: $mostFailedField, failures: $fieldFailureCounts)';
  }
}
