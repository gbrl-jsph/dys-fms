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
import '../../../../core/widgets/app_chart_placeholder.dart';
import '../../../../core/widgets/app_error_container.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../../core/widgets/section_label.dart';
import '../../../auth/domain/auth_state.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/financial_summary.dart';
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
              sectorName: _sectorName(auth),
              accent: BusinessSectorsConfig.accentFor(sectorIdFor(auth)),
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
              if (isBusinessOwner) ...[
                const SectionLabel('Sales Overview'),
                const SizedBox(height: AppSpacing.sp2),
                const AppChartPlaceholder(),
                const SizedBox(height: AppSpacing.sp4),
              ],
            ],
            const SectionLabel('Quick Actions'),
            const SizedBox(height: AppSpacing.sp2),
            _QuickActions(
              isBusinessOwner: isBusinessOwner,
              isEventManager: auth.user?.isEventManager ?? false,
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
}

/// Profile avatar menu (navigation-map Rule 2: logout via the avatar
/// menu on any authenticated screen — no dedicated screen). Shows the
/// signed-in user and a Logout action that ends the session and returns
/// to the Login screen.
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
        if (value == 'logout') onLogout();
      },
      itemBuilder: (BuildContext context) => [
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
    required this.sectorName,
    required this.accent,
    required this.isInteractive,
    required this.onTap,
  });

  final String sectorName;
  final Color accent;
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
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.grid_view_rounded, size: 14, color: accent),
              ),
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
                const Icon(
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
  });

  final bool isBusinessOwner;
  final bool isEventManager;

  @override
  Widget build(BuildContext context) {
    final bool showOperational = isBusinessOwner || isEventManager;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showOperational) ...[
          _QuickActionsRow(
            children: [
              ElevatedButton.icon(
                onPressed: () => context.go('/sales'),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Record Sale'),
              ),
              const SizedBox(width: AppSpacing.sp3),
              FilledButton.icon(
                onPressed: () => context.go('/expenses'),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Record Expense'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sp3),
          _QuickActionsRow(
            children: [
              OutlinedButton(
                onPressed: () => context.go('/reports'),
                child: const Text('View Reports'),
              ),
              const SizedBox(width: AppSpacing.sp3),
              OutlinedButton(
                onPressed: () => context.go('/payroll'),
                child: const Text('View Payroll'),
              ),
            ],
          ),
          if (isBusinessOwner) ...[
            const SizedBox(height: AppSpacing.sp3),
            OutlinedButton(
              onPressed: () => context.go('/users'),
              child: const Text('Manage Users'),
            ),
          ],
        ] else ...[
          OutlinedButton(
            onPressed: () => context.go('/payroll'),
            child: const Text('View Payroll'),
          ),
        ],
      ],
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(width: AppSpacing.sp3),
          Expanded(child: children[i]),
        ],
      ],
    );
  }
}
