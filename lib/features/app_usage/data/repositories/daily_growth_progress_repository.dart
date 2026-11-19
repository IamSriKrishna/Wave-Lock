import 'package:sembast/sembast.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_stores.dart';

class DailyGrowthProgressRepository {
  DailyGrowthProgressRepository(this._appDatabase);

  final AppDatabase _appDatabase;

  Future<Set<String>> getCompletedStepIds(String dateKey) async {
    final database = await _appDatabase.database;
    final record = await DatabaseStores.dailyGrowth
        .record(dateKey)
        .get(database);
    final ids = record?['completed_step_ids'];
    if (ids == null) return {};
    if (ids is! List) {
      throw const FormatException('Saved daily growth progress is invalid.');
    }
    if (ids.any((id) => id is! String)) {
      throw const FormatException(
        'Saved daily growth progress contains invalid step IDs.',
      );
    }
    return ids.toSet().cast<String>();
  }

  Future<void> saveCompletedStepIds(
    String dateKey,
    Set<String> completedStepIds,
  ) async {
    final database = await _appDatabase.database;
    await DatabaseStores.dailyGrowth.record(dateKey).put(database, {
      'date_key': dateKey,
      'completed_step_ids': completedStepIds.toList()..sort(),
    });
  }
}
