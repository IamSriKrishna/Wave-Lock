import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakelock/features/pomodoro/presentation/pages/pomodoro_page.dart';
import 'package:wakelock/features/strict_mode/presentation/pages/strict_mode_page.dart';

import '../../../../injection_container.dart';
import '../../../../core/theme/app_colors.dart';

import '../../../daily_missions/presentation/pages/daily_missions_page.dart';
import '../../../daily_missions/presentation/widgets/daily_mission_progress_card.dart';

import '../../../gamification/presentation/bloc/gamification_bloc.dart';
import '../../../gamification/presentation/bloc/gamification_event.dart';
import '../../../gamification/presentation/bloc/gamification_state.dart';
import '../../../gamification/presentation/widgets/xp_progress_card.dart';
import '../../../gamification/presentation/widgets/streak_card.dart';
import '../../../events/presentation/pages/event_page.dart';
import '../../../gamification/presentation/pages/achievements_page.dart';
import '../../../app_usage/presentation/pages/app_usage_page.dart';
import '../../../app_usage/presentation/pages/daily_growth_page.dart';

import '../../../habits/presentation/bloc/habit_bloc.dart';
import '../../../habits/presentation/bloc/habit_event.dart';
import '../../../habits/presentation/bloc/habit_state.dart';
import '../../../habits/presentation/pages/habit_page.dart';
import '../../../habits/presentation/widgets/dashboard_habit_card.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _missionProgressRevision = 0;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<GamificationBloc>()..add(LoadGamification()),
        ),
        BlocProvider(create: (_) => getIt<HabitBloc>()..add(LoadHabits())),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Row(
            children: [
              Icon(Icons.bolt_rounded, color: AppColors.primary),
              SizedBox(width: 8),
              Text('WakeLock'),
            ],
          ),
        ),
        body: BlocBuilder<GamificationBloc, GamificationState>(
          builder: (context, state) {
            if (state.status == GamificationStatus.loading ||
                state.status == GamificationStatus.initial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == GamificationStatus.failure) {
              return Center(
                child: Text(state.errorMessage ?? 'Unable to load progress'),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Overall Progress
                  const Text(
                    'Your Progress',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 16),

                  XpProgressCard(progress: state.progress),

                  const SizedBox(height: 16),

                  StreakCard(progress: state.progress),

                  const SizedBox(height: 20),

                  // Daily Habits
                  BlocBuilder<HabitBloc, HabitState>(
                    builder: (context, habitState) {
                      return DashboardHabitCard(
                        habits: habitState.habits,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HabitPage(),
                            ),
                          );

                          if (context.mounted) {
                            context.read<HabitBloc>().add(LoadHabits());

                            context.read<GamificationBloc>().add(
                              LoadGamification(),
                            );
                          }
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // Achievements
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AchievementsPage(progress: state.progress),
                          ),
                        );
                      },
                      icon: const Icon(Icons.emoji_events_outlined),
                      label: const Text('View Achievements'),
                    ),
                  ),
                  const SizedBox(height: 28),

                  ListTile(
                    leading: const Icon(
                      Icons.bar_chart_rounded,
                      color: AppColors.primary,
                    ),
                    title: const Text(
                      'App Usage',
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: const Text(
                      'See daily screen time across your apps',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white54,
                      size: 16,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AppUsagePage()),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  ListTile(
                    leading: const Icon(
                      Icons.emoji_events_outlined,
                      color: AppColors.primary,
                    ),
                    title: const Text(
                      'Daily Growth Challenge',
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: const Text(
                      'Complete goal-based steps and earn points',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white54,
                      size: 16,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DailyGrowthPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  ListTile(
                    leading: const Icon(
                      Icons.timer_outlined,
                      color: AppColors.primary,
                    ),
                    title: const Text(
                      'Pomodoro Focus',
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: const Text(
                      'Build focus with timed sessions',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white54,
                      size: 16,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PomodoroPage()),
                      );
                    },
                  ),

                  const SizedBox(height: 12),
                  ListTile(
                    leading: const Icon(
                      Icons.lock_outline_rounded,
                      color: AppColors.primary,
                    ),
                    title: const Text(
                      'Strict Mode',
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: const Text(
                      'Block distracting apps and protect your focus',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white54,
                      size: 16,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const StrictModePage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  ListTile(
                    leading: const Icon(
                      Icons.event_available,
                      color: AppColors.primary,
                    ),
                    title: const Text(
                      'My Events',
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: const Text(
                      'Manage your schedule and reminders',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white54,
                      size: 16,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const EventPage()),
                      );
                    },
                  ),

                  const SizedBox(height: 28),

                  // Daily Missions
                  const Text(
                    'Daily Missions',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 12),

                  DailyMissionProgressCard(
                    key: ValueKey(_missionProgressRevision),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DailyMissionsPage(),
                          ),
                        );

                        if (context.mounted) {
                          setState(() {
                            _missionProgressRevision++;
                          });
                          context.read<GamificationBloc>().add(
                            LoadGamification(),
                          );
                        }
                      },
                      icon: const Icon(Icons.flag_outlined),
                      label: const Text('View Daily Missions'),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
