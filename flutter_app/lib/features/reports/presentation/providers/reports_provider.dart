import 'package:flutter/foundation.dart';

import '../../../../data/api/api_error_mapper.dart';
import '../../data/models/report_data.dart';
import '../../data/repositories/reports_repository.dart';
import '../../domain/reports_state.dart';

/// Reports state (Phase 6, FR-007).
///
/// Delegates all data access to [ReportsRepository]; exposes only the
/// state and methods required by the Reports screen.
class ReportsProvider extends ChangeNotifier {
  ReportsProvider(this._reportsRepository);

  final ReportsRepository _reportsRepository;

  ReportsState _state = const ReportsState();

  ReportsState get state => _state;

  /// GET /api/reports — generate a report for the selected [type] and
  /// optional date range. [sectorId] is the Business Owner's sector
  /// filter (null = cross-sector); it is null for the Event Manager,
  /// who is scoped to the assigned sector by the server.
  Future<void> generateReport({
    required String type,
    DateTime? dateFrom,
    DateTime? dateTo,
    int? sectorId,
  }) async {
    _state = _state.copyWith(isLoading: true, error: null);
    notifyListeners();

    try {
      final ReportData report = await _reportsRepository.getReport(
        type: type,
        dateFrom: dateFrom,
        dateTo: dateTo,
        sectorId: sectorId,
      );
      _state = _state.copyWith(isLoading: false, report: report);
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

  /// Discards the generated report and any error so the screen returns
  /// to its initial state (BR-38: after a sector switch the previously
  /// generated report belongs to the old sector and must not be shown).
  void clearReport() {
    if (_state.report != null || _state.error != null) {
      _state = _state.copyWith(report: null, error: null);
      notifyListeners();
    }
  }
}
