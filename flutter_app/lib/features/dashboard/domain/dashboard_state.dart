import '../data/models/financial_summary.dart';
import '../data/models/recent_transaction.dart';

/// Immutable dashboard state managed by [DashboardProvider].
///
/// Updated via [copyWith] so every published state is consistent.
class DashboardState {
  const DashboardState({
    this.isLoading = false,
    this.summary,
    this.recentTransactions = const [],
    this.error,
  });

  /// Tracks the financial summary fetch in progress.
  final bool isLoading;

  /// Financial summary for the stat cards (null until loaded).
  final FinancialSummary? summary;
  final List<RecentTransaction> recentTransactions;

  /// Error message to display.
  final String? error;

  /// Sentinel distinguishing "not provided" from an explicit null in
  /// [copyWith], so nullable fields can be cleared by passing null.
  static const Object _unset = Object();

  DashboardState copyWith({
    bool? isLoading,
    Object? summary = _unset,
    List<RecentTransaction>? recentTransactions,
    Object? error = _unset,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      summary: identical(summary, _unset)
          ? this.summary
           : summary as FinancialSummary?,
      recentTransactions: recentTransactions ?? this.recentTransactions,
      error: identical(error, _unset) ? this.error : error as String?,
    );
  }
}
