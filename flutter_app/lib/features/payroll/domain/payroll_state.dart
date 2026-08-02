import '../data/models/payroll_record.dart';

/// Immutable payroll state managed by [PayrollProvider].
///
/// Updated via [copyWith] so every published state is consistent.
class PayrollState {
  const PayrollState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.records = const [],
    this.error,
    this.successMessage,
  });

  /// Tracks the payroll list fetch in progress.
  final bool isLoading;

  /// Tracks the calculate-and-save submission in progress.
  final bool isSubmitting;

  /// Payroll records from GET /payroll.
  final List<PayrollRecord> records;

  /// Error message to display.
  final String? error;

  /// Success feedback message to display.
  final String? successMessage;

  /// Sentinel distinguishing "not provided" from an explicit null in
  /// [copyWith], so nullable fields can be cleared by passing null.
  static const Object _unset = Object();

  PayrollState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    List<PayrollRecord>? records,
    Object? error = _unset,
    Object? successMessage = _unset,
  }) {
    return PayrollState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      records: records ?? this.records,
      error: identical(error, _unset) ? this.error : error as String?,
      successMessage: identical(successMessage, _unset)
          ? this.successMessage
          : successMessage as String?,
    );
  }
}
