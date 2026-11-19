
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../injection_container.dart';
import '../../../gamification/domain/services/achievement_engine.dart';
import '../../../gamification/presentation/widgets/achievement_unlock_dialog.dart';
import '../bloc/habit_bloc.dart';
import '../bloc/habit_event.dart';
import '../bloc/habit_state.dart';
import '../widgets/habit_card.dart';
import '../widgets/habit_progress_card.dart';
import 'create_habit_page.dart';
import 'habit_analytics_page.dart';

class HabitPage extends StatelessWidget {
  const HabitPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<HabitBloc>()..add(const LoadHabits()),
      child: const _HabitView(),
    );
  }
}

class _HabitView extends StatelessWidget {
  const _HabitView();

  Future<void> _showAchievementDialogs(
    BuildContext context,
    List<String> achievementIds,
  ) async {
    for (final id in achievementIds) {
      final matches = AchievementEngine.achievements
          .where((achievement) => achievement.id == id)
          .toList();

      if (matches.isEmpty) continue;

      if (!context.mounted) return;

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => AchievementUnlockDialog(
          achievement: matches.first,
        ),
      );
    }

    if (context.mounted) {
      context.read<HabitBloc>().add(
        const ClearNewlyUnlockedHabitAchievements(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Habits'),
        backgroundColor: AppColors.background,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<HabitBloc>(),
                    child: const HabitAnalyticsPage(),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.analytics_outlined),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.black,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<HabitBloc>(),
                child: const CreateHabitPage(),
              ),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('New Habit'),
      ),
      body: BlocListener<HabitBloc, HabitState>(
        listenWhen: (previous, current) =>
            current.newlyUnlockedAchievements.isNotEmpty &&
            previous.newlyUnlockedAchievements !=
                current.newlyUnlockedAchievements,
        listener: (context, state) {
          _showAchievementDialogs(
            context,
            state.newlyUnlockedAchievements,
          );
        },
        child: BlocBuilder<HabitBloc, HabitState>(
          builder: (context, state) {
            if (state.status == HabitStatus.loading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state.status == HabitStatus.failure &&
                state.habits.isEmpty) {
              return Center(
                child: Text(
                  state.errorMessage ?? 'Something went wrong',
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }

            final habits = state.scheduledHabits;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HabitProgressCard(
                    completed: state.completedCount,
                    total: state.totalCount,
                    progress: state.completionProgress,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Today's Routine",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (habits.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(30),
                        child: Text(
                          'No habits scheduled today.\n'
                          'Create a habit to get started!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white54),
                        ),
                      ),
                    ),
                  ...habits.map((habit) {
                    final bloc = context.read<HabitBloc>();

                    return HabitCard(
                      habit: habit,
                      currentStreak: bloc.currentStreak(habit),
                      longestStreak: bloc.longestStreak(habit),
                      isCompleted:
                          habit.isCompletedOn(state.selectedDate),
                      onToggle: () {
                        if (habit.isCompletedOn(state.selectedDate)) {
                          bloc.add(
                            UndoHabitCompletion(
                              habitId: habit.id,
                              date: state.selectedDate,
                            ),
                          );
                        } else {
                          bloc.add(
                            CompleteHabit(
                              habitId: habit.id,
                              date: state.selectedDate,
                            ),
                          );
                        }
                      },
                      onDelete: () {
                        bloc.add(DeleteHabit(habit.id));
                      },
                    );
                  }),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
