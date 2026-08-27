import 'package:flutter/foundation.dart';

import '../../../../core/events/financial_events.dart';
import '../../../../data/api/api_error_mapper.dart';
import '../../data/models/expense_record.dart';
import '../../data/models/save_expense_request.dart';
import '../../data/repositories/expenses_repository.dart';
import '../../domain/expenses_state.dart';

/// Expenses state (Phase 3, FR-005).
///
/// Delegates all data access to [ExpensesRepository]; exposes only the
/// state and methods required by the Expenses screen. A successful
/// [recordExpense] notifies the optional [FinancialEvents] channel so
/// the Dashboard summary refreshes immediately.
class ExpensesProvider extends ChangeNotifier {
  ExpensesProvider(this._expensesRepository, {FinancialEvents? financialEvents}) {
    _financialEvents = financialEvents;
  }

  final ExpensesRepository _expensesRepository;
  FinancialEvents? _financialEvents;

  ExpensesState _state = const ExpensesState();

  ExpensesState get state => _state;

  /// GET /api/expenses — load expense records for the current sector
  /// context. [sectorId] is the Business Owner's selected sector; it is
  /// null for the Event Manager (server-scoped to the assigned sector).
  Future<void> loadExpenses({
    int? sectorId,
    String? search,
    String? dateFrom,
    String? dateTo,
    double? amountMin,
    double? amountMax,
  }) async {
    _state = _state.copyWith(isLoading: true, error: null);
    notifyListeners();

    try {
      final List<ExpenseRecord> expenses = await _expensesRepository
          .getExpenses(sectorId: sectorId);
      List<ExpenseRecord> filtered = expenses;
      if (search != null && search.isNotEmpty) {
        filtered = filtered
            .where(
              (e) => e.description?.toLowerCase().contains(search.toLowerCase()) ?? false,
            )
            .toList();
      }
      _state = _state.copyWith(isLoading: false, expenses: filtered);
    } catch (error) {
      _state = _state.copyWith(isLoading: false, error: apiErrorMessage(error));
    }

    notifyListeners();
  }

  Future<void> searchExpenses({
    int? sectorId,
    String? search,
    String? dateFrom,
    String? dateTo,
    double? amountMin,
    double? amountMax,
  }) async {
    _state = _state.copyWith(isLoading: true, error: null);
    notifyListeners();

    try {
      final List<ExpenseRecord> expenses = await _expensesRepository.searchExpenses(
        sectorId: sectorId,
        search: search,
        dateFrom: dateFrom,
        dateTo: dateTo,
        amountMin: amountMin,
        amountMax: amountMax,
      );
      _state = _state.copyWith(isLoading: false, expenses: expenses);
    } catch (error) {
      _state = _state.copyWith(isLoading: false, error: apiErrorMessage(error));
    }

    notifyListeners();
  }

  Future<void> updateExpense(int id, SaveExpenseRequest request, {int? sectorId}) async {
    _state = _state.copyWith(isSubmitting: true, error: null, successMessage: null);
    notifyListeners();

    try {
      await _expensesRepository.updateExpense(id, request);
      final List<ExpenseRecord> expenses = await _expensesRepository.getExpenses(sectorId: sectorId);
      _state = _state.copyWith(isSubmitting: false, expenses: expenses, successMessage: 'Expense updated successfully.');
      _financialEvents?.notifyDataChanged();
    } catch (error) {
      _state = _state.copyWith(isSubmitting: false, error: apiErrorMessage(error));
    }

    notifyListeners();
  }

  Future<void> deleteExpense(int id, {int? sectorId}) async {
    _state = _state.copyWith(isSubmitting: true, error: null, successMessage: null);
    notifyListeners();

    try {
      await _expensesRepository.deleteExpense(id);
      final List<ExpenseRecord> expenses = await _expensesRepository.getExpenses(sectorId: sectorId);
      _state = _state.copyWith(isSubmitting: false, expenses: expenses, successMessage: 'Expense deleted successfully.');
      _financialEvents?.notifyDataChanged();
    } catch (error) {
      _state = _state.copyWith(isSubmitting: false, error: apiErrorMessage(error));
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
      _financialEvents?.notifyDataChanged();
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
