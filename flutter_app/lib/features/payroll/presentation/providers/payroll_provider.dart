import 'package:flutter/foundation.dart';

import '../../../../core/events/financial_events.dart';
import '../../../../data/api/api_error_mapper.dart';
import '../../data/models/payroll_record.dart';
import '../../data/models/save_payroll_request.dart';
import '../../data/repositories/payroll_repository.dart';
import '../../domain/payroll_state.dart';

/// Payroll state (Phase 5, FR-006).
///
/// Delegates all data access to [PayrollRepository]; exposes only the
/// state and methods required by the Payroll screen. A successful
/// [calculatePayroll] notifies the optional [FinancialEvents] channel so
/// the Dashboard summary refreshes immediately.
class PayrollProvider extends ChangeNotifier {
  PayrollProvider(this._payrollRepository, {FinancialEvents? financialEvents}) {
    _financialEvents = financialEvents;
  }

  final PayrollRepository _payrollRepository;
  FinancialEvents? _financialEvents;

  PayrollState _state = const PayrollState();

  PayrollState get state => _state;

  /// GET /api/payroll — load payroll records. [sectorId] is the Business
  /// Owner's optional sector filter; it is null for the Event Manager
  /// and Employee (server-scoped to their own records).
  Future<void> loadPayroll({int? sectorId}) async {
    _state = _state.copyWith(isLoading: true, error: null);
    notifyListeners();

    try {
      final List<PayrollRecord> records = await _payrollRepository.getPayroll(
        sectorId: sectorId,
      );
      _state = _state.copyWith(isLoading: false, records: records);
    } catch (error) {
      _state = _state.copyWith(isLoading: false, error: apiErrorMessage(error));
    }

    notifyListeners();
  }

  /// POST /api/payroll — calculate and save a payroll record, then
  /// refresh the list.
  Future<void> calculatePayroll(
    SavePayrollRequest request, {
    int? sectorId,
  }) async {
    _state = _state.copyWith(
      isSubmitting: true,
      error: null,
      successMessage: null,
    );
    notifyListeners();

    try {
      await _payrollRepository.calculatePayroll(request);
      final List<PayrollRecord> records = await _payrollRepository.getPayroll(
        sectorId: sectorId,
      );
      _state = _state.copyWith(
        isSubmitting: false,
        records: records,
        successMessage:
            'Payroll calculated and saved successfully. Expense record '
            'auto-created.',
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
