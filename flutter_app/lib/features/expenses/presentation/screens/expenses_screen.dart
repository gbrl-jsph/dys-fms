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
import '../../data/models/expense_record.dart';
import '../../data/models/save_expense_request.dart';
import '../../domain/expenses_state.dart';
import '../providers/expenses_provider.dart';

/// Expenses screen (FR-005, Screen 4).
///
/// Record an expense and review recent records per the expenses.html
/// wireframe and navigation-map Rule 3:
/// - Business Owner: sector dropdown (selectable; switching sectors
///   reloads the list), Amount + Description fields, Save Expense button.
/// - Event Manager: read-only assigned sector; Amount + Description
///   fields; the server scopes both the list and the new expense to the
///   assigned sector (no sector_id is sent).
/// - Employee/Staff: screen is unreachable (router redirect + hidden
///   bottom nav tab).
class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  int? _selectedSectorId;
  int? _syncedSectorId;
  String? _amountError;
  String? _sectorError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadExpenses());
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _loadExpenses() {
    final AuthState auth = context.read<AuthProvider>().state;
    final ExpensesProvider provider = context.read<ExpensesProvider>();
    final bool isBusinessOwner = auth.user?.isBusinessOwner ?? false;
    final int? sectorId = isBusinessOwner ? sectorIdFor(auth) : null;

    setState(() {
      _selectedSectorId = sectorId;
      _syncedSectorId = sectorId;
    });
    provider.loadExpenses(sectorId: sectorId);
  }

  void _onSectorChanged(int? sectorId) {
    setState(() {
      _selectedSectorId = sectorId;
      _sectorError = null;
    });
    context.read<ExpensesProvider>().loadExpenses(sectorId: sectorId);
  }

  bool _validate(bool isBusinessOwner) {
    final String amountText = _amountController.text.trim();

    setState(() {
      _amountError = _validateAmount(amountText);
      _sectorError = isBusinessOwner && _selectedSectorId == null
          ? 'Sector is required.'
          : null;
    });

    return _amountError == null && _sectorError == null;
  }

  /// Amount rules per the Validation Rules Matrix (UI layer):
  /// required, then a positive number, then the 999999.99 ceiling
  /// (matches the DECIMAL(8,2) limit enforced by the backend).
  String? _validateAmount(String amountText) {
    if (amountText.isEmpty) return 'Amount is required.';
    final double? amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      return 'Amount must be a positive number.';
    }
    if (amount > 999999.99) {
      return 'Amount must not exceed 999999.99.';
    }
    return null;
  }

  void _submitSave(ExpensesProvider provider, {required bool isBusinessOwner}) {
    if (provider.state.isSubmitting) return;
    if (!_validate(isBusinessOwner)) return;

    provider.clearSuccess();

    final SaveExpenseRequest request = SaveExpenseRequest(
      amount: double.parse(_amountController.text.trim()),
      description: _descriptionController.text.trim(),
      sectorId: isBusinessOwner ? _selectedSectorId : null,
    );

    setState(() {
      _amountController.clear();
      _descriptionController.clear();
    });

    provider.recordExpense(
      request,
      sectorId: isBusinessOwner ? _selectedSectorId : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final AuthState auth = context.watch<AuthProvider>().state;
    final ExpensesProvider expensesProvider = context.watch<ExpensesProvider>();
    final ExpensesState state = expensesProvider.state;
    final bool isBusinessOwner = auth.user?.isBusinessOwner ?? false;
    final bool isEventManager = auth.user?.isEventManager ?? false;

    // Keep the sector selector in sync after the Business Owner switches
    // the active sector (BR-38): the screen is kept alive in the shell,
    // so it must follow the client-side sector context. Manual dropdown
    // changes are tracked separately and are never overridden here.
    if (isBusinessOwner &&
        _syncedSectorId != null &&
        _syncedSectorId != sectorIdFor(auth)) {
      final int? currentSectorId = sectorIdFor(auth);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _selectedSectorId = currentSectorId;
          _syncedSectorId = currentSectorId;
          _sectorError = null;
        });
        expensesProvider.loadExpenses(sectorId: currentSectorId);
      });
    }

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
              title: 'Record Expense',
              onBack: () => context.go('/dashboard'),
            ),
            const SizedBox(height: AppSpacing.sp2),
            _RecordExpenseForm(
              isBusinessOwner: isBusinessOwner,
              isEventManager: isEventManager,
              assignedSectorId: auth.user?.sectorId,
              selectedSectorId: _selectedSectorId,
              isSubmitting: state.isSubmitting,
              amountController: _amountController,
              descriptionController: _descriptionController,
              amountError: _amountError,
              sectorError: _sectorError,
              onAmountChanged: (_) {
                if (_amountError != null) {
                  setState(() => _amountError = null);
                }
              },
              onSectorChanged: _onSectorChanged,
              onSave: () => _submitSave(
                expensesProvider,
                isBusinessOwner: isBusinessOwner,
              ),
            ),
            if (state.successMessage != null) ...[
              const SizedBox(height: AppSpacing.sp3),
              AppSuccessContainer(message: state.successMessage!),
            ],
            if (state.error != null && state.expenses.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sp3),
              AppErrorContainer(message: state.error!),
            ],
            const SizedBox(height: AppSpacing.sp4),
            const SectionLabel('Expense List'),
            const SizedBox(height: AppSpacing.sp2),
            _ExpensesList(state: state, onRetry: _loadExpenses),
            const SizedBox(height: AppSpacing.sp3),
            Text(
              'Expense records are immutable after creation. Only the Business Owner and Event Managers can record expenses.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

/// Record Expense form (wireframe `.card-flat`): sector selector,
/// Amount and Description fields, Save Expense button.
class _RecordExpenseForm extends StatelessWidget {
  const _RecordExpenseForm({
    required this.isBusinessOwner,
    required this.isEventManager,
    required this.assignedSectorId,
    required this.selectedSectorId,
    required this.isSubmitting,
    required this.amountController,
    required this.descriptionController,
    required this.amountError,
    required this.sectorError,
    required this.onAmountChanged,
    required this.onSectorChanged,
    required this.onSave,
  });

  final bool isBusinessOwner;
  final bool isEventManager;
  final int? assignedSectorId;
  final int? selectedSectorId;
  final bool isSubmitting;
  final TextEditingController amountController;
  final TextEditingController descriptionController;
  final String? amountError;
  final String? sectorError;
  final ValueChanged<String> onAmountChanged;
  final ValueChanged<int?> onSectorChanged;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final bool sectorSelectable = isBusinessOwner;

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
            initialValue: sectorSelectable
                ? selectedSectorId
                : assignedSectorId,
            isExpanded: true,
            decoration: const InputDecoration(hintText: 'Select sector'),
            items: [
              for (final BusinessSectorData sector
                  in BusinessSectorsConfig.sectors)
                DropdownMenuItem(value: sector.id, child: Text(sector.name)),
            ],
            onChanged: sectorSelectable && !isSubmitting
                ? onSectorChanged
                : null,
          ),
          if (sectorError != null) AppErrorContainer(message: sectorError!),
          if (isEventManager) ...[
            const SizedBox(height: AppSpacing.sp1),
            Text(
              'Expenses are recorded under your assigned sector.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: AppSpacing.sp4),
          AppTextField(
            label: 'Amount',
            controller: amountController,
            enabled: !isSubmitting,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            hintText: '0.00',
            prefixIcon: const Icon(Icons.attach_money, size: 18),
            errorText: amountError,
            onChanged: onAmountChanged,
          ),
          const SizedBox(height: AppSpacing.sp4),
          AppTextField(
            label: 'Description',
            controller: descriptionController,
            enabled: !isSubmitting,
            hintText: 'Optional',
            onChanged: (_) {},
          ),
          const SizedBox(height: AppSpacing.sp3),
          LoadingButton(
            label: 'Save Expense',
            loading: isSubmitting,
            onPressed: onSave,
          ),
        ],
      ),
    );
  }
}

