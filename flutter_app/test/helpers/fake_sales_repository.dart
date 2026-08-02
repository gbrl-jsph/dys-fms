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

  @override
  late final Dio dio = Dio();

  @override
  Future<List<SalesTransaction>> getSales({int? sectorId}) =>
      onGetSales!(sectorId);

  @override
  Future<SalesTransaction> recordSale(SaveSaleRequest request) =>
      onRecordSale!(request);
}
