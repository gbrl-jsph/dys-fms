import 'package:flutter_test/flutter_test.dart';

import 'package:dys_fms/core/utils/formatters.dart';

void main() {
  group('Formatters.formatCurrency', () {
    test('formats whole amounts with two decimals', () {
      expect(Formatters.formatCurrency(0), '₱0.00');
      expect(Formatters.formatCurrency(150000), '₱150,000.00');
      expect(Formatters.formatCurrency(225000), '₱225,000.00');
    });

    test('groups thousands with commas', () {
      expect(Formatters.formatCurrency(1234.5), '₱1,234.50');
      expect(Formatters.formatCurrency(1234567), '₱1,234,567.00');
    });

    test('formats fractional amounts to two decimals', () {
      expect(Formatters.formatCurrency(0.5), '₱0.50');
      expect(Formatters.formatCurrency(999.999), '₱1,000.00');
    });

    test('formats negative amounts', () {
      expect(Formatters.formatCurrency(-65000), '₱-65,000.00');
    });

    test('formats exactly one thousand', () {
      expect(Formatters.formatCurrency(1000), '₱1,000.00');
    });
  });
}
