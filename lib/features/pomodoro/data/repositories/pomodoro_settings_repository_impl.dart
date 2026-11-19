import 'package:sembast/sembast.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_stores.dart';
import '../../domain/entities/pomodoro_settings_entity.dart';
import '../../domain/repositories/pomodoro_settings_repository.dart';
import '../models/pomodoro_settings_model.dart';

class PomodoroSettingsRepositoryImpl implements PomodoroSettingsRepository {
  final AppDatabase appDatabase;

  PomodoroSettingsRepositoryImpl(this.appDatabase);

  static const String settingsKey = 'pomodoro_settings';

  @override
  Future<PomodoroSettingsEntity> getSettings() async {
    final database = await appDatabase.database;

    final data = await DatabaseStores.pomodoro
        .record(settingsKey)
        .get(database);

    if (data == null) {
      return const PomodoroSettingsModel();
    }

    return PomodoroSettingsModel.fromMap(data);
  }

  @override
  Future<void> saveSettings(PomodoroSettingsEntity settings) async {
    final database = await appDatabase.database;

    final model = PomodoroSettingsModel.fromEntity(settings);

    await DatabaseStores.pomodoro
        .record(settingsKey)
        .put(database, model.toMap());
  }
}
