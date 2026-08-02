import 'package:flutter/foundation.dart';

/// App-level financial data event channel.
///
/// Decouples the providers that write financial records (Sales, Expenses,
/// Payroll) from the Dashboard provider that displays the Financial
/// Summary. Recording providers call [notifyDataChanged] after a
/// successful write; the Dashboard provider listens and reloads its
/// summary so the numbers refresh without leaving the screen.
class FinancialEvents extends ChangeNotifier {
  /// Signals that a sale, expense, or payroll record was created.
  void notifyDataChanged() => notifyListeners();
}
