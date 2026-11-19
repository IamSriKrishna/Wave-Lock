import '../entities/habit_entity.dart';

class HabitAnalyticsEngine {
  int completedCountOn(List<HabitEntity> habits, DateTime date) {
    return habits.where((habit) {
      return habit.isActive &&
          habit.isScheduledOn(date) &&
          habit.isCompletedOn(date);
    }).length;
  }

  int scheduledCountOn(List<HabitEntity> habits, DateTime date) {
    return habits.where((habit) {
      return habit.isActive && habit.isScheduledOn(date);
    }).length;
  }

  double completionRate({required int completed, required int scheduled}) {
    if (scheduled == 0) return 0;

    return completed / scheduled;
  }

  int totalCompletions(List<HabitEntity> habits) {
    return habits.fold<int>(
      0,
      (total, habit) => total + habit.completedDates.length,
    );
  }

  Map<String, int> weeklyHistory({
    required List<HabitEntity> habits,
    required DateTime referenceDate,
  }) {
    final today = DateTime(
      referenceDate.year,
      referenceDate.month,
      referenceDate.day,
    );

    final monday = today.subtract(Duration(days: today.weekday - 1));

    final history = <String, int>{};

    for (var i = 0; i < 7; i++) {
      final date = monday.add(Duration(days: i));

      final key =
          '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}';

      history[key] = completedCountOn(habits, date);
    }

    return history;
  }

  HabitEntity? bestPerformingHabit(List<HabitEntity> habits) {
    if (habits.isEmpty) return null;

    final activeHabits = habits.where((habit) => habit.isActive).toList();

    if (activeHabits.isEmpty) return null;

    activeHabits.sort(
      (a, b) => b.completedDates.length.compareTo(a.completedDates.length),
    );

    return activeHabits.first;
  }
}
