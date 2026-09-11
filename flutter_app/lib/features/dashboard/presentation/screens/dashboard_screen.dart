import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/business_sectors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/initials.dart';
import '../../../../core/utils/sector_context.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_error_container.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../../core/widgets/section_label.dart';
import '../../../../core/widgets/sector_logo.dart';
import '../../../auth/domain/auth_state.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/financial_summary.dart';
import '../../data/models/recent_transaction.dart';
import '../../domain/dashboard_state.dart';
import '../providers/dashboard_provider.dart';

/// Dashboard (FR-002, Screen 2).
///
/// Role-based landing screen per the functional requirements:
/// - Business Owner: sector chip/selector (opens Sector Switcher),
///   financial summary cards, chart placeholder, and quick actions
///   (Record Sale, Record Expense, View Reports, View Payroll,
///   Manage Users).
/// - Event Manager: read-only sector chip, summary cards scoped to the
///   assigned sector, and quick actions without Manage Users.
/// - Employee/Staff: read-only sector chip and the View Payroll quick
///   action only (no financial summary or chart — the reports API is
///   Business Owner / Event Manager only).
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  _TransactionVisibility _visibility = _TransactionVisibility.both;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSummary());
  }

  /// Loads the financial summary once, scoped to the current sector.
  ///
  /// The Business Owner's sector context comes from the login
  /// `default_sector` (FRS BR: DYS Event Management on login); the
  /// Event Manager's summary is always scoped by the server to the
  /// assigned sector, so no `sector_id` is sent for that role.
  void _loadSummary() {
    final AuthState auth = context.read<AuthProvider>().state;
    final DashboardProvider provider = context.read<DashboardProvider>();
    final bool isOwner = auth.user?.isBusinessOwner ?? false;
    final bool isManager = auth.user?.isEventManager ?? false;

    if (!isOwner && !isManager) return;

    final int? sectorId = isOwner
        ? (auth.defaultSector?.id ??
              auth.user?.sectorId ??
              BusinessSectorsConfig.sectors.first.id)
        : null;
    provider.loadSummary(sectorId: sectorId);
  }

  @override
  Widget build(BuildContext context) {
    final AuthState auth = context.watch<AuthProvider>().state;
    final DashboardState dashboard = context.watch<DashboardProvider>().state;
    final String? name = auth.user?.name;
    final bool isBusinessOwner = auth.user?.isBusinessOwner ?? false;
    final bool hasFinancialSummary =
        isBusinessOwner || (auth.user?.isEventManager ?? false);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.sp1,
            AppSpacing.sp3,
            AppSpacing.sp4,
            AppSpacing.sp4,
          ),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Dashboard',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                ),
                _AvatarMenu(
                  name: name,
                  role: auth.user?.role ?? '',
                  onLogout: () => context.read<AuthProvider>().logout(),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sp4),
            _SectorChip(
              sectorId: sectorIdFor(auth),
              sectorName: _sectorName(auth),
              isInteractive: isBusinessOwner,
              onTap: isBusinessOwner
                  ? () => context.go('/sector-switcher')
                  : null,
            ),
            if (hasFinancialSummary) ...[
              const SizedBox(height: AppSpacing.sp4),
              const SectionLabel('Financial Summary'),
              const SizedBox(height: AppSpacing.sp2),
              _SummaryCards(state: dashboard, onRetry: _loadSummary),
              const SizedBox(height: AppSpacing.sp4),
              const SizedBox(height: AppSpacing.sp4),
              _RecentActivity(
                transactions: dashboard.recentTransactions,
                visibility: _visibility,
                onDisplayOptions: _showDisplayOptions,
              ),
              const SizedBox(height: AppSpacing.sp4),
            ],
            const SectionLabel('Quick Actions'),
            const SizedBox(height: AppSpacing.sp2),
            _QuickActions(
              isBusinessOwner: isBusinessOwner,
              isEventManager: auth.user?.isEventManager ?? false,
              isEmployee: auth.user?.isEmployee ?? false,
            ),
          ],
        ),
      ),
    );
  }

  String _sectorName(AuthState auth) {
    if (auth.defaultSector?.name != null) return auth.defaultSector!.name;
    return BusinessSectorsConfig.nameFor(sectorIdFor(auth), fallback: '—');
  }

  Future<void> _showDisplayOptions() async {
    final _TransactionVisibility? selection =
        await showModalBottomSheet<_TransactionVisibility>(
          context: context,
          showDragHandle: true,
          builder: (BuildContext context) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.sp4,
                AppSpacing.sp2,
                AppSpacing.sp4,
                AppSpacing.sp4,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Display Options',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.sp2),
                  for (final _TransactionVisibility option
                      in _TransactionVisibility.values)
                    ListTile(
                      leading: Icon(
                        option == _visibility
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                      ),
                      title: Text(option.label),
                      onTap: () => Navigator.pop(context, option),
                    ),
                ],
              ),
            ),
          ),
        );
    if (selection != null && mounted) setState(() => _visibility = selection);
  }
}

