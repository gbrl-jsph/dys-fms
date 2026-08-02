import 'package:dys_fms/core/constants/business_sectors.dart';
import 'package:dys_fms/features/auth/domain/auth_state.dart';

/// Resolves the current sector context for the authenticated user:
/// the login default sector, else the user's assigned sector, else the
/// Owner's default (DYS Events).
int? sectorIdFor(AuthState auth) {
  if (auth.defaultSector?.id != null) return auth.defaultSector!.id;
  if (auth.user?.sectorId != null) return auth.user!.sectorId;
  if (auth.user?.isBusinessOwner ?? false) {
    return BusinessSectorsConfig.sectors.first.id;
  }
  return null;
}
