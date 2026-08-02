import 'package:flutter/foundation.dart';

import '../../../../data/api/api_error_mapper.dart';
import '../../data/models/business_sector.dart';
import '../../data/repositories/sectors_repository.dart';
import '../../domain/sectors_state.dart';

/// Business sector state (Phase 7, FR-008).
///
/// Delegates all data access to [SectorsRepository]; exposes only the
/// state and methods required by the Sector Switcher screen. The
/// switch endpoint is stateless, so the screen coordinates the
/// client-side sector context update and Dashboard refresh after a
/// successful switch.
class SectorsProvider extends ChangeNotifier {
  SectorsProvider(this._sectorsRepository);

  final SectorsRepository _sectorsRepository;

  SectorsState _state = const SectorsState();

  SectorsState get state => _state;

  /// GET /api/business-sectors — load the four approved sectors.
  Future<void> loadSectors() async {
    _state = _state.copyWith(isLoading: true, error: null);
    notifyListeners();

    try {
      final List<BusinessSector> sectors = await _sectorsRepository
          .getSectors();
      _state = _state.copyWith(isLoading: false, sectors: sectors);
    } catch (error) {
      _state = _state.copyWith(isLoading: false, error: apiErrorMessage(error));
    }

    notifyListeners();
  }

  /// POST /api/business-sectors/switch — switch the current sector
  /// context.
  ///
  /// Returns the server acknowledgement (previous + current sector)
  /// so the screen can update the client-side sector context, or null
  /// when the switch failed (the error is exposed through [SectorsState.error]).
  Future<SectorSwitchResult?> switchSector(int sectorId) async {
    _state = _state.copyWith(isSwitching: true, error: null);
    notifyListeners();

    SectorSwitchResult? result;
    try {
      result = await _sectorsRepository.switchSector(sectorId);
      _state = _state.copyWith(isSwitching: false);
    } catch (error) {
      _state = _state.copyWith(
        isSwitching: false,
        error: apiErrorMessage(error),
      );
    }

    notifyListeners();
    return result;
  }

  void clearError() {
    if (_state.error != null) {
      _state = _state.copyWith(error: null);
      notifyListeners();
    }
  }
}
