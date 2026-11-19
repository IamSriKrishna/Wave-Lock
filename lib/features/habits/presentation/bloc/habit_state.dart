
import 'package:equatable/equatable.dart';

import '../../domain/entities/habit_entity.dart';

enum HabitStatus { initial, loading, loaded, saving, failure }

class HabitState extends Equatable {
  final HabitStatus status;
  final List<HabitEntity> habits;
  final String? errorMessage;
  final DateTime selectedDate;

  final List<String>? _newlyUnlockedAchievements;
  List<String> get newlyUnlockedAchievements =>
      _newlyUnlockedAchievements ?? const [];

  const HabitState({
    this.status = HabitStatus.initial,
    this.habits = const [],
    this.errorMessage,
    required this.selectedDate,
    List<String> this._newlyUnlockedAchievements = const [],
  });

  List<HabitEntity> get scheduledHabits {
    return habits
        .where((habit) => habit.isActive && habit.isScheduledOn(selectedDate))
        .toList();
  }

  int get completedCount {
    return scheduledHabits
        .where((habit) => habit.isCompletedOn(selectedDate))
        .length;
  }

  int get totalCount => scheduledHabits.length;

  double get completionProgress {
    if (totalCount == 0) return 0;
    return completedCount / totalCount;
  }

  HabitState copyWith({
    HabitStatus? status,
    List<HabitEntity>? habits,
    String? errorMessage,
    DateTime? selectedDate,
    List<String>? newlyUnlockedAchievements,
    bool clearError = false,
    bool clearNewlyUnlockedAchievements = false,
  }) {
    return HabitState(
      status: status ?? this.status,
      habits: habits ?? this.habits,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      selectedDate: selectedDate ?? this.selectedDate,
      newlyUnlockedAchievements: clearNewlyUnlockedAchievements
          ? const []
          : newlyUnlockedAchievements ?? this.newlyUnlockedAchievements,
    );
  }

  @override
  List<Object?> get props => [
        status,
        habits,
        errorMessage,
        selectedDate,
        newlyUnlockedAchievements,
      ];
}