/// Expense records list with loading / error / empty / data states.
class _ExpensesList extends StatelessWidget {
  const _ExpensesList({required this.state, required this.onRetry});

  final ExpensesState state;
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

    if (state.error != null && state.expenses.isEmpty) {
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

    if (state.expenses.isEmpty) {
      return const SizedBox(
        height: 160,
        child: AppEmptyState(
          icon: Icons.receipt_long_outlined,
          title: 'No records yet',
          message: 'Record an expense to get started.',
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
          for (int i = 0; i < state.expenses.length; i++) ...[
            if (i > 0)
              Divider(height: 1, thickness: 1, color: AppColors.border),
            _ExpenseRow(record: state.expenses[i]),
          ],
        ],
      ),
    );
  }
}

/// One expense record row: amount + description on the left,
/// sector + recorder + date on the right.
class _ExpenseRow extends StatelessWidget {
  const _ExpenseRow({required this.record});

  final ExpenseRecord record;

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
                  Formatters.formatCurrency(record.amount),
                  style: textTheme.bodyMedium?.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.totalExpenses,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                if (record.description != null) ...[
                  const SizedBox(height: 2),
                  Text(record.description!, style: textTheme.bodySmall),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sp3),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                record.sectorName,
                style: textTheme.labelSmall?.copyWith(
                  color: BusinessSectorsConfig.accentFor(record.sectorId),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(record.recordedByName, style: textTheme.bodySmall),
              Text(
                Formatters.formatDate(record.recordedAt),
                style: textTheme.bodySmall?.copyWith(color: AppColors.inkMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
