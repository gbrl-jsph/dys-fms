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
import '../../../../core/widgets/app_report_charts.dart';
import '../../../../core/widgets/app_screen_header.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/loading_button.dart';
import '../../../../core/widgets/section_label.dart';
import '../../../auth/domain/auth_state.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/report_data.dart';
import '../../domain/reports_state.dart';
import '../providers/reports_provider.dart';

/// Reports screen (FR-007, Screen 6).
///
/// Report generation per the reports.html wireframe and API spec:
/// - Business Owner: Report Type selector (Summary, Sales, Expenses,
///   Analytics), sector selector ("All Sectors" cross-sector or one of
///   the four sectors), From/To date pickers, Generate Report button.
/// - Event Manager: same form minus Analytics (no sector selector — the
///   server scopes reports to the assigned sector).
/// - Employee/Staff: screen is unreachable (router redirect + hidden
///   bottom nav tab; the API returns 403 for this role).
///
/// Charts are rendered as [AppChartPlaceholder]s per the wireframe —
/// no chart rendering is invented. The analytics charts object
/// (sales_trend / expense_breakdown / sector_comparison) maps to the
/// three analytics placeholders.
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  /// Report types allowed by the Validation Rules Matrix.
  static const List<String> _reportTypes = [
    'summary',
    'sales',
    'expenses',
    'analytics',
  ];

  final TextEditingController _dateFromController = TextEditingController();
  final TextEditingController _dateToController = TextEditingController();

  String _reportType = 'summary';
  int? _selectedSectorId;
  int? _syncedSectorId;
  DateTime? _dateFrom;
  DateTime? _dateTo;
  String? _typeError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final AuthState auth = context.read<AuthProvider>().state;
      if (auth.user?.isBusinessOwner ?? false) {
        final int? sectorId = sectorIdFor(auth);
        setState(() {
          _selectedSectorId = sectorId;
          _syncedSectorId = sectorId;
        });
      }
    });
  }

  @override
  void dispose() {
    _dateFromController.dispose();
    _dateToController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(
    TextEditingController controller, {
    required ValueChanged<DateTime> onPicked,
  }) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      onPicked(picked);
      controller.text = Formatters.formatDate(picked);
    });
  }

  bool _validate() {
    setState(() {
      _typeError = _reportTypes.contains(_reportType)
          ? null
          : 'The selected type is invalid.';
    });
    return _typeError == null;
  }

  void _generate(ReportsProvider provider) {
    if (provider.state.isLoading) return;
    if (!_validate()) return;

    final AuthState auth = context.read<AuthProvider>().state;
    final bool isBusinessOwner = auth.user?.isBusinessOwner ?? false;

    provider.clearError();
    provider.generateReport(
      type: _reportType,
      dateFrom: _dateFrom,
      dateTo: _dateTo,
      sectorId: isBusinessOwner ? _selectedSectorId : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final AuthState auth = context.watch<AuthProvider>().state;
    final ReportsProvider reportsProvider = context.watch<ReportsProvider>();
    final ReportsState state = reportsProvider.state;
    final bool isBusinessOwner = auth.user?.isBusinessOwner ?? false;
    final bool isEventManager = auth.user?.isEventManager ?? false;
    final bool isAnalytics = _reportType == 'analytics';

    // Keep the sector selector in sync and discard the stale report after
    // the Business Owner switches the active sector (BR-38): the screen is
    // kept alive in the shell, so it must follow the client-side context.
    // Manual dropdown changes are tracked separately and are not overridden.
    if (isBusinessOwner &&
        _syncedSectorId != null &&
        _syncedSectorId != sectorIdFor(auth)) {
      final int? currentSectorId = sectorIdFor(auth);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _selectedSectorId = currentSectorId;
          _syncedSectorId = currentSectorId;
        });
        reportsProvider.clearReport();
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
              title: 'Financial Reports',
              onBack: () => context.go('/dashboard'),
            ),
            const SizedBox(height: AppSpacing.sp2),
            _ReportForm(
              isBusinessOwner: isBusinessOwner,
              isEventManager: isEventManager,
              reportType: _reportType,
              selectedSectorId: _selectedSectorId,
              isGenerating: state.isLoading,
              dateFromController: _dateFromController,
              dateToController: _dateToController,
              typeError: _typeError,
              onTypeChanged: (type) {
                setState(() {
                  _reportType = type ?? 'summary';
                  _typeError = null;
                });
              },
              onSectorChanged: (sectorId) {
                setState(() => _selectedSectorId = sectorId);
              },
              onPickDateFrom: () => _pickDate(
                _dateFromController,
                onPicked: (date) => _dateFrom = date,
              ),
              onPickDateTo: () => _pickDate(
                _dateToController,
                onPicked: (date) => _dateTo = date,
              ),
              onGenerate: () => _generate(reportsProvider),
            ),
            const SizedBox(height: AppSpacing.sp4),
            _ReportContent(
              state: state,
              isAnalytics: isAnalytics,
              onRetry: () => _generate(reportsProvider),
            ),
          ],
        ),
      ),
    );
  }
}

