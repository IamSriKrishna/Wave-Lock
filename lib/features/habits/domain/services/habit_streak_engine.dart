import '../entities/habit_entity.dart';

class HabitStreakEngine {
  int calculateCurrentStreak(HabitEntity habit, {DateTime? referenceDate}) {
    final today = _dateOnly(referenceDate ?? DateTime.now());

    if (!habit.isActive) return 0;

    var currentDate = today;

    if (!habit.isCompletedOn(currentDate)) {
      currentDate = currentDate.subtract(const Duration(days: 1));
    }

    var streak = 0;

    while (habit.isScheduledOn(currentDate) &&
        habit.isCompletedOn(currentDate)) {
      streak++;

      currentDate = currentDate.subtract(const Duration(days: 1));
    }

    return streak;
  }

  int calculateLongestStreak(HabitEntity habit) {
    final completedDates =
        habit.completedDates.map(DateTime.parse).map(_dateOnly).toSet().toList()
          ..sort();

    if (completedDates.isEmpty) return 0;

    var longestStreak = 0;
    var currentStreak = 0;

    DateTime? previousDate;

    for (final date in completedDates) {
      if (!habit.isScheduledOn(date)) continue;

      if (previousDate == null) {
        currentStreak = 1;
      } else {
        final expectedNextDate = _nextScheduledDate(habit, previousDate);

        if (expectedNextDate == date) {
          currentStreak++;
        } else {
          currentStreak = 1;
        }
      }

      if (currentStreak > longestStreak) {
        longestStreak = currentStreak;
      }

      previousDate = date;
    }

    return longestStreak;
  }

  DateTime? _nextScheduledDate(HabitEntity habit, DateTime date) {
    var nextDate = date.add(const Duration(days: 1));

    if (habit.scheduledWeekdays.isEmpty) {
      return nextDate;
    }

    for (var i = 0; i < 7; i++) {
      if (habit.isScheduledOn(nextDate)) {
        return nextDate;
      }

      nextDate = nextDate.add(const Duration(days: 1));
    }

    return null;
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
