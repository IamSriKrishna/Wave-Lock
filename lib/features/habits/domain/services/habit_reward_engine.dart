
import '../entities/habit_entity.dart';
import '../../../gamification/domain/entities/user_progress_entity.dart';

class HabitRewardResult {
  final UserProgressEntity progress;
  final int xpAwarded;
  final bool completedAllHabits;
  final bool achievedSevenDayStreak;

  const HabitRewardResult({
    required this.progress,
    required this.xpAwarded,
    required this.completedAllHabits,
    required this.achievedSevenDayStreak,
  });
}

class HabitRewardEngine {
  static const int habitCompletionXp = 10;
  static const int allHabitsBonusXp = 25;
  static const int sevenDayStreakBonusXp = 50;

  HabitRewardResult rewardHabit({
    required HabitEntity habit,
    required List<HabitEntity> allHabits,
    required UserProgressEntity progress,
    required int currentHabitStreak,
    DateTime? referenceDate,
  }) {
    final now = referenceDate ?? DateTime.now();
    final dateKey = habit.dateKey(now);

    final rewardId = 'habit_${habit.id}_$dateKey';

    // Prevent duplicate rewards for the same habit and date.
    if (progress.rewardedHabitCompletionIds.contains(rewardId)) {
      return HabitRewardResult(
        progress: progress,
        xpAwarded: 0,
        completedAllHabits: false,
        achievedSevenDayStreak: false,
      );
    }

    final scheduledHabits = allHabits.where((item) {
      return item.isActive && item.isScheduledOn(now);
    }).toList();

    final completedAllHabits = scheduledHabits.isNotEmpty &&
        scheduledHabits.every((item) {
          if (item.id == habit.id) return true;
          return item.isCompletedOn(now);
        });

    final alreadyReceivedDailyBonus =
        progress.rewardedHabitCompletionIds.contains(
      'all_habits_$dateKey',
    );

    final awardAllHabitsBonus =
        completedAllHabits && !alreadyReceivedDailyBonus;

    final achievedSevenDayStreak = currentHabitStreak >= 7;

    final streakRewardId = 'habit_streak_${habit.id}_7';

    final alreadyReceivedStreakBonus =
        progress.rewardedHabitCompletionIds.contains(streakRewardId);

    final awardStreakBonus =
        achievedSevenDayStreak && !alreadyReceivedStreakBonus;

    var xpAwarded = habitCompletionXp;

    if (awardAllHabitsBonus) {
      xpAwarded += allHabitsBonusXp;
    }

    if (awardStreakBonus) {
      xpAwarded += sevenDayStreakBonusXp;
    }

    final rewardIds = [
      ...progress.rewardedHabitCompletionIds,
      rewardId,
      if (awardAllHabitsBonus) 'all_habits_$dateKey',
      if (awardStreakBonus) streakRewardId,
    ];

    final updatedProgress = progress.copyWith(
      totalXp: progress.totalXp + xpAwarded,
      rewardedHabitCompletionIds: rewardIds,
    );

    return HabitRewardResult(
      progress: updatedProgress,
      xpAwarded: xpAwarded,
      completedAllHabits: awardAllHabitsBonus,
      achievedSevenDayStreak: awardStreakBonus,
    );
  }
}
