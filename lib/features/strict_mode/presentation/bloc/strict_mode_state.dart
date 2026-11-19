import 'package:equatable/equatable.dart';

import '../../domain/entities/strict_mode_entity.dart';
import '../../domain/entities/installed_app_entity.dart';

enum StrictModeLoadStatus { initial, loading, loaded, saving, failure }

class StrictModeState extends Equatable {
  final StrictModeLoadStatus status;
  final StrictModeEntity? settings;
  final List<InstalledAppEntity> installedApps;
  final String? errorMessage;

  const StrictModeState({
    this.status = StrictModeLoadStatus.initial,
    this.settings,
    this.installedApps = const [],
    this.errorMessage,
  });

  bool get isActive => settings?.isActive ?? false;

  bool get isEnabled => settings?.isEnabled ?? false;

  List<String> get selectedPackages => settings?.blockedPackageNames ?? [];

  int get selectedAppCount => selectedPackages.length;

  bool get isLoading => status == StrictModeLoadStatus.loading;

  StrictModeState copyWith({
    StrictModeLoadStatus? status,
    StrictModeEntity? settings,
    List<InstalledAppEntity>? installedApps,
    String? errorMessage,
    bool clearSettings = false,
    bool clearError = false,
  }) {
    return StrictModeState(
      status: status ?? this.status,
      settings: clearSettings ? null : settings ?? this.settings,
      installedApps: installedApps ?? this.installedApps,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, settings, installedApps, errorMessage];
}
