import '../entities/user_progress_entity.dart';

class ProgressRewardEngine {
  int calculateXp(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return 10;
      case 'medium':
        return 20;
      case 'hard':
        return 30;
      default:
        return 10;
    }
  }

  UserProgressEntity rewardMission({
    required UserProgressEntity progress,
    required String missionId,
    required String difficulty,
    DateTime? completedAt,
  }) {
    // Prevent duplicate rewards.
    if (progress.rewardedMissionIds.contains(missionId)) {
      return progress;
    }

    final now = completedAt ?? DateTime.now();

    final today = DateTime(now.year, now.month, now.day);

    final lastDate = progress.lastCompletedDate == null
        ? null
        : DateTime(
            progress.lastCompletedDate!.year,
            progress.lastCompletedDate!.month,
            progress.lastCompletedDate!.day,
          );

    int streak = progress.currentStreak;

    if (lastDate == null) {
      streak = 1;
    } else {
      final difference = today.difference(lastDate).inDays;

      if (difference == 1) {
        streak++;
      } else if (difference > 1) {
        streak = 1;
      }
      // Same day: don't increase the streak.
      // Earlier dates: don't roll progress backwards.
    }

    final xp = calculateXp(difficulty);

    final newTotalXp = progress.totalXp + xp;

    final newLongestStreak = streak > progress.longestStreak
        ? streak
        : progress.longestStreak;

    final rewardedIds = [...progress.rewardedMissionIds, missionId];

    return progress.copyWith(
      totalXp: newTotalXp,
      currentStreak: streak,
      longestStreak: newLongestStreak,
      lastCompletedDate: lastDate != null && today.isBefore(lastDate)
          ? progress.lastCompletedDate
          : today,
      rewardedMissionIds: rewardedIds,
    );
  }
}
