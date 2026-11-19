import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/user_progress_entity.dart';

class StreakCard extends StatelessWidget {
  final UserProgressEntity progress;

  const StreakCard({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StreakItem(
            icon: Icons.local_fire_department_rounded,
            title: 'Current Streak',
            value: '${progress.currentStreak} Days',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StreakItem(
            icon: Icons.emoji_events_rounded,
            title: 'Best Streak',
            value: '${progress.longestStreak} Days',
          ),
        ),
      ],
    );
  }
}

class _StreakItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _StreakItem({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 26),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
