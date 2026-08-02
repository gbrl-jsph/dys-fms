/// Presentation formatting helpers (ui-style-guide.md: Text Inputs,
/// stat values use the `--currency` display convention).
class Formatters {
  Formatters._();

  /// Formats [amount] as PHP currency with the ₱ symbol and two decimals
  /// (e.g. `₱1,234.56`), matching the wireframe `stat-value` convention.
  static String formatCurrency(num amount) {
    final String fixed = amount.toStringAsFixed(2);
    final List<String> parts = fixed.split('.');
    final StringBuffer grouped = StringBuffer();
    final String digits = parts[0];
    final int firstGroupLength = digits.length % 3 == 0 ? 3 : digits.length % 3;

    for (int i = 0; i < digits.length; i++) {
      if (i == firstGroupLength && digits.length > 3) {
        grouped.write(',');
      } else if (i > firstGroupLength && (i - firstGroupLength) % 3 == 0) {
        grouped.write(',');
      }
      grouped.write(digits[i]);
    }

    return '₱$grouped.${parts[1]}';
  }

  static const List<String> _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  /// Formats a timestamp as a compact date (e.g. `Jul 28, 2026`), used
  /// for sales transaction list rows.
  static String formatDate(DateTime date) =>
      '${_months[date.month - 1]} ${date.day}, ${date.year}';

  /// Formats [date] as an API date value (`YYYY-MM-DD`), used for the
  /// payroll `pay_period` payload field.
  static String formatApiDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
