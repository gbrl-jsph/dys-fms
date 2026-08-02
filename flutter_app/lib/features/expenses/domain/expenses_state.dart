import '../data/models/expense_record.dart';

/// Immutable expenses state managed by [ExpensesProvider].
///
/// Updated via [copyWith] so every published state is consistent.
class ExpensesState {
  const ExpensesState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.expenses = const [],
    this.error,
    this.successMessage,
  });

  /// Tracks the expenses list fetch in progress.
  final bool isLoading;

  /// Tracks the record-expense submission in progress.
  final bool isSubmitting;

  /// Expense records from GET /expenses.
  final List<ExpenseRecord> expenses;

  /// Error message to display.
  final String? error;

  /// Success feedback message to display.
  final String? successMessage;

  /// Sentinel distinguishing "not provided" from an explicit null in
  /// [copyWith], so nullable fields can be cleared by passing null.
  static const Object _unset = Object();

  ExpensesState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    List<ExpenseRecord>? expenses,
    Object? error = _unset,
    Object? successMessage = _unset,
  }) {
    return ExpensesState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      expenses: expenses ?? this.expenses,
      error: identical(error, _unset) ? this.error : error as String?,
      successMessage: identical(successMessage, _unset)
          ? this.successMessage
          : successMessage as String?,
    );
  }
}
