import 'package:flutter/foundation.dart';

import '../../../../data/api/api_error_mapper.dart';
import '../../data/models/financial_summary.dart';
import '../../data/repositories/dashboard_repository.dart';
import '../../domain/dashboard_state.dart';

/// Dashboard state management (Phase 8, FR-002).
///
/// Delegates all data access to [DashboardRepository]; exposes only the
/// state and methods required by the Dashboard screen.
class DashboardProvider extends ChangeNotifier {
  DashboardProvider(this._dashboardRepository);

  final DashboardRepository _dashboardRepository;

  DashboardState _state = const DashboardState();

  DashboardState get state => _state;

  /// GET /api/reports?type=summary — load the financial summary for the
  /// stat cards. [sectorId] filters the report to one sector (see
  /// [DashboardRepository.getSummary]).
  Future<void> loadSummary({int? sectorId}) async {
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
}
