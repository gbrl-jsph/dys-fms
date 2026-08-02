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
import '../../data/models/save_sale_request.dart';
import '../../data/models/sales_transaction.dart';
import '../../domain/sales_state.dart';
import '../providers/sales_provider.dart';

/// Sales screen (FR-004, Screen 3).
///
/// Record a sale and review recent transactions per the sales.html
/// wireframe and navigation-map Rule 3:
/// - Business Owner: sector dropdown (selectable; switching sectors
///   reloads the list), Amount + Description fields, Save Sale button.
/// - Event Manager: read-only assigned sector; Amount + Description
///   fields; the server scopes both the list and the new sale to the
///   assigned sector (no sector_id is sent).
/// - Employee/Staff: screen is unreachable (router redirect + hidden
///   bottom nav tab).
class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  int? _selectedSectorId;
  int? _syncedSectorId;
  String? _amountError;
  String? _sectorError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSales());
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _loadSales() {
    final AuthState auth = context.read<AuthProvider>().state;
    final SalesProvider provider = context.read<SalesProvider>();
    final bool isBusinessOwner = auth.user?.isBusinessOwner ?? false;
    final int? sectorId = isBusinessOwner ? sectorIdFor(auth) : null;

    setState(() {
      _selectedSectorId = sectorId;
      _syncedSectorId = sectorId;
    });
    provider.loadSales(sectorId: sectorId);
  }

  void _onSectorChanged(int? sectorId) {
    setState(() {
      _selectedSectorId = sectorId;
      _sectorError = null;
    });
    context.read<SalesProvider>().loadSales(sectorId: sectorId);
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

  void _submitSave(SalesProvider provider, {required bool isBusinessOwner}) {
    if (provider.state.isSubmitting) return;
    if (!_validate(isBusinessOwner)) return;

    provider.clearSuccess();

    final SaveSaleRequest request = SaveSaleRequest(
      amount: double.parse(_amountController.text.trim()),
      description: _descriptionController.text.trim(),
      sectorId: isBusinessOwner ? _selectedSectorId : null,
    );

    setState(() {
      _amountController.clear();
      _descriptionController.clear();
    });

    provider.recordSale(
      request,
      sectorId: isBusinessOwner ? _selectedSectorId : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final AuthState auth = context.watch<AuthProvider>().state;
    final SalesProvider salesProvider = context.watch<SalesProvider>();
    final SalesState state = salesProvider.state;
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
        salesProvider.loadSales(sectorId: currentSectorId);
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
              title: 'Record Sale',
              onBack: () => context.go('/dashboard'),
            ),
            const SizedBox(height: AppSpacing.sp2),
            _RecordSaleForm(
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
              onSave: () =>
                  _submitSave(salesProvider, isBusinessOwner: isBusinessOwner),
            ),
            if (state.successMessage != null) ...[
              const SizedBox(height: AppSpacing.sp3),
              AppSuccessContainer(message: state.successMessage!),
            ],
            if (state.error != null && state.sales.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sp3),
              AppErrorContainer(message: state.error!),
            ],
            const SizedBox(height: AppSpacing.sp4),
            const SectionLabel('Sales List'),
            const SizedBox(height: AppSpacing.sp2),
            _SalesList(state: state, onRetry: _loadSales),
            const SizedBox(height: AppSpacing.sp3),
            Text(
              'Sales records are immutable after creation. Only the Business Owner and Event Managers can record sales.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

/// Record Sale form (wireframe `.card-flat`): sector selector,
/// Amount and Description fields, Save Sale button.
class _RecordSaleForm extends StatelessWidget {
  const _RecordSaleForm({
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
              'Sales are recorded under your assigned sector.',
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
            label: 'Save Sale',
            loading: isSubmitting,
            onPressed: onSave,
          ),
        ],
      ),
    );
  }
}

/// Sales transaction list with loading / error / empty / data states.
class _SalesList extends StatelessWidget {
  const _SalesList({required this.state, required this.onRetry});

  final SalesState state;
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

    if (state.error != null && state.sales.isEmpty) {
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

    if (state.sales.isEmpty) {
      return const SizedBox(
        height: 160,
        child: AppEmptyState(
          icon: Icons.receipt_long_outlined,
          title: 'No records yet',
          message: 'Record a sale to get started.',
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
          for (int i = 0; i < state.sales.length; i++) ...[
            if (i > 0)
              Divider(height: 1, thickness: 1, color: AppColors.border),
            _SalesRow(transaction: state.sales[i]),
          ],
        ],
      ),
    );
  }
}

/// One sales transaction row: amount + description on the left,
/// sector + recorder + date on the right.
class _SalesRow extends StatelessWidget {
  const _SalesRow({required this.transaction});

  final SalesTransaction transaction;

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
                  Formatters.formatCurrency(transaction.amount),
                  style: textTheme.bodyMedium?.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.totalSales,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                if (transaction.description != null) ...[
                  const SizedBox(height: 2),
                  Text(transaction.description!, style: textTheme.bodySmall),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sp3),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                transaction.sectorName,
                style: textTheme.labelSmall?.copyWith(
                  color: BusinessSectorsConfig.accentFor(transaction.sectorId),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(transaction.recordedByName, style: textTheme.bodySmall),
              Text(
                Formatters.formatDate(transaction.recordedAt),
                style: textTheme.bodySmall?.copyWith(color: AppColors.inkMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
