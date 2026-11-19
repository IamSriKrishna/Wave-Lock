import 'package:equatable/equatable.dart';

abstract class HabitEvent extends Equatable {
  const HabitEvent();

  @override
  List<Object?> get props => [];
}

class LoadHabits extends HabitEvent {
  const LoadHabits();
}

class CreateHabit extends HabitEvent {
  final String title;
  final String description;
  final String category;
  final int? scheduledTimeMinutes;
  final List<int> scheduledWeekdays;

  const CreateHabit({
    required this.title,
    required this.description,
    required this.category,
    required this.scheduledWeekdays,
    this.scheduledTimeMinutes,
  });

  @override
  List<Object?> get props => [
    title,
    description,
    category,
    scheduledWeekdays,
    scheduledTimeMinutes,
  ];
}

class ClearNewlyUnlockedHabitAchievements extends HabitEvent {
  const ClearNewlyUnlockedHabitAchievements();
}

class DeleteHabit extends HabitEvent {
  final String habitId;

  const DeleteHabit(this.habitId);

  @override
  List<Object?> get props => [habitId];
}

class CompleteHabit extends HabitEvent {
  final String habitId;
  final DateTime date;

  const CompleteHabit({required this.habitId, required this.date});

  @override
  List<Object?> get props => [habitId, date];
}

class UndoHabitCompletion extends HabitEvent {
  final String habitId;
  final DateTime date;

  const UndoHabitCompletion({required this.habitId, required this.date});

  @override
  List<Object?> get props => [habitId, date];
}

class RefreshHabitStreaks extends HabitEvent {
  const RefreshHabitStreaks();
}