/// Report generation form (wireframe `.card-flat`): Report Type selector,
/// sector selector (Owner only, with a cross-sector "All Sectors" option),
/// From/To date pickers, and the Generate Report action.
class _ReportForm extends StatelessWidget {
  const _ReportForm({
    required this.isBusinessOwner,
    required this.isEventManager,
    required this.reportType,
    required this.selectedSectorId,
    required this.isGenerating,
    required this.dateFromController,
    required this.dateToController,
    required this.typeError,
    required this.onTypeChanged,
    required this.onSectorChanged,
    required this.onPickDateFrom,
    required this.onPickDateTo,
    required this.onGenerate,
  });

  final bool isBusinessOwner;
  final bool isEventManager;
  final String reportType;
  final int? selectedSectorId;
  final bool isGenerating;
  final TextEditingController dateFromController;
  final TextEditingController dateToController;
  final String? typeError;
  final ValueChanged<String?> onTypeChanged;
  final ValueChanged<int?> onSectorChanged;
  final VoidCallback onPickDateFrom;
  final VoidCallback onPickDateTo;
  final VoidCallback onGenerate;

  static const List<(String, String)> _types = [
    ('summary', 'Summary'),
    ('sales', 'Sales'),
    ('expenses', 'Expenses'),
    ('analytics', 'Analytics'),
  ];

  @override
  Widget build(BuildContext context) {
    final List<(String, String)> types = isBusinessOwner
        ? _types
        : _types.take(3).toList();

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
          const AppFieldLabel('Report Type'),
          DropdownButtonFormField<String>(
            initialValue: reportType,
            isExpanded: true,
            decoration: const InputDecoration(hintText: 'Select type'),
            items: [
              for (final (String value, String label) in types)
                DropdownMenuItem(value: value, child: Text(label)),
            ],
            onChanged: !isGenerating ? onTypeChanged : null,
          ),
          if (typeError != null) AppErrorContainer(message: typeError!),
          if (isBusinessOwner) ...[
            const SizedBox(height: AppSpacing.sp4),
            const AppFieldLabel('Business Sector'),
            DropdownButtonFormField<int?>(
              initialValue: selectedSectorId,
              isExpanded: true,
              decoration: const InputDecoration(hintText: 'Select sector'),
              items: [
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text('All Sectors'),
                ),
                for (final BusinessSectorData sector
                    in BusinessSectorsConfig.sectors)
                  DropdownMenuItem<int?>(
                    value: sector.id,
                    child: Text(sector.name),
                  ),
              ],
              onChanged: !isGenerating ? onSectorChanged : null,
            ),
            const SizedBox(height: AppSpacing.sp1),
            Text(
              'All Sectors generates a cross-sector report.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: AppSpacing.sp4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppTextField(
                  label: 'From',
                  controller: dateFromController,
                  enabled: !isGenerating,
                  readOnly: true,
                  hintText: 'MM/DD/YYYY',
                  suffixIcon: const Icon(
                    Icons.calendar_today_outlined,
                    size: 18,
                  ),
                  onTap: onPickDateFrom,
                  onChanged: (_) {},
                ),
              ),
              const SizedBox(width: AppSpacing.sp3),
              Expanded(
                child: AppTextField(
                  label: 'To',
                  controller: dateToController,
                  enabled: !isGenerating,
                  readOnly: true,
                  hintText: 'MM/DD/YYYY',
                  suffixIcon: const Icon(
                    Icons.calendar_today_outlined,
                    size: 18,
                  ),
                  onTap: onPickDateTo,
                  onChanged: (_) {},
                ),
              ),
            ],
          ),
          if (isEventManager) ...[
            const SizedBox(height: AppSpacing.sp1),
            Text(
              'Reports are scoped to your assigned sector.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: AppSpacing.sp3),
          LoadingButton(
            label: 'Generate Report',
            loading: isGenerating,
            onPressed: onGenerate,
          ),
        ],
      ),
    );
  }
}

