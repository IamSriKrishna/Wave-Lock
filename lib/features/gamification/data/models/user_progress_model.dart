import '../../domain/entities/user_progress_entity.dart';

class UserProgressModel extends UserProgressEntity {
  const UserProgressModel({
    super.totalXp,
    super.currentStreak,
    super.longestStreak,
    super.lastCompletedDate,
    super.rewardedMissionIds,
    super.unlockedAchievements,
    super.rewardedHabitCompletionIds,
  });

  factory UserProgressModel.fromMap(Map<String, dynamic> map) {
    return UserProgressModel(
      totalXp: map['total_xp'] ?? 0,
      currentStreak: map['current_streak'] ?? 0,
      longestStreak: map['longest_streak'] ?? 0,
      rewardedHabitCompletionIds: List<String>.from(
        map['rewarded_habit_completion_ids'] ?? [],
      ),
      lastCompletedDate: map['last_completed_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['last_completed_date'])
          : null,
      rewardedMissionIds: List<String>.from(map['rewarded_mission_ids'] ?? []),
      unlockedAchievements: List<String>.from(
        map['unlocked_achievements'] ?? [],
      ),
    );
  }

  factory UserProgressModel.fromEntity(UserProgressEntity entity) {
    return UserProgressModel(
      totalXp: entity.totalXp,
      currentStreak: entity.currentStreak,
      longestStreak: entity.longestStreak,
      lastCompletedDate: entity.lastCompletedDate,
      rewardedHabitCompletionIds: entity.rewardedHabitCompletionIds,
      rewardedMissionIds: entity.rewardedMissionIds,
      unlockedAchievements: entity.unlockedAchievements,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'total_xp': totalXp,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'last_completed_date': lastCompletedDate?.millisecondsSinceEpoch,
      'rewarded_mission_ids': rewardedMissionIds,
      'unlocked_achievements': unlockedAchievements,
      'rewarded_habit_completion_ids': rewardedHabitCompletionIds,
    };
  }
}
