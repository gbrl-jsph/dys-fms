import 'package:flutter/foundation.dart';

import '../../../../core/events/financial_events.dart';
import '../../../../data/api/api_error_mapper.dart';
import '../../data/models/financial_summary.dart';
import '../../data/repositories/dashboard_repository.dart';
import '../../domain/dashboard_state.dart';

/// Dashboard state management (Phase 8, FR-002).
///
/// Delegates all data access to [DashboardRepository]; exposes only the
/// state and methods required by the Dashboard screen. When a
/// [FinancialEvents] channel is wired, the summary reloads automatically
/// after any sale / expense / payroll record is created.
class DashboardProvider extends ChangeNotifier {
  DashboardProvider(
    this._dashboardRepository, {
    FinancialEvents? financialEvents,
  }) {
    _financialEvents = financialEvents;
    _financialEvents?.addListener(_onFinancialDataChanged);
  }

  final DashboardRepository _dashboardRepository;

  FinancialEvents? _financialEvents;

  /// Sector scope of the last [loadSummary] call; reused when reloading
  /// after a [FinancialEvents] notification.
  int? _currentSectorId;

  DashboardState _state = const DashboardState();

  DashboardState get state => _state;

  /// GET /api/reports?type=summary — load the financial summary for the
  /// stat cards. [sectorId] filters the report to one sector (see
  /// [DashboardRepository.getSummary]).
  Future<void> loadSummary({int? sectorId}) async {
    _currentSectorId = sectorId;
    _state = _state.copyWith(isLoading: true, error: null);
    notifyListeners();

    try {
      final FinancialSummary summary = await _dashboardRepository.getSummary(
        sectorId: sectorId,
      );
      _state = _state.copyWith(isLoading: false, summary: summary);
    } catch (error) {
      _state = _state.copyWith(isLoading: false, error: apiErrorMessage(error));
    }

    notifyListeners();
  }

  void clearError() {
    if (_state.error != null) {
      _state = _state.copyWith(error: null);
      notifyListeners();
    }
  }

  /// Reloads the summary for the current sector after a sale, expense,
  /// or payroll record is created elsewhere in the app.
  void _onFinancialDataChanged() {
    loadSummary(sectorId: _currentSectorId);
  }

  @override
  void dispose() {
    _financialEvents?.removeListener(_onFinancialDataChanged);
    super.dispose();
  }
}
