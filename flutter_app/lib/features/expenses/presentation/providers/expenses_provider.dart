import 'package:flutter/foundation.dart';

import '../../../../data/api/api_error_mapper.dart';
import '../../data/models/expense_record.dart';
import '../../data/models/save_expense_request.dart';
import '../../data/repositories/expenses_repository.dart';
import '../../domain/expenses_state.dart';

/// Expenses state (Phase 3, FR-005).
///
/// Delegates all data access to [ExpensesRepository]; exposes only the
/// state and methods required by the Expenses screen.
class ExpensesProvider extends ChangeNotifier {
  ExpensesProvider(this._expensesRepository);

  final ExpensesRepository _expensesRepository;

  ExpensesState _state = const ExpensesState();

  ExpensesState get state => _state;

  /// GET /api/expenses — load expense records for the current sector
  /// context. [sectorId] is the Business Owner's selected sector; it is
  /// null for the Event Manager (server-scoped to the assigned sector).
  Future<void> loadExpenses({int? sectorId}) async {
    _state = _state.copyWith(isLoading: true, error: null);
    notifyListeners();

    try {
      final List<ExpenseRecord> expenses = await _expensesRepository
          .getExpenses(sectorId: sectorId);
      _state = _state.copyWith(isLoading: false, expenses: expenses);
    } catch (error) {
      _state = _state.copyWith(isLoading: false, error: apiErrorMessage(error));
    }

    notifyListeners();
  }

  /// POST /api/expenses — record an expense and refresh the list.
  Future<void> recordExpense(
    SaveExpenseRequest request, {
    int? sectorId,
  }) async {
    _state = _state.copyWith(
      isSubmitting: true,
      error: null,
      successMessage: null,
    );
    notifyListeners();

    try {
      await _expensesRepository.recordExpense(request);
      final List<ExpenseRecord> expenses = await _expensesRepository
          .getExpenses(sectorId: sectorId);
      _state = _state.copyWith(
        isSubmitting: false,
        expenses: expenses,
        successMessage: 'Expense recorded successfully.',
      );
    } catch (error) {
      _state = _state.copyWith(
        isSubmitting: false,
        error: apiErrorMessage(error),
      );
    }

    notifyListeners();
  }

  void clearError() {
    if (_state.error != null) {
      _state = _state.copyWith(error: null);
      notifyListeners();
    }
  }

  void clearSuccess() {
    if (_state.successMessage != null) {
      _state = _state.copyWith(successMessage: null);
      notifyListeners();
    }
  }
}
