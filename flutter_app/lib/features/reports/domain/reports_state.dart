import '../data/models/report_data.dart';

/// Immutable reports state managed by [ReportsProvider].
///
/// Updated via [copyWith] so every published state is consistent.
class ReportsState {
  const ReportsState({this.isLoading = false, this.report, this.error});

  /// Tracks a report generation in progress.
  final bool isLoading;

  /// The most recently generated report; null until the first
  /// successful generation.
  final ReportData? report;

  /// Error message to display.
  final String? error;

  /// Sentinel distinguishing "not provided" from an explicit null in
  /// [copyWith], so nullable fields can be cleared by passing null.
  static const Object _unset = Object();

  ReportsState copyWith({
    bool? isLoading,
    Object? report = _unset,
    Object? error = _unset,
  }) {
    return ReportsState(
      isLoading: isLoading ?? this.isLoading,
      report: identical(report, _unset) ? this.report : report as ReportData?,
      error: identical(error, _unset) ? this.error : error as String?,
    );
  }
}
