import '../entities/pomodoro_settings_entity.dart';

abstract class PomodoroSettingsRepository {
  Future<PomodoroSettingsEntity> getSettings();

  Future<void> saveSettings(PomodoroSettingsEntity settings);
}
