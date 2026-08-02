import '../data/models/sales_transaction.dart';

/// Immutable sales state managed by [SalesProvider].
///
/// Updated via [copyWith] so every published state is consistent.
class SalesState {
  const SalesState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.sales = const [],
    this.error,
    this.successMessage,
  });

  /// Tracks the sales list fetch in progress.
  final bool isLoading;

  /// Tracks the record-sale submission in progress.
  final bool isSubmitting;

  /// Sales transactions from GET /sales.
  final List<SalesTransaction> sales;

  /// Error message to display.
  final String? error;

  /// Success feedback message to display.
  final String? successMessage;

  /// Sentinel distinguishing "not provided" from an explicit null in
  /// [copyWith], so nullable fields can be cleared by passing null.
  static const Object _unset = Object();

  SalesState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    List<SalesTransaction>? sales,
    Object? error = _unset,
    Object? successMessage = _unset,
  }) {
    return SalesState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      sales: sales ?? this.sales,
      error: identical(error, _unset) ? this.error : error as String?,
      successMessage: identical(successMessage, _unset)
          ? this.successMessage
          : successMessage as String?,
    );
  }
}
