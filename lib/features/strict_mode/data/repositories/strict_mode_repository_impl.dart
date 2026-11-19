
import 'package:sembast/sembast_io.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_stores.dart';

import '../../domain/entities/strict_mode_entity.dart';
import '../../domain/repositories/strict_mode_repository.dart';
import '../models/strict_mode_model.dart';

class StrictModeRepositoryImpl implements StrictModeRepository {
  final AppDatabase _appDatabase;

  StrictModeRepositoryImpl(this._appDatabase);

  static const String _settingsKey = 'strict_mode_settings';

  @override
  Future<StrictModeEntity?> getSettings() async {
    final database = await _appDatabase.database;

    final data = await DatabaseStores.strictMode
        .record(_settingsKey)
        .get(database);

    if (data == null) return null;

    return StrictModeModel.fromMap(data);
  }

  @override
  Future<void> saveSettings(StrictModeEntity settings) async {
    final database = await _appDatabase.database;

    final model = StrictModeModel.fromEntity(settings);

    await DatabaseStores.strictMode
        .record(_settingsKey)
        .put(database, model.toMap());
  }

  @override
  Future<void> deleteSettings() async {
    final database = await _appDatabase.database;

    await DatabaseStores.strictMode
        .record(_settingsKey)
        .delete(database);
  }
}
