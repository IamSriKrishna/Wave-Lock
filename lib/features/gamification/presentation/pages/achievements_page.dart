
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/user_progress_entity.dart';
import '../../domain/services/achievement_engine.dart';

class AchievementsPage extends StatelessWidget {
  final UserProgressEntity progress;

  const AchievementsPage({
    super.key,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final achievements = AchievementEngine.achievements;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: achievements.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final achievement = achievements[index];

          final unlocked = progress.unlockedAchievements
              .contains(achievement.id);

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: unlocked
                    ? AppColors.primary
                    : AppColors.textSecondary.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Text(
                  achievement.icon,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        achievement.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        achievement.description,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  unlocked
                      ? Icons.check_circle
                      : Icons.lock_outline,
                  color: unlocked
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
