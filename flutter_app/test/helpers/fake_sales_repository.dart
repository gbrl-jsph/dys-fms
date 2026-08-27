import 'package:dio/dio.dart';

import 'package:dys_fms/features/sales/data/models/save_sale_request.dart';
import 'package:dys_fms/features/sales/data/models/sales_transaction.dart';
import 'package:dys_fms/features/sales/data/repositories/sales_repository.dart';

/// Sample sales list payloads matching the API spec `data` array.
const Map<String, dynamic> saleJson = {
  'id': 101,
  'amount': 15000.00,
  'description': 'Full event coordination package',
  'recorded_by': {'id': 1, 'name': 'Juan Dela Cruz'},
  'sector': {'id': 1, 'name': 'DYS Events'},
  'recorded_at': '2026-07-28T14:30:00.000000Z',
};

const Map<String, dynamic> secondSaleJson = {
  'id': 102,
  'amount': 25000.00,
  'description': null,
  'recorded_by': {'id': 2, 'name': 'Maria Santos'},
  'sector': {'id': 2, 'name': 'B&DYS'},
  'recorded_at': '2026-07-29T09:15:00.000000Z',
};

List<SalesTransaction> buildSalesList() => [
  SalesTransaction.fromJson(saleJson),
  SalesTransaction.fromJson(secondSaleJson),
];

/// In-memory [SalesRepository] fake with overridable callbacks.
class FakeSalesRepository implements SalesRepository {
  Future<List<SalesTransaction>> Function(int? sectorId)? onGetSales;
  Future<SalesTransaction> Function(SaveSaleRequest request)? onRecordSale;
  Future<SalesTransaction> Function(int id, SaveSaleRequest request)? onUpdateSale;
  Future<void> Function(int id)? onDeleteSale;
  Future<List<SalesTransaction>> Function(int? sectorId)? onSearchSales;
  Future<SalesTransaction> Function(int id)? onGetSale;

  @override
  late final Dio dio = Dio();

  @override
  Future<List<SalesTransaction>> getSales({int? sectorId}) =>
      onGetSales!(sectorId);

  @override
  Future<SalesTransaction> recordSale(SaveSaleRequest request) =>
      onRecordSale!(request);

  @override
  Future<SalesTransaction> updateSale(int id, SaveSaleRequest request) =>
      onUpdateSale != null ? onUpdateSale!(id, request) : throw UnimplementedError();

  @override
  Future<void> deleteSale(int id) =>
      onDeleteSale != null ? onDeleteSale!(id) : throw UnimplementedError();

  @override
  Future<List<SalesTransaction>> searchSales({
    int? sectorId,
    String? search,
    String? dateFrom,
    String? dateTo,
    double? amountMin,
    double? amountMax,
  }) =>
      onSearchSales != null ? onSearchSales!(sectorId) : getSales(sectorId: sectorId);

  @override
  Future<SalesTransaction> getSale(int id) =>
      onGetSale != null ? onGetSale!(id) : throw UnimplementedError();
}
