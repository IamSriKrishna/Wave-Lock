import 'package:uuid/uuid.dart';

import '../entities/habit_entity.dart';

class HabitManagementService {
  final Uuid _uuid = const Uuid();

  HabitEntity createHabit({
    required String title,
    required String description,
    int? scheduledTimeMinutes,
    required String category,
    required List<int> scheduledWeekdays,
  }) {
    if (title.trim().isEmpty) {
      throw ArgumentError('Habit title cannot be empty.');
    }

    if (scheduledWeekdays.any((day) => day < 1 || day > 7)) {
      throw ArgumentError('Weekdays must be between 1 and 7.');
    }

    return HabitEntity(
      id: _uuid.v4(),
      title: title.trim(),
      description: description.trim(),
      category: category,
      scheduledWeekdays: scheduledWeekdays.toSet().toList()..sort(),
      createdAt: DateTime.now(),
      scheduledTimeMinutes: scheduledTimeMinutes,
    );
  }

  HabitEntity markCompleted(HabitEntity habit, DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);

    if (!habit.isScheduledOn(normalizedDate)) {
      throw StateError('This habit is not scheduled for this day.');
    }

    final dateKey = _dateKey(normalizedDate);

    if (habit.completedDates.contains(dateKey)) {
      return habit;
    }

    return habit.copyWith(
      completedDates: [...habit.completedDates, dateKey]..sort(),
    );
  }

  HabitEntity undoCompletion(HabitEntity habit, DateTime date) {
    final dateKey = _dateKey(date);

    return habit.copyWith(
      completedDates: habit.completedDates
          .where((completedDate) => completedDate != dateKey)
          .toList(),
    );
  }

  String _dateKey(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }
}
