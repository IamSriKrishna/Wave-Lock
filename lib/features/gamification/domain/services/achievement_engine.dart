
import '../entities/achievement_entity.dart';
import '../entities/user_progress_entity.dart';

class AchievementEngine {
  static const List<AchievementEntity> achievements = [
    // Mission achievements
    AchievementEntity(
      id: 'first_mission',
      title: 'First Mission',
      description: 'Complete your first mission.',
      icon: '🎯',
      target: 1,
      bonusXp: 50,
      type: 'missions',
    ),
    AchievementEntity(
      id: 'ten_missions',
      title: 'Getting Serious',
      description: 'Complete 10 missions.',
      icon: '🚀',
      target: 10,
      bonusXp: 75,
      type: 'missions',
    ),

    // General streak achievements
    AchievementEntity(
      id: 'seven_day_streak',
      title: 'Consistency King',
      description: 'Maintain a 7-day streak.',
      icon: '🔥',
      target: 7,
      bonusXp: 100,
      type: 'streak',
    ),
    AchievementEntity(
      id: 'thousand_xp',
      title: 'Productivity Master',
      description: 'Earn 1,000 XP.',
      icon: '🏆',
      target: 1000,
      bonusXp: 125,
      type: 'xp',
    ),
    AchievementEntity(
      id: 'thirty_day_streak',
      title: 'Unstoppable',
      description: 'Maintain a 30-day streak.',
      icon: '👑',
      target: 30,
      bonusXp: 150,
      type: 'streak',
    ),

    // Habit achievements
    AchievementEntity(
      id: 'first_habit',
      title: 'First Step',
      description: 'Complete your first habit.',
      icon: '🌱',
      target: 1,
      bonusXp: 25,
      type: 'habits',
    ),
    AchievementEntity(
      id: 'five_habits',
      title: 'Habit Builder',
      description: 'Complete 5 habits.',
      icon: '💪',
      target: 5,
      bonusXp: 50,
      type: 'habits',
    ),
    AchievementEntity(
      id: 'twenty_five_habits',
      title: 'Consistency',
      description: 'Complete 25 habits.',
      icon: '⚡',
      target: 25,
      bonusXp: 100,
      type: 'habits',
    ),
    AchievementEntity(
      id: 'seven_day_habit_streak',
      title: 'Seven-Day Warrior',
      description: 'Maintain a 7-day habit streak.',
      icon: '🔥',
      target: 7,
      bonusXp: 150,
      type: 'habit_streak',
    ),
    AchievementEntity(
      id: 'hundred_habits',
      title: 'Habit Master',
      description: 'Complete 100 habits.',
      icon: '👑',
      target: 100,
      bonusXp: 300,
      type: 'habits',
    ),
  ];

  List<String> checkAchievements({
    required UserProgressEntity progress,
  }) {
    final unlocked = <String>[];

    // Count unique rewarded habit completions.
    final completedHabits = progress.rewardedHabitCompletionIds
        .where(
          (id) =>
              id.startsWith('habit_') &&
              !id.startsWith('habit_streak_'),
        )
        .length;

    // Check whether any habit has received its 7-day streak reward.
    final hasSevenDayHabitStreak =
        progress.rewardedHabitCompletionIds.any(
      (id) => id.startsWith('habit_streak_') && id.endsWith('_7'),
    );

    for (final achievement in achievements) {
      if (progress.unlockedAchievements.contains(achievement.id)) {
        continue;
      }

      final achieved = switch (achievement.type) {
        'missions' =>
          progress.rewardedMissionIds.length >= achievement.target,

        // Use longest streak so historical achievements remain unlocked.
        'streak' =>
          progress.longestStreak >= achievement.target,

        'xp' =>
          progress.totalXp >= achievement.target,

        'habits' =>
          completedHabits >= achievement.target,

        'habit_streak' =>
          hasSevenDayHabitStreak,

        _ => false,
      };

      if (achieved) {
        unlocked.add(achievement.id);
      }
    }

    return unlocked;
  }
}