/// Report output area: loading / error / empty / generated states.
///
/// Real charts are rendered from [ReportData] — sales trend (bar),
/// expense breakdown (pie/donut), and sector comparison (bar). Empty
/// datasets show an inline "No data to display" chart container
/// rather than crashing or showing stale data.
class _ReportContent extends StatelessWidget {
  const _ReportContent({
    required this.state,
    required this.isAnalytics,
    required this.onRetry,
  });

  final ReportsState state;
  final bool isAnalytics;
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

    if (state.error != null) {
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

    final ReportData? report = state.report;
    if (report == null) {
      return const SizedBox(
        height: 200,
        child: AppEmptyState(
          icon: Icons.bar_chart_outlined,
          title: 'No report yet',
          message: 'Select a report type and press Generate Report.',
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isAnalytics) ...[
          const SectionLabel('Sales Trend'),
          const SizedBox(height: AppSpacing.sp2),
          ReportBarChart(
            points: report.salesTrend,
            title: 'Sales Trend',
            barColor: AppColors.primary,
          ),
          const SizedBox(height: AppSpacing.sp4),
          const SectionLabel('Expense Breakdown'),
          const SizedBox(height: AppSpacing.sp2),
          ReportPieChart(points: report.expenseBreakdown),
          const SizedBox(height: AppSpacing.sp4),
          const SectionLabel('Sector Comparison'),
          const SizedBox(height: AppSpacing.sp2),
          ReportSectorChart(sectors: report.sectorComparison),
        ] else ...[
          const SectionLabel('Sales Graph'),
          const SizedBox(height: AppSpacing.sp2),
          ReportBarChart(
            points: report.salesTrend,
            title: 'Sales Graph',
            barColor: AppColors.primary,
          ),
          const SizedBox(height: AppSpacing.sp4),
          const SectionLabel('Expense Chart'),
          const SizedBox(height: AppSpacing.sp2),
          ReportPieChart(points: report.expenseBreakdown),
        ],
        const SizedBox(height: AppSpacing.sp4),
        const SectionLabel('Financial Summary'),
        const SizedBox(height: AppSpacing.sp2),
        _SummaryTable(report: report),
      ],
    );
  }
}

/// Financial Summary table per the reports.html wireframe: Total Sales,
/// Total Expenses, and Net Balance as the emphasized total row.
class _SummaryTable extends StatelessWidget {
  const _SummaryTable({required this.report});

  final ReportData report;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border, width: 1),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SummaryRow(
            label: 'Total Sales',
            value: Formatters.formatCurrency(report.totalSales),
            valueColor: AppColors.totalSales,
          ),
          _Divider(),
          _SummaryRow(
            label: 'Total Expenses',
            value: Formatters.formatCurrency(report.totalExpenses),
            valueColor: AppColors.totalExpenses,
          ),
          if (report.payrollExpenses != null) ...[
            _Divider(),
            _SummaryRow(
              label: 'Payroll Expenses',
              value: Formatters.formatCurrency(report.payrollExpenses!),
              valueColor: AppColors.ink,
            ),
          ],
          _Divider(),
          Container(
            color: AppColors.surfaceAlt,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sp3,
              vertical: AppSpacing.sp3,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Net Balance',
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  Formatters.formatCurrency(report.netBalance),
                  style: textTheme.bodyMedium?.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.netBalance,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sp3,
        vertical: AppSpacing.sp3,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: textTheme.bodyMedium),
          Text(
            value,
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: valueColor,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, thickness: 1, color: AppColors.border);
  }
}
