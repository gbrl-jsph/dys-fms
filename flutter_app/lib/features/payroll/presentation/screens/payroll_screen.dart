import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/business_sectors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/sector_context.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_container.dart';
import '../../../../core/widgets/app_field_label.dart';
import '../../../../core/widgets/app_screen_header.dart';
import '../../../../core/widgets/app_success_container.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/loading_button.dart';
import '../../../../core/widgets/section_label.dart';
import '../../../auth/domain/auth_state.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../users/data/models/user_account.dart';
import '../../../users/domain/users_state.dart';
import '../../../users/presentation/providers/users_provider.dart';
import '../../data/models/payroll_record.dart';
import '../../data/models/save_payroll_request.dart';
import '../../domain/payroll_state.dart';
import '../providers/payroll_provider.dart';

/// Payroll screen (FR-006, Screen 5).
///
/// Payroll calculation form + history list per the payroll.html
/// wireframe and navigation-map Rule 3:
/// - Business Owner: sector dropdown (optional filter; switching sectors
///   reloads the list), Employee selector, Hours Worked + Hourly Rate
///   fields, Pay Period picker, Save Payroll Record button.
/// - Event Manager / Employee: records list only (own records, scoped by
///   the server) — no calculate controls (POST /payroll is Owner-only).
///
/// `computed_salary` is always derived server-side (hours × rate) and is
/// never computed in the UI; the backend auto-creates the linked Expense
/// record in the same transaction.
class PayrollScreen extends StatefulWidget {
  const PayrollScreen({super.key});

  @override
  State<PayrollScreen> createState() => _PayrollScreenState();
}

class _PayrollScreenState extends State<PayrollScreen> {
  final TextEditingController _hoursController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _payPeriodController = TextEditingController();

