import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/achievement_entity.dart';

class AchievementUnlockDialog extends StatelessWidget {
  final AchievementEntity achievement;

  const AchievementUnlockDialog({super.key, required this.achievement});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(achievement.icon, style: const TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            'Achievement Unlocked!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            achievement.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            achievement.description,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          Text(
            '+${achievement.bonusXp} Bonus XP',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Awesome!'),
        ),
      ],
    );
  }
}
