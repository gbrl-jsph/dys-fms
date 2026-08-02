import '../../../../core/utils/formatters.dart';

/// Request body for `POST /api/payroll`.
///
/// Mirrors the backend request fields: user_id, hours_worked, hourly_rate,
/// pay_period. `computed_salary` and `sector_id` are derived server-side
/// and are never client-supplied (FR-006, API spec).
class SavePayrollRequest {
  const SavePayrollRequest({
    required this.userId,
    required this.hoursWorked,
    required this.hourlyRate,
    required this.payPeriod,
  });

  /// Employee ID (must be an Event Manager or Employee/Staff).
  final int userId;
  final double hoursWorked;
  final double hourlyRate;

  /// Pay period end date, serialized as `YYYY-MM-DD`.
  final DateTime payPeriod;

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'hours_worked': hoursWorked,
    'hourly_rate': hourlyRate,
    'pay_period': Formatters.formatApiDate(payPeriod),
  };
}
