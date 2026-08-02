import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/business_sectors.dart';
import '../../../../core/utils/sector_context.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_container.dart';
import '../../../../core/widgets/app_screen_header.dart';
import '../../../../core/widgets/loading_button.dart';
import '../../../../core/widgets/section_label.dart';
import '../../../../core/widgets/sector_logo.dart';
import '../../../auth/data/models/login_response.dart';
import '../../../auth/domain/auth_state.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';
import '../../data/models/business_sector.dart';
import '../../domain/sectors_state.dart';
import '../providers/sectors_provider.dart';

/// Sector Switcher (FR-008, Screen 7).
///
/// Changes the active business sector context per the
/// sector-switcher.html wireframe and navigation-map Rule 8:
/// - Business Owner: tappable sector cards (radio selection), Switch
///   Sector + Cancel actions. On switch, the client-side sector context
///   updates app-wide and the Dashboard refreshes for the new sector
///   (no confirmation dialog).
/// - Event Manager / Employee: read-only view with the current sector
///   highlighted. The router redirects them away (FR-008, API 403);
///   this is a defensive rendering only.
class SectorSwitcherScreen extends StatefulWidget {
  const SectorSwitcherScreen({super.key});

  @override
  State<SectorSwitcherScreen> createState() => _SectorSwitcherScreenState();
}

class _SectorSwitcherScreenState extends State<SectorSwitcherScreen> {
  int? _selectedSectorId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final AuthState auth = context.read<AuthProvider>().state;
      _selectedSectorId = sectorIdFor(auth);
      context.read<SectorsProvider>().loadSectors();
    });
  }

  Future<void> _switchSector(int sectorId) async {
    final SectorsProvider provider = context.read<SectorsProvider>();
    if (provider.state.isSwitching) return;

    final SectorSwitchResult? result = await provider.switchSector(sectorId);
    if (!mounted || result == null) return;

    // The switch endpoint is stateless: update the client-side sector
    // context, refresh the Dashboard for the new sector, and return
    // (FR-008: no confirmation dialog).
    context.read<AuthProvider>().updateSector(
      DefaultSector(
        id: result.currentSector.id,
        name: result.currentSector.name,
      ),
    );
    context.read<DashboardProvider>().loadSummary(
      sectorId: result.currentSector.id,
    );
    context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final AuthState auth = context.watch<AuthProvider>().state;
    final SectorsState state = context.watch<SectorsProvider>().state;
    final bool isBusinessOwner = auth.user?.isBusinessOwner ?? false;
    final int? currentSectorId = sectorIdFor(auth);

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
              title: 'Switch Business Sector',
              onBack: () => context.go('/dashboard'),
            ),
            const SizedBox(height: AppSpacing.sp2),
            Text(
              'Select the business sector you want to switch to.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.sp4),
            const SectionLabel('Business Sectors'),
            const SizedBox(height: AppSpacing.sp2),
            _SectorList(
              state: state,
              currentSectorId: currentSectorId,
              selectedSectorId: isBusinessOwner ? _selectedSectorId : null,
              selectable: isBusinessOwner,
              onSelected: isBusinessOwner
                  ? (int id) => setState(() => _selectedSectorId = id)
                  : null,
              onRetry: () => context.read<SectorsProvider>().loadSectors(),
            ),
            if (state.error != null && state.sectors.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sp2),
              AppErrorContainer(message: state.error!),
            ],
            const SizedBox(height: AppSpacing.sp1),
            Text(
              'Currently active: ${BusinessSectorsConfig.nameFor(currentSectorId)}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.inkMuted),
            ),
            if (isBusinessOwner) ...[
              const SizedBox(height: AppSpacing.sp3),
              Row(
                children: [
                  Expanded(
                    child: LoadingButton(
                      label: 'Switch Sector',
                      loading: state.isSwitching,
                      onPressed:
                          _selectedSectorId == null ||
                              _selectedSectorId == currentSectorId
                          ? null
                          : () => _switchSector(_selectedSectorId!),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sp3),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: state.isSwitching
                          ? null
                          : () => context.go('/dashboard'),
                      child: const Text('Cancel'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Business sector list with loading / error / empty / data states.
///
/// For the Business Owner each card is tappable (radio selection); for
/// the Event Manager and Employee the cards are read-only with the
/// current sector highlighted.
class _SectorList extends StatelessWidget {
  const _SectorList({
    required this.state,
    required this.currentSectorId,
    required this.selectedSectorId,
    required this.selectable,
    required this.onSelected,
    required this.onRetry,
  });

  final SectorsState state;
  final int? currentSectorId;
  final int? selectedSectorId;
  final bool selectable;
  final ValueChanged<int>? onSelected;
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

    if (state.error != null && state.sectors.isEmpty) {
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

    if (state.sectors.isEmpty) {
      return const SizedBox(
        height: 160,
        child: AppEmptyState(
          icon: Icons.storefront_outlined,
          title: 'No sectors available',
          message: 'Business sectors could not be loaded.',
        ),
      );
    }

    return Column(
      children: [
        for (final BusinessSector sector in state.sectors) ...[
          _SectorCard(
            sector: sector,
            accent: BusinessSectorsConfig.accentFor(sector.id),
            isActive: sector.id == currentSectorId,
            isSelected: sector.id == selectedSectorId,
            selectable: selectable,
            onTap: onSelected == null ? null : () => onSelected!(sector.id),
          ),
          const SizedBox(height: AppSpacing.sp2),
        ],
      ],
    );
  }
}

/// One business sector card (wireframe `.sector-card`): signature
/// icon, name + description, and an Active badge (current sector) or
/// radio dot (selection state).
class _SectorCard extends StatelessWidget {
  const _SectorCard({
    required this.sector,
    required this.accent,
    required this.isActive,
    required this.isSelected,
    required this.selectable,
    required this.onTap,
  });

  final BusinessSector sector;
  final Color accent;
  final bool isActive;
  final bool isSelected;
  final bool selectable;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool showSelection = selectable && !isActive;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.sp3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Row(
            children: [
              SectorLogo(sectorId: sector.id, size: 40),
              const SizedBox(width: AppSpacing.sp3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sector.name,
                      style: textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                    if (sector.description != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        sector.description!,
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.inkSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sp2),
              if (isActive)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sp2,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.successContainer,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Text(
                    'Active',
                    style: textTheme.labelSmall?.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              else
                Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  size: 20,
                  color: showSelection
                      ? (isSelected ? accent : AppColors.inkMuted)
                      : AppColors.inkMuted,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
