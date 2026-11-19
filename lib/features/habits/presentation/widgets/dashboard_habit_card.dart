import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/habit_entity.dart';

class DashboardHabitCard extends StatelessWidget {
  final List<HabitEntity> habits;
  final VoidCallback onTap;

  const DashboardHabitCard({
    super.key,
    required this.habits,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();

    final scheduledHabits = habits
        .where((habit) => habit.isActive && habit.isScheduledOn(today))
        .toList();

    final completedCount = scheduledHabits
        .where((habit) => habit.isCompletedOn(today))
        .length;

    final totalCount = scheduledHabits.length;

    final progress = totalCount == 0 ? 0.0 : completedCount / totalCount;

    return Card(
      color: AppColors.surface,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.track_changes, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Daily Habits',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    '$completedCount/$totalCount',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                borderRadius: BorderRadius.circular(10),
                backgroundColor: AppColors.background,
                color: AppColors.primary,
              ),
              const SizedBox(height: 12),
              Text(
                totalCount == 0
                    ? 'Create your first habit and build consistency.'
                    : '$completedCount of $totalCount habits completed today',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'View Habits',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 5),
                  Icon(Icons.arrow_forward, size: 16, color: AppColors.primary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
