import '../entities/habit_entity.dart';

abstract class HabitRepository {
  Future<List<HabitEntity>> getHabits();

  Future<void> saveHabit(HabitEntity habit);

  Future<void> deleteHabit(String habitId);

  Future<void> saveHabits(List<HabitEntity> habits);
}
