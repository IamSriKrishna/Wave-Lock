import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/user_progress_entity.dart';

class XpProgressCard extends StatelessWidget {
  final UserProgressEntity progress;

  const XpProgressCard({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.25),
            AppColors.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bolt_rounded, color: AppColors.primary, size: 30),
              const SizedBox(width: 8),
              Text(
                '${progress.totalXp} XP',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                'LEVEL ${progress.currentLevel}',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          LinearProgressIndicator(
            value: progress.levelProgress,
            minHeight: 9,
            borderRadius: BorderRadius.circular(20),
            backgroundColor: AppColors.textSecondary.withValues(alpha: 0.2),
            color: AppColors.primary,
          ),
          const SizedBox(height: 10),
          Text(
            '${progress.xpInCurrentLevel} / 100 XP to next level',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
