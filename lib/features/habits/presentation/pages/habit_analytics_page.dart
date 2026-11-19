import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../injection_container.dart';
import '../../domain/services/habit_analytics_engine.dart';
import '../bloc/habit_bloc.dart';
import '../bloc/habit_state.dart';

class HabitAnalyticsPage extends StatelessWidget {
  const HabitAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Habit Analytics'),
        backgroundColor: AppColors.background,
      ),
      body: BlocBuilder<HabitBloc, HabitState>(
        builder: (context, state) {
          final engine = getIt<HabitAnalyticsEngine>();
          final habits = state.habits;

          final today = DateTime.now();

          final completed = engine.completedCountOn(habits, today);

          final scheduled = engine.scheduledCountOn(habits, today);

          final rate = engine.completionRate(
            completed: completed,
            scheduled: scheduled,
          );

          final weeklyHistory = engine.weeklyHistory(
            habits: habits,
            referenceDate: today,
          );

          final bestHabit = engine.bestPerformingHabit(habits);

          final totalCompletions = engine.totalCompletions(habits);

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _AnalyticsCard(
                title: "Today's Completion",
                value: '${(rate * 100).round()}%',
                subtitle: '$completed of $scheduled habits completed',
                progress: rate,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Total Completions',
                      value: '$totalCompletions',
                      icon: Icons.check_circle_outline,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'Active Habits',
                      value: '${habits.where((h) => h.isActive).length}',
                      icon: Icons.repeat,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              const Text(
                'Weekly Activity',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _WeeklyChart(history: weeklyHistory),
              const SizedBox(height: 28),
              const Text(
                'Best Performing Habit',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              if (bestHabit != null)
                _BestHabitCard(
                  title: bestHabit.title,
                  completions: bestHabit.completedDates.length,
                )
              else
                const Text(
                  'No habit data available yet.',
                  style: TextStyle(color: Colors.white54),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _AnalyticsCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final double progress;

  const _AnalyticsCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: Colors.white12,
            valueColor: AlwaysStoppedAnimation(AppColors.primary),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  final Map<String, int> history;

  const _WeeklyChart({required this.history});

  @override
  Widget build(BuildContext context) {
    final maxValue = history.values.fold<int>(
      0,
      (previous, value) => value > previous ? value : previous,
    );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: history.entries.map((entry) {
          final height = maxValue == 0 ? 0.0 : (entry.value / maxValue) * 110;

          return Expanded(
            child: Column(
              children: [
                Text(
                  '${entry.value}',
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
                const SizedBox(height: 8),
                Container(
                  height: height.clamp(4.0, 110.0),
                  width: 18,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  entry.key,
                  style: const TextStyle(color: Colors.white54, fontSize: 9),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _BestHabitCard extends StatelessWidget {
  final String title;
  final int completions;

  const _BestHabitCard({required this.title, required this.completions});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(Icons.emoji_events, color: Colors.orangeAccent, size: 32),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$completions total completions',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