enum _TransactionVisibility {
  both('Sales and expenses'),
  sales('Sales only'),
  expenses('Expenses only');

  const _TransactionVisibility(this.label);
  final String label;
}

class _RecentActivity extends StatelessWidget {
  const _RecentActivity({
    required this.transactions,
    required this.visibility,
    required this.onDisplayOptions,
  });

  final List<RecentTransaction> transactions;
  final _TransactionVisibility visibility;
  final VoidCallback onDisplayOptions;

  @override
  Widget build(BuildContext context) {
    final List<RecentTransaction> visible = transactions.where((transaction) {
      return visibility == _TransactionVisibility.both ||
          transaction.isSale == (visibility == _TransactionVisibility.sales);
    }).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(child: SectionLabel('Recent Activity')),
            TextButton.icon(
              onPressed: onDisplayOptions,
              icon: const Icon(Icons.tune, size: 18),
              label: const Text('Display'),
            ),
          ],
        ),
        if (visible.isEmpty)
          Container(
            padding: const EdgeInsets.all(AppSpacing.sp4),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: const Center(child: Text('No recent transactions')),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (int index = 0; index < visible.length; index++) ...[
                  if (index > 0) Divider(height: 1, color: AppColors.border),
                  _RecentTransactionRow(transaction: visible[index]),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _RecentTransactionRow extends StatelessWidget {
  const _RecentTransactionRow({required this.transaction});
  final RecentTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final Color color = transaction.isSale
        ? AppColors.totalSales
        : AppColors.totalExpenses;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sp3,
        vertical: AppSpacing.sp2,
      ),
      child: Row(
        children: [
          Icon(
            transaction.isSale ? Icons.trending_up : Icons.trending_down,
            color: color,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sp2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.isSale ? 'Sale' : 'Expense',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  transaction.description?.trim().isNotEmpty == true
                      ? transaction.description!
                      : 'No description',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sp2),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                Formatters.formatCurrency(transaction.amount),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              Text(
                Formatters.formatDate(transaction.localRecordedAt),
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.inkMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Profile avatar menu (navigation-map Rule 2: logout via the avatar
/// menu on any authenticated screen — no dedicated screen). Shows the
/// signed-in user, a Settings entry (appearance preferences live on
/// the Settings screen) and a Logout action that ends the session and
/// returns to the Login screen.
class _AvatarMenu extends StatelessWidget {
  const _AvatarMenu({
    required this.name,
    required this.role,
    required this.onLogout,
  });

  final String? name;
  final String role;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Profile',
      onSelected: (String value) {
        if (value == 'logout') {
          onLogout();
        }
        if (value == 'settings') {
          context.go('/settings');
        }
        if (value == 'profile') {
          context.go('/profile');
        }
        if (value == 'change_password') {
          context.go('/change-password');
        }
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<String>(
          value: 'profile',
          child: const Row(
            children: [
              Icon(Icons.person_outline, size: 18),
              SizedBox(width: AppSpacing.sp2),
              Text('Profile'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'change_password',
          child: const Row(
            children: [
              Icon(Icons.lock_outline, size: 18),
              SizedBox(width: AppSpacing.sp2),
              Text('Change Password'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'settings',
          child: const Row(
            children: [
              Icon(Icons.settings_outlined, size: 18),
              SizedBox(width: AppSpacing.sp2),
              Text('Settings'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name ?? '',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                role,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.inkMuted),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, size: 18),
              SizedBox(width: AppSpacing.sp2),
              Text('Logout'),
            ],
          ),
        ),
      ],
      child: AppAvatar(initials: initialsFor(name)),
    );
  }
}

/// Sector chip (ui-style-guide.md: `.sector-chip`).
///
/// Displays the current sector with its signature accent dot. Tappable
/// (navigates to the Sector Switcher) for the Business Owner only;
/// read-only for Event Managers and Employees.
class _SectorChip extends StatelessWidget {
  const _SectorChip({
    required this.sectorId,
    required this.sectorName,
    required this.isInteractive,
    required this.onTap,
  });

  final int? sectorId;
  final String sectorName;
  final bool isInteractive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sp4,
            vertical: AppSpacing.sp3,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Row(
            children: [
              SectorLogo(sectorId: sectorId, size: 24),
              const SizedBox(width: AppSpacing.sp2),
              Expanded(
                child: Text(
                  sectorName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
              ),
              if (isInteractive)
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 18,
                  color: AppColors.inkSecondary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Financial summary stat cards with loading / error / data states.
class _SummaryCards extends StatelessWidget {
  const _SummaryCards({required this.state, required this.onRetry});

  final DashboardState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return const SizedBox(height: 96, child: AppLoadingIndicator());
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

    final FinancialSummary? summary = state.summary;
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Total Sales',
            value: Formatters.formatCurrency(summary?.totalSales ?? 0),
            valueColor: AppColors.totalSales,
          ),
        ),
        const SizedBox(width: AppSpacing.sp3),
        Expanded(
          child: _StatCard(
            label: 'Total Exp.',
            value: Formatters.formatCurrency(summary?.totalExpenses ?? 0),
            valueColor: AppColors.totalExpenses,
          ),
        ),
        const SizedBox(width: AppSpacing.sp3),
        Expanded(
          child: _StatCard(
            label: 'Net Balance',
            value: Formatters.formatCurrency(summary?.netBalance ?? 0),
            valueColor: AppColors.netBalance,
          ),
        ),
      ],
    );
  }
}

/// Stat card (ui-style-guide.md: `.stat-card`).
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sp3),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: AppShadows.shadow1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.inkSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sp1),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: valueColor,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Role-based quick actions per FR-002 (rows of 2 per the wireframes):
/// - Business Owner: Record Sale, Record Expense, View Reports,
///   View Payroll, Manage Users
/// - Event Manager: Record Sale, Record Expense, View Reports,
///   View Payroll
/// - Employee/Staff: View Payroll only
class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.isBusinessOwner,
    required this.isEventManager,
    required this.isEmployee,
  });

  final bool isBusinessOwner;
  final bool isEventManager;
  final bool isEmployee;

  @override
  Widget build(BuildContext context) {
    final bool showTransactionAction =
        isBusinessOwner || isEventManager || isEmployee;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showTransactionAction) ...[
          FilledButton.icon(
            onPressed: () => _showTransactionChoice(context),
            icon: const Icon(Icons.add, size: 20),
            label: const Text('Add Transaction'),
          ),
        ] else ...[
          OutlinedButton(
            onPressed: () => context.go('/reports'),
            child: const Text('View Reports'),
          ),
        ],
      ],
    );
  }

  void _showTransactionChoice(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sp4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Add Transaction',
                style: Theme.of(sheetContext).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.sp2),
              if (!isEmployee) ListTile(
                leading: const Icon(Icons.trending_up),
                title: const Text('Record Sale'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  context.go('/sales');
                },
              ),
              ListTile(
                leading: const Icon(Icons.trending_down),
                title: const Text('Record Expense'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  context.go('/expenses');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
