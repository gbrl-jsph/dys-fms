import '../data/models/financial_summary.dart';

/// Immutable dashboard state managed by [DashboardProvider].
///
/// Updated via [copyWith] so every published state is consistent.
class DashboardState {
  const DashboardState({this.isLoading = false, this.summary, this.error});

  /// Tracks the financial summary fetch in progress.
  final bool isLoading;

  /// Financial summary for the stat cards (null until loaded).
  final FinancialSummary? summary;

  /// Error message to display.
  final String? error;

  /// Sentinel distinguishing "not provided" from an explicit null in
  /// [copyWith], so nullable fields can be cleared by passing null.
  static const Object _unset = Object();

  DashboardState copyWith({
    bool? isLoading,
    Object? summary = _unset,
    Object? error = _unset,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      summary: identical(summary, _unset)
          ? this.summary
          : summary as FinancialSummary?,
      error: identical(error, _unset) ? this.error : error as String?,
    );
  }
}