  int? _selectedSectorId;
  int? _selectedEmployeeId;
  DateTime? _payPeriod;
  String? _employeeError;
  String? _hoursError;
  String? _rateError;
  String? _payPeriodError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPayroll());
  }

  @override
  void dispose() {
    _hoursController.dispose();
    _rateController.dispose();
    _payPeriodController.dispose();
    super.dispose();
  }

  void _loadPayroll() {
    final AuthState auth = context.read<AuthProvider>().state;
    final PayrollProvider provider = context.read<PayrollProvider>();
    final bool isBusinessOwner = auth.user?.isBusinessOwner ?? false;
    final int? sectorId = isBusinessOwner ? sectorIdFor(auth) : null;

    setState(() => _selectedSectorId = sectorId);
    provider.loadPayroll(sectorId: sectorId);

    if (isBusinessOwner) {
      final UsersProvider usersProvider = context.read<UsersProvider>();
      if (usersProvider.state.users.isEmpty && !usersProvider.state.isLoading) {
        usersProvider.loadUsers();
      }
    }
  }

  void _onSectorChanged(int? sectorId) {
    setState(() => _selectedSectorId = sectorId);
    context.read<PayrollProvider>().loadPayroll(sectorId: sectorId);
  }

  Future<void> _pickPayPeriod() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _payPeriod ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      _payPeriod = picked;
      _payPeriodController.text = Formatters.formatDate(picked);
      _payPeriodError = null;
    });
  }

  bool _validate() {
    final String hoursText = _hoursController.text.trim();
    final String rateText = _rateController.text.trim();

    setState(() {
      _employeeError = _selectedEmployeeId == null
          ? 'Employee is required.'
          : null;
      _hoursError = _validateHours(hoursText);
      _rateError = _validateRate(rateText);
      _payPeriodError = _payPeriod == null ? 'Pay period is required.' : null;
    });

    // Computed salary (hours × rate) must fit the DECIMAL(10,2) limit
    // even when each input is within its own ceiling.
    if (_hoursError == null && _rateError == null) {
      final double? hours = double.tryParse(hoursText);
      final double? rate = double.tryParse(rateText);
      if (hours != null && rate != null && (hours * rate) > 99999999.99) {
        setState(
          () => _hoursError = 'Computed salary must not exceed 99999999.99.',
        );
      }
    }

    return _employeeError == null &&
        _hoursError == null &&
        _rateError == null &&
        _payPeriodError == null;
  }

  /// Hours rules per the Validation Rules Matrix (UI layer): required,
  /// then a positive number, then the 99999999.99 ceiling.
  String? _validateHours(String hoursText) {
    if (hoursText.isEmpty) return 'Hours worked is required.';
    final double? hours = double.tryParse(hoursText);
    if (hours == null || hours <= 0) {
      return 'Hours worked must be a positive number.';
    }
    if (hours > 99999999.99) {
      return 'Hours worked must not exceed 99999999.99.';
    }
    return null;
  }

  /// Rate rules per the Validation Rules Matrix (UI layer): required,
  /// then a positive number, then the 99999999.99 ceiling.
  String? _validateRate(String rateText) {
    if (rateText.isEmpty) return 'Hourly rate is required.';
    final double? rate = double.tryParse(rateText);
    if (rate == null || rate <= 0) {
      return 'Hourly rate must be a positive number.';
    }
    if (rate > 99999999.99) {
      return 'Hourly rate must not exceed 99999999.99.';
    }
    return null;
  }

  void _submitSave(PayrollProvider provider) {
    if (provider.state.isSubmitting) return;
    if (!_validate()) return;

    provider.clearSuccess();

    final SavePayrollRequest request = SavePayrollRequest(
      userId: _selectedEmployeeId!,
      hoursWorked: double.parse(_hoursController.text.trim()),
      hourlyRate: double.parse(_rateController.text.trim()),
      payPeriod: _payPeriod!,
    );

    setState(() {
      _hoursController.clear();
      _rateController.clear();
      _payPeriodController.clear();
      _selectedEmployeeId = null;
      _payPeriod = null;
    });

    provider.calculatePayroll(request, sectorId: _selectedSectorId);
  }

  @override
  Widget build(BuildContext context) {
    final AuthState auth = context.watch<AuthProvider>().state;
    final PayrollProvider payrollProvider = context.watch<PayrollProvider>();
    final PayrollState state = payrollProvider.state;
    final bool isBusinessOwner = auth.user?.isBusinessOwner ?? false;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.sp4,
            AppSpacing.sp2,
            AppSpacing.sp4,
            AppSpacing.sp4,
          ),
          children: [
            AppScreenHeader(
              title: 'Payroll',
              onBack: () => context.go('/dashboard'),
            ),
            const SizedBox(height: AppSpacing.sp2),
            if (isBusinessOwner) ...[
              _CalculatePayrollForm(
                selectedSectorId: _selectedSectorId,
                selectedEmployeeId: _selectedEmployeeId,
                isSubmitting: state.isSubmitting,
                hoursController: _hoursController,
                rateController: _rateController,
                payPeriodController: _payPeriodController,
                employeeError: _employeeError,
                hoursError: _hoursError,
                rateError: _rateError,
                payPeriodError: _payPeriodError,
                onSectorChanged: _onSectorChanged,
                onEmployeeChanged: (employeeId) {
                  setState(() {
                    _selectedEmployeeId = employeeId;
                    _employeeError = null;
                  });
                },
                onHoursChanged: (_) {
                  if (_hoursError != null) {
                    setState(() => _hoursError = null);
                  }
                },
                onRateChanged: (_) {
                  if (_rateError != null) {
                    setState(() => _rateError = null);
                  }
                },
                onPickPayPeriod: _pickPayPeriod,
                onSave: () => _submitSave(payrollProvider),
              ),
              if (state.successMessage != null) ...[
                const SizedBox(height: AppSpacing.sp3),
                AppSuccessContainer(message: state.successMessage!),
              ],
              if (state.error != null && state.records.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sp3),
                AppErrorContainer(message: state.error!),
              ],
            ],
            const SizedBox(height: AppSpacing.sp4),
            const SectionLabel('Payroll History'),
            const SizedBox(height: AppSpacing.sp2),
            _PayrollList(state: state, onRetry: _loadPayroll),
            const SizedBox(height: AppSpacing.sp3),
            Text(
              isBusinessOwner
                  ? 'Payroll records are immutable and stored permanently. '
                        'Only the Business Owner can calculate payroll.'
                  : 'You can only view your own payroll records. Payroll is '
                        'calculated by the Business Owner.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

/// Calculate Payroll form (wireframe `.card-flat`, Owner only): sector
/// filter, Employee selector, Hours Worked, Hourly Rate, Pay Period
/// picker, and the Save Payroll Record action.
class _CalculatePayrollForm extends StatelessWidget {
  const _CalculatePayrollForm({
    required this.selectedSectorId,
    required this.selectedEmployeeId,
    required this.isSubmitting,
    required this.hoursController,
    required this.rateController,
    required this.payPeriodController,
    required this.employeeError,
    required this.hoursError,
    required this.rateError,
    required this.payPeriodError,
    required this.onSectorChanged,
    required this.onEmployeeChanged,
    required this.onHoursChanged,
    required this.onRateChanged,
    required this.onPickPayPeriod,
    required this.onSave,
  });

  final int? selectedSectorId;
  final int? selectedEmployeeId;
  final bool isSubmitting;
  final TextEditingController hoursController;
  final TextEditingController rateController;
  final TextEditingController payPeriodController;
  final String? employeeError;
  final String? hoursError;
  final String? rateError;
  final String? payPeriodError;
  final ValueChanged<int?> onSectorChanged;
  final ValueChanged<int?> onEmployeeChanged;
  final ValueChanged<String> onHoursChanged;
  final ValueChanged<String> onRateChanged;
  final VoidCallback onPickPayPeriod;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final UsersState usersState = context.watch<UsersProvider>().state;
    final List<UserAccount> employees = usersState.users
        .where((UserAccount user) => !user.isBusinessOwner)
        .toList();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sp4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border, width: 1),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppFieldLabel('Business Sector'),
          DropdownButtonFormField<int>(
            initialValue: selectedSectorId,
            isExpanded: true,
            decoration: const InputDecoration(hintText: 'Select sector'),
            items: [
              for (final BusinessSectorData sector
                  in BusinessSectorsConfig.sectors)
                DropdownMenuItem(value: sector.id, child: Text(sector.name)),
            ],
            onChanged: !isSubmitting ? onSectorChanged : null,
          ),
          const SizedBox(height: AppSpacing.sp4),
          const AppFieldLabel('Employee'),
          DropdownButtonFormField<int>(
            initialValue: selectedEmployeeId,
            isExpanded: true,
            decoration: const InputDecoration(hintText: 'Select employee'),
            items: [
              for (final UserAccount employee in employees)
                DropdownMenuItem(
                  value: employee.id,
                  child: Text(employee.name),
                ),
            ],
            onChanged: !isSubmitting ? onEmployeeChanged : null,
          ),
          if (employeeError != null) AppErrorContainer(message: employeeError!),
          const SizedBox(height: AppSpacing.sp4),
          AppTextField(
            label: 'Hours Worked',
            controller: hoursController,
            enabled: !isSubmitting,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            hintText: '0.00',
            errorText: hoursError,
            onChanged: onHoursChanged,
          ),
          const SizedBox(height: AppSpacing.sp4),
          AppTextField(
            label: 'Hourly Rate (₱)',
            controller: rateController,
            enabled: !isSubmitting,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            hintText: '0.00',
            prefixIcon: const Padding(
              padding: EdgeInsetsDirectional.only(start: 12, end: 8),
              child: Text('₱', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
            errorText: rateError,
            onChanged: onRateChanged,
          ),
          const SizedBox(height: AppSpacing.sp4),
          AppTextField(
            label: 'Pay Period',
            controller: payPeriodController,
            enabled: !isSubmitting,
            readOnly: true,
            hintText: 'Select pay period end date',
            suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
            errorText: payPeriodError,
            onTap: onPickPayPeriod,
            onChanged: (_) {},
          ),
          const SizedBox(height: AppSpacing.sp3),
          LoadingButton(
            label: 'Save Payroll Record',
            loading: isSubmitting,
            onPressed: onSave,
          ),
          const SizedBox(height: AppSpacing.sp1),
          Text(
            'Computed salary (hours × rate) is calculated and saved by the '
            'system, and an Expense record is auto-created.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

/// Payroll records list with loading / error / empty / data states.
class _PayrollList extends StatelessWidget {
  const _PayrollList({required this.state, required this.onRetry});

  final PayrollState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.sp5),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
        ),
      );
    }

    if (state.error != null && state.records.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppErrorContainer(message: state.error!),
          const SizedBox(height: AppSpacing.sp2),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Retry'),
          ),
        ],
      );
    }

    if (state.records.isEmpty) {
      return const SizedBox(
        height: 160,
        child: AppEmptyState(
          icon: Icons.payments_outlined,
          title: 'No payroll records yet',
          message: 'Calculate payroll to get started.',
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border, width: 1),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (int i = 0; i < state.records.length; i++) ...[
            if (i > 0)
              Divider(height: 1, thickness: 1, color: AppColors.border),
            _PayrollRow(record: state.records[i]),
          ],
        ],
      ),
    );
  }
}

/// One payroll record row: employee + pay period + hours × rate on the
/// left, sector + computed salary + calculated date on the right.
class _PayrollRow extends StatelessWidget {
  const _PayrollRow({required this.record});

  final PayrollRecord record;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sp3,
        vertical: AppSpacing.sp3,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.employeeName,
                  style: textTheme.bodyMedium?.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Pay period: ${Formatters.formatDate(record.payPeriod)}',
                  style: textTheme.bodySmall,
                ),
                const SizedBox(height: 2),
                Text(
                  '${_formatDecimal(record.hoursWorked)} h × '
                  '${Formatters.formatCurrency(record.hourlyRate)}',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.inkMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sp3),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                Formatters.formatCurrency(record.computedSalary),
                style: textTheme.bodyMedium?.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.totalSales,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                record.sectorName,
                style: textTheme.labelSmall?.copyWith(
                  color: BusinessSectorsConfig.accentFor(record.sectorId),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                Formatters.formatDate(record.calculatedAt),
                style: textTheme.bodySmall?.copyWith(color: AppColors.inkMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _formatDecimal(double value) {
    if (value == value.roundToDouble()) return value.toStringAsFixed(0);
    return value.toString();
  }
}
