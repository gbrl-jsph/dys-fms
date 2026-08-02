import '../data/models/business_sector.dart';

/// Immutable business sector state managed by [SectorsProvider].
///
/// Updated via [copyWith] so every published state is consistent.
class SectorsState {
  const SectorsState({
    this.isLoading = false,
    this.isSwitching = false,
    this.sectors = const [],
    this.error,
  });

  /// Tracks the sector list fetch in progress.
  final bool isLoading;

  /// Tracks the switch submission in progress.
  final bool isSwitching;

  /// Business sectors from GET /business-sectors.
  final List<BusinessSector> sectors;

  /// Error message to display.
  final String? error;

  /// Sentinel distinguishing "not provided" from an explicit null in
  /// [copyWith], so nullable fields can be cleared by passing null.
  static const Object _unset = Object();

  SectorsState copyWith({
    bool? isLoading,
    bool? isSwitching,
    List<BusinessSector>? sectors,
    Object? error = _unset,
  }) {
    return SectorsState(
      isLoading: isLoading ?? this.isLoading,
      isSwitching: isSwitching ?? this.isSwitching,
      sectors: sectors ?? this.sectors,
      error: identical(error, _unset) ? this.error : error as String?,
    );
  }
}
