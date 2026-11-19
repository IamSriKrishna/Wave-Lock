import 'package:sembast/sembast.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_stores.dart';
import '../../domain/entities/habit_entity.dart';
import '../../domain/repositories/habit_repository.dart';
import '../models/habit_model.dart';

class HabitRepositoryImpl implements HabitRepository {
  final AppDatabase appDatabase;

  HabitRepositoryImpl(this.appDatabase);

  @override
  Future<List<HabitEntity>> getHabits() async {
    final database = await appDatabase.database;

    final records = await DatabaseStores.habits.find(database);

    return records.map((record) => HabitModel.fromMap(record.value)).toList();
  }

  @override
  Future<void> saveHabit(HabitEntity habit) async {
    final database = await appDatabase.database;

    await DatabaseStores.habits
        .record(habit.id)
        .put(database, HabitModel.fromEntity(habit).toMap());
  }

  @override
  Future<void> deleteHabit(String habitId) async {
    final database = await appDatabase.database;

    await DatabaseStores.habits.record(habitId).delete(database);
  }

  @override
  Future<void> saveHabits(List<HabitEntity> habits) async {
    final database = await appDatabase.database;

    final records = DatabaseStores.habits;

    await database.transaction((transaction) async {
      await records.delete(transaction);

      for (final habit in habits) {
        await records
            .record(habit.id)
            .put(transaction, HabitModel.fromEntity(habit).toMap());
      }
    });
  }
}
