import '../entities/strict_mode_entity.dart';

abstract class StrictModeRepository {
  Future<StrictModeEntity?> getSettings();

  Future<void> saveSettings(StrictModeEntity settings);

  Future<void> deleteSettings();
}
