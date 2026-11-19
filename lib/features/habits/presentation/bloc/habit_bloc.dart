import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/habit_entity.dart';
import '../../domain/repositories/habit_repository.dart';
import '../../domain/services/habit_management_service.dart';
import '../../domain/services/habit_streak_engine.dart';
import '../../domain/services/habit_reward_engine.dart';
import '../../../gamification/domain/services/achievement_engine.dart';

import '../../../gamification/domain/repositories/progress_repository.dart';

import 'habit_event.dart';
import 'habit_state.dart';

class HabitBloc extends Bloc<HabitEvent, HabitState> {
  final HabitRepository habitRepository;
  final HabitManagementService managementService;
  final HabitStreakEngine streakEngine;
  final HabitRewardEngine rewardEngine;
  final AchievementEngine achievementEngine;
  final ProgressRepository progressRepository;

  HabitBloc({
    required this.habitRepository,
    required this.managementService,
    required this.achievementEngine,
    required this.streakEngine,
    required this.rewardEngine,
    required this.progressRepository,
  }) : super(HabitState(selectedDate: DateTime.now())) {
    on<LoadHabits>(_onLoadHabits);
    on<CreateHabit>(_onCreateHabit);
    on<DeleteHabit>(_onDeleteHabit);
    on<CompleteHabit>(_onCompleteHabit);
    on<UndoHabitCompletion>(_onUndoHabitCompletion);
    on<RefreshHabitStreaks>(_onRefreshHabitStreaks);
    on<ClearNewlyUnlockedHabitAchievements>((event, emit) {
      emit(state.copyWith(clearNewlyUnlockedAchievements: true));
    });
  }

  Future<void> _onLoadHabits(LoadHabits event, Emitter<HabitState> emit) async {
    emit(state.copyWith(status: HabitStatus.loading, clearError: true));

    try {
      final habits = await habitRepository.getHabits();

      emit(state.copyWith(status: HabitStatus.loaded, habits: habits));
    } catch (error) {
      emit(
        state.copyWith(
          status: HabitStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onCreateHabit(
    CreateHabit event,
    Emitter<HabitState> emit,
  ) async {
    try {
      final habit = managementService.createHabit(
        title: event.title,
        description: event.description,
        category: event.category,
        scheduledWeekdays: event.scheduledWeekdays,
        scheduledTimeMinutes: event.scheduledTimeMinutes,
      );

      final updatedHabits = [...state.habits, habit];

      await habitRepository.saveHabit(habit);

      emit(
        state.copyWith(
          status: HabitStatus.loaded,
          habits: updatedHabits,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: HabitStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onDeleteHabit(
    DeleteHabit event,
    Emitter<HabitState> emit,
  ) async {
    try {
      await habitRepository.deleteHabit(event.habitId);

      final updatedHabits = state.habits
          .where((habit) => habit.id != event.habitId)
          .toList();

      emit(
        state.copyWith(
          status: HabitStatus.loaded,
          habits: updatedHabits,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: HabitStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onCompleteHabit(
    CompleteHabit event,
    Emitter<HabitState> emit,
  ) async {
    try {
      final index = state.habits.indexWhere(
        (habit) => habit.id == event.habitId,
      );

      if (index == -1) {
        throw StateError('Habit not found.');
      }

      final habit = state.habits[index];

      final updatedHabit = managementService.markCompleted(habit, event.date);

      final updatedHabits = [...state.habits];
      updatedHabits[index] = updatedHabit;

      await habitRepository.saveHabit(updatedHabit);

      final habitStreak = streakEngine.calculateCurrentStreak(
        updatedHabit,
        referenceDate: event.date,
      );

      final progress = await progressRepository.getProgress();

      final rewardResult = rewardEngine.rewardHabit(
        habit: updatedHabit,
        allHabits: updatedHabits,
        progress: progress,
        currentHabitStreak: habitStreak,
        referenceDate: event.date,
      );

      final newlyUnlocked = achievementEngine.checkAchievements(
        progress: rewardResult.progress,
      );

      final achievementBonusXp = newlyUnlocked.fold<int>(0, (
        total,
        achievementId,
      ) {
        final achievement = AchievementEngine.achievements.firstWhere(
          (item) => item.id == achievementId,
        );

        return total + achievement.bonusXp;
      });

      final finalProgress = rewardResult.progress.copyWith(
        totalXp: rewardResult.progress.totalXp + achievementBonusXp,
        unlockedAchievements: [
          ...rewardResult.progress.unlockedAchievements,
          ...newlyUnlocked,
        ],
      );

      await progressRepository.saveProgress(finalProgress);

      emit(
        state.copyWith(
          status: HabitStatus.loaded,
          habits: updatedHabits,
          newlyUnlockedAchievements: newlyUnlocked,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: HabitStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onUndoHabitCompletion(
    UndoHabitCompletion event,
    Emitter<HabitState> emit,
  ) async {
    await _updateHabit(
      event.habitId,
      emit,
      (habit) => managementService.undoCompletion(habit, event.date),
    );
  }

  Future<void> _updateHabit(
    String habitId,
    Emitter<HabitState> emit,
    HabitEntity Function(HabitEntity habit) update,
  ) async {
    try {
      final index = state.habits.indexWhere((habit) => habit.id == habitId);

      if (index == -1) {
        throw StateError('Habit not found.');
      }

      final updatedHabit = update(state.habits[index]);

      await habitRepository.saveHabit(updatedHabit);

      final updatedHabits = [...state.habits];
      updatedHabits[index] = updatedHabit;

      emit(
        state.copyWith(
          status: HabitStatus.loaded,
          habits: updatedHabits,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: HabitStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  void _onRefreshHabitStreaks(
    RefreshHabitStreaks event,
    Emitter<HabitState> emit,
  ) {
    emit(state.copyWith(selectedDate: DateTime.now()));
  }

  int currentStreak(HabitEntity habit) {
    return streakEngine.calculateCurrentStreak(
      habit,
      referenceDate: state.selectedDate,
    );
  }

  int longestStreak(HabitEntity habit) {
    return streakEngine.calculateLongestStreak(habit);
  }
}
