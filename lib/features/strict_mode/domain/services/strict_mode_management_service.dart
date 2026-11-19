import 'package:uuid/uuid.dart';

import '../entities/strict_mode_entity.dart';
import '../repositories/strict_mode_repository.dart';

class StrictModeManagementService {
  final StrictModeRepository _repository;
  final Uuid _uuid;

  StrictModeManagementService(this._repository, this._uuid);

  Future<StrictModeEntity> getOrCreateSettings() async {
    final existing = await _repository.getSettings();

    if (existing != null) return existing;

    final settings = StrictModeEntity(
      id: _uuid.v4(),
      createdAt: DateTime.now(),
    );

    await _repository.saveSettings(settings);

    return settings;
  }

  Future<StrictModeEntity> updateBlockingType(
    StrictModeEntity settings,
    StrictModeBlockingType blockingType,
  ) async {
    if (settings.isActive) {
      throw StateError(
        'Blocking settings cannot be changed during Strict Mode.',
      );
    }

    final updatedSettings = settings.copyWith(
      blockingType: blockingType,
      blockedPackageNames:
          blockingType == StrictModeBlockingType.allEligibleApps
          ? []
          : settings.blockedPackageNames,
    );

    await _repository.saveSettings(updatedSettings);

    return updatedSettings;
  }

  Future<StrictModeEntity> updateSelectedApps(
    StrictModeEntity settings,
    List<String> packageNames,
  ) async {
    if (settings.isActive) {
      throw StateError('Selected apps cannot be changed during Strict Mode.');
    }

    if (settings.blockingType != StrictModeBlockingType.selectedApps) {
      throw StateError('App selection is only available in selected-app mode.');
    }

    final uniquePackages = packageNames.toSet().toList();

    final updatedSettings = settings.copyWith(
      blockedPackageNames: uniquePackages,
    );

    await _repository.saveSettings(updatedSettings);

    return updatedSettings;
  }

  Future<StrictModeEntity> enableStrictMode(
    StrictModeEntity settings,
    String missionId,
  ) async {
    if (settings.isActive) {
      throw StateError('Strict Mode is already active.');
    }

    if (missionId.trim().isEmpty) {
      throw ArgumentError('A valid mission is required.');
    }

    final updatedSettings = settings.copyWith(
      status: StrictModeStatus.active,
      blockingType: StrictModeBlockingType.allEligibleApps,
      blockedPackageNames: const [],
      isEnabled: true,
      linkedMissionId: missionId,
      startedAt: DateTime.now(),
      clearCompletedAt: true,
    );

    await _repository.saveSettings(updatedSettings);

    return updatedSettings;
  }

  Future<StrictModeEntity> disableStrictMode(StrictModeEntity settings) async {
    if (settings.isActive) {
      throw StateError(
        'Strict Mode can only be released after completing its linked task.',
      );
    }

    final updatedSettings = settings.copyWith(
      status: StrictModeStatus.disabled,
      isEnabled: false,
      clearLinkedMissionId: true,
      clearStartedAt: true,
      clearCompletedAt: true,
    );

    await _repository.saveSettings(updatedSettings);

    return updatedSettings;
  }

  Future<StrictModeEntity> completeStrictMode(StrictModeEntity settings) async {
    if (!settings.isActive) {
      throw StateError('Strict Mode is not active.');
    }

    final updatedSettings = settings.copyWith(
      status: StrictModeStatus.completed,
      isEnabled: false,
      completedAt: DateTime.now(),
    );

    await _repository.saveSettings(updatedSettings);

    return updatedSettings;
  }
}
