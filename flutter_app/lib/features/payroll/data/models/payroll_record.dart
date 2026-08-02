/// A payroll record as returned by `GET /api/payroll` / `POST /api/payroll`.
///
/// `computed_salary` is derived server-side (hours_worked × hourly_rate)
/// and is never computed in the UI. Payroll records are immutable and
/// stored permanently (FR-006).
class PayrollRecord {
  const PayrollRecord({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.sectorId,
    required this.sectorName,
    required this.hoursWorked,
    required this.hourlyRate,
    required this.computedSalary,
    required this.payPeriod,
    required this.calculatedAt,
    this.expenseId,
  });

  factory PayrollRecord.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> employee =
        json['employee'] as Map<String, dynamic>;
    final Map<String, dynamic> sector = json['sector'] as Map<String, dynamic>;
    final Map<String, dynamic>? expense =
        json['expense'] as Map<String, dynamic>?;

    return PayrollRecord(
      id: json['id'] as int,
      employeeId: employee['id'] as int,
      employeeName: employee['name'] as String,
      sectorId: sector['id'] as int,
      sectorName: sector['name'] as String,
      hoursWorked: (json['hours_worked'] as num).toDouble(),
      hourlyRate: (json['hourly_rate'] as num).toDouble(),
      computedSalary: (json['computed_salary'] as num).toDouble(),
      payPeriod: DateTime.parse(json['pay_period'] as String),
      calculatedAt: DateTime.parse(json['calculated_at'] as String),
      expenseId: expense?['id'] as int?,
    );
  }

  final int id;
  final int employeeId;
  final String employeeName;
  final int sectorId;
  final String sectorName;

  /// Hours worked in the pay period (positive decimal).
  final double hoursWorked;

  /// Hourly rate recorded at the time of calculation.
  final double hourlyRate;

  /// Salary computed by the backend (hours_worked × hourly_rate).
  final double computedSalary;

  /// Pay period end date (YYYY-MM-DD from the API).
  final DateTime payPeriod;

  /// Server-assigned timestamp (`calculated_at`).
  final DateTime calculatedAt;

  /// Linked auto-created Expense record id (traceability per API spec).
  final int? expenseId;
}
