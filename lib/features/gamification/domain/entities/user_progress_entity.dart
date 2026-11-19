import 'package:equatable/equatable.dart';

class UserProgressEntity extends Equatable {
  final int totalXp;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastCompletedDate;
  final List<String> rewardedMissionIds;
  final List<String> rewardedHabitCompletionIds;
  final List<String> unlockedAchievements;

  const UserProgressEntity({
    this.totalXp = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastCompletedDate,
    this.rewardedHabitCompletionIds = const [],
    this.rewardedMissionIds = const [],
    this.unlockedAchievements = const [],
  });

  int get currentLevel => (totalXp ~/ 100) + 1;

  int get xpForNextLevel => currentLevel * 100;

  int get xpInCurrentLevel => totalXp % 100;

  double get levelProgress => xpInCurrentLevel / 100;

  UserProgressEntity copyWith({
    int? totalXp,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastCompletedDate,
    List<String>? rewardedHabitCompletionIds,
    List<String>? rewardedMissionIds,
    List<String>? unlockedAchievements,
  }) {
    return UserProgressEntity(
      totalXp: totalXp ?? this.totalXp,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastCompletedDate: lastCompletedDate ?? this.lastCompletedDate,
      rewardedHabitCompletionIds:
          rewardedHabitCompletionIds ?? this.rewardedHabitCompletionIds,
      rewardedMissionIds: rewardedMissionIds ?? this.rewardedMissionIds,
      unlockedAchievements: unlockedAchievements ?? this.unlockedAchievements,
    );
  }

  @override
  List<Object?> get props => [
    totalXp,
    currentStreak,
    longestStreak,
    rewardedHabitCompletionIds,
    lastCompletedDate,
    rewardedMissionIds,
    unlockedAchievements,
  ];
}
