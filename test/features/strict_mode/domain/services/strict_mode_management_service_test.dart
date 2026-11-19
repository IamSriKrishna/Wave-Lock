import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';
import 'package:wakelock/features/strict_mode/domain/entities/strict_mode_entity.dart';
import 'package:wakelock/features/strict_mode/domain/repositories/strict_mode_repository.dart';
import 'package:wakelock/features/strict_mode/domain/services/strict_mode_management_service.dart';

void main() {
  test('mission-linked strict mode needs no app selection', () async {
    final service = StrictModeManagementService(
      _InMemoryStrictModeRepository(),
      const Uuid(),
    );
    final settings = StrictModeEntity(
      id: 'settings',
      blockingType: StrictModeBlockingType.selectedApps,
      createdAt: DateTime(2026),
    );

    final enabled = await service.enableStrictMode(settings, 'mission-1');

    expect(enabled.isActive, isTrue);
    expect(enabled.blockingType, StrictModeBlockingType.allEligibleApps);
    expect(enabled.blockedPackageNames, isEmpty);
  });
  test(
    'mission-linked strict mode ignores selected-app configuration',
    () async {
      final repository = _InMemoryStrictModeRepository();
      final service = StrictModeManagementService(repository, const Uuid());
      final settings = StrictModeEntity(
        id: 'settings',
        blockingType: StrictModeBlockingType.selectedApps,
        blockedPackageNames: const ['com.example.distraction'],
        createdAt: DateTime(2026),
      );

      final enabled = await service.enableStrictMode(settings, 'mission-1');

      expect(enabled.isActive, isTrue);
      expect(enabled.linkedMissionId, 'mission-1');
      expect(enabled.blockingType, StrictModeBlockingType.allEligibleApps);
      expect(enabled.blockedPackageNames, isEmpty);
      expect(repository.savedSettings, same(enabled));
    },
  );
}

class _InMemoryStrictModeRepository implements StrictModeRepository {
  StrictModeEntity? savedSettings;

  @override
  Future<StrictModeEntity?> getSettings() async => savedSettings;

  @override
  Future<void> saveSettings(StrictModeEntity settings) async {
    savedSettings = settings;
  }

  @override
  Future<void> deleteSettings() async {
    savedSettings = null;
  }
}
