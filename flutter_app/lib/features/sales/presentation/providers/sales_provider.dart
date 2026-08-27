import 'package:flutter/foundation.dart';

import '../../../../core/events/financial_events.dart';
import '../../../../data/api/api_error_mapper.dart';
import '../../data/models/save_sale_request.dart';
import '../../data/models/sales_transaction.dart';
import '../../data/repositories/sales_repository.dart';
import '../../domain/sales_state.dart';

/// Sales state (Phase 3, FR-004).
///
/// Delegates all data access to [SalesRepository]; exposes only the
/// state and methods required by the Sales screen. A successful
/// [recordSale] notifies the optional [FinancialEvents] channel so the
/// Dashboard summary refreshes immediately.
class SalesProvider extends ChangeNotifier {
  SalesProvider(this._salesRepository, {FinancialEvents? financialEvents}) {
    _financialEvents = financialEvents;
  }

  final SalesRepository _salesRepository;
  FinancialEvents? _financialEvents;

  SalesState _state = const SalesState();

  SalesState get state => _state;

  /// GET /api/sales — load sales transactions for the current sector
  /// context. [sectorId] is the Business Owner's selected sector; it is
  /// null for the Event Manager (server-scoped to the assigned sector).
  Future<void> loadSales({
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
      final List<SalesTransaction> sales = await _salesRepository.getSales(
        sectorId: sectorId,
      );
      // Client-side filtering for search/date/amount when server doesn't support it
      // (server now supports it, but we keep client-side as fallback for empty search)
      List<SalesTransaction> filtered = sales;
      if (search != null && search.isNotEmpty) {
        filtered = filtered.where((s) => s.description?.toLowerCase().contains(search.toLowerCase()) ?? false).toList();
      }
      _state = _state.copyWith(isLoading: false, sales: filtered);
    } catch (error) {
      _state = _state.copyWith(isLoading: false, error: apiErrorMessage(error));
    }

    notifyListeners();
  }

  Future<void> searchSales({
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
      final List<SalesTransaction> sales = await _salesRepository.searchSales(
        sectorId: sectorId,
        search: search,
        dateFrom: dateFrom,
        dateTo: dateTo,
        amountMin: amountMin,
        amountMax: amountMax,
      );
      _state = _state.copyWith(isLoading: false, sales: sales);
    } catch (error) {
      _state = _state.copyWith(isLoading: false, error: apiErrorMessage(error));
    }

    notifyListeners();
  }

  /// POST /api/sales — record a sale and refresh the list.
  Future<void> recordSale(SaveSaleRequest request, {int? sectorId}) async {
    _state = _state.copyWith(
      isSubmitting: true,
      error: null,
      successMessage: null,
    );
    notifyListeners();

    try {
      await _salesRepository.recordSale(request);
      final List<SalesTransaction> sales = await _salesRepository.getSales(
        sectorId: sectorId,
      );
      _state = _state.copyWith(
        isSubmitting: false,
        sales: sales,
        successMessage: 'Sale recorded successfully.',
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

  Future<void> updateSale(int id, SaveSaleRequest request, {int? sectorId}) async {
    _state = _state.copyWith(isSubmitting: true, error: null, successMessage: null);
    notifyListeners();

    try {
      await _salesRepository.updateSale(id, request);
      final List<SalesTransaction> sales = await _salesRepository.getSales(sectorId: sectorId);
      _state = _state.copyWith(isSubmitting: false, sales: sales, successMessage: 'Sale updated successfully.');
      _financialEvents?.notifyDataChanged();
    } catch (error) {
      _state = _state.copyWith(isSubmitting: false, error: apiErrorMessage(error));
    }

    notifyListeners();
  }

  Future<void> deleteSale(int id, {int? sectorId}) async {
    _state = _state.copyWith(isSubmitting: true, error: null, successMessage: null);
    notifyListeners();

    try {
      await _salesRepository.deleteSale(id);
      final List<SalesTransaction> sales = await _salesRepository.getSales(sectorId: sectorId);
      _state = _state.copyWith(isSubmitting: false, sales: sales, successMessage: 'Sale deleted successfully.');
      _financialEvents?.notifyDataChanged();
    } catch (error) {
      _state = _state.copyWith(isSubmitting: false, error: apiErrorMessage(error));
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
