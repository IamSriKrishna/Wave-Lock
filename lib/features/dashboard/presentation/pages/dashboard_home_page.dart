import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../injection_container.dart';
import '../../../app_usage/presentation/pages/app_usage_page.dart';
import '../../../app_usage/presentation/pages/daily_growth_page.dart';
import '../../../daily_missions/presentation/widgets/daily_mission_progress_card.dart';
import '../../../events/presentation/pages/event_page.dart';
import '../../../gamification/presentation/bloc/gamification_bloc.dart';
import '../../../gamification/presentation/bloc/gamification_event.dart';
import '../../../gamification/presentation/bloc/gamification_state.dart';
import '../../../gamification/domain/entities/user_progress_entity.dart';
import '../../../gamification/presentation/pages/achievements_page.dart';
import '../../../gamification/presentation/widgets/streak_card.dart';
import '../../../gamification/presentation/widgets/xp_progress_card.dart';
import '../../../habits/presentation/bloc/habit_bloc.dart';
import '../../../habits/presentation/bloc/habit_event.dart';
import '../../../habits/presentation/bloc/habit_state.dart';
import '../../../habits/presentation/pages/habit_page.dart';
import '../../../habits/presentation/widgets/dashboard_habit_card.dart';
import '../../../pomodoro/presentation/pages/pomodoro_page.dart';
import '../../../strict_mode/presentation/pages/strict_mode_page.dart';

class DashboardHomePage extends StatelessWidget {
  const DashboardHomePage({
    required this.onOpenMissions,
    required this.onOpenFeature,
    super.key,
  });

  final VoidCallback onOpenMissions;
  final ValueChanged<Widget> onOpenFeature;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<GamificationBloc>()..add(LoadGamification()),
        ),
        BlocProvider(
          create: (_) => getIt<HabitBloc>()..add(const LoadHabits()),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 20,
          title: const Row(
            children: [
              _BrandMark(),
              SizedBox(width: 10),
              Text(
                'WakeLock',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.surfaceLight,
                child: Icon(
                  Icons.person_rounded,
                  size: 19,
                  color: AppColors.secondary,
                ),
              ),
            ),
          ],
        ),
        body: BlocBuilder<GamificationBloc, GamificationState>(
          builder: (context, state) {
            if (state.status == GamificationStatus.loading ||
                state.status == GamificationStatus.initial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == GamificationStatus.failure) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        state.errorMessage ?? 'Unable to load your progress',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () => context.read<GamificationBloc>().add(
                          LoadGamification(),
                        ),
                        child: const Text('Try again'),
                      ),
                    ],
                  ),
                ),
              );
            }

            return _HomeContent(
              progress: state.progress,
              onOpenMissions: onOpenMissions,
              onOpenFeature: onOpenFeature,
            );
          },
        ),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({
    required this.progress,
    required this.onOpenMissions,
    required this.onOpenFeature,
  });

  final UserProgressEntity progress;
  final VoidCallback onOpenMissions;
  final ValueChanged<Widget> onOpenFeature;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final greeting = switch (now.hour) {
      < 12 => 'Good morning',
      < 17 => 'Good afternoon',
      _ => 'Good evening',
    };

    return RefreshIndicator(
      onRefresh: () async {
        context.read<GamificationBloc>().add(LoadGamification());
        context.read<HabitBloc>().add(const LoadHabits());
        await Future<void>.delayed(const Duration(milliseconds: 350));
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  DateFormat('EEEE, MMMM d').format(now),
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '$greeting. Ready to grow?',
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 20),
                XpProgressCard(progress: progress),
                const SizedBox(height: 12),
                StreakCard(progress: progress),
                const SizedBox(height: 22),
                _SectionHeader(
                  title: "Today's mission",
                  action: 'View all',
                  onTap: onOpenMissions,
                ),
                const SizedBox(height: 10),
                DailyMissionProgressCard(
                  key: const ValueKey('today-mission-progress'),
                ),
                _MissionLaunchCard(onTap: onOpenMissions),
                const SizedBox(height: 22),
                _SectionHeader(title: 'Your daily rhythm'),
                const SizedBox(height: 10),
                BlocBuilder<HabitBloc, HabitState>(
                  builder: (context, habitState) {
                    return DashboardHabitCard(
                      habits: habitState.habits,
                      onTap: () => onOpenFeature(const HabitPage()),
                    );
                  },
                ),
                const SizedBox(height: 24),
                const _SectionHeader(title: 'Your toolkit'),
                const SizedBox(height: 12),
                _QuickActions(onOpenFeature: onOpenFeature, progress: progress),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _MissionLaunchCard extends StatelessWidget {
  const _MissionLaunchCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B2A1D), Color(0xFF222027)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  Icons.rocket_launch_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Make today count',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Pick up where you left off',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_rounded, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.onOpenFeature, required this.progress});

  final ValueChanged<Widget> onOpenFeature;
  final UserProgressEntity progress;

  @override
  Widget build(BuildContext context) {
    final actions = [
      _ActionData(
        'App usage',
        'Understand your screen time',
        Icons.insights_rounded,
        const Color(0xFF63B8A8),
        const AppUsagePage(),
      ),
      _ActionData(
        'Daily growth',
        'Take goal-based steps',
        Icons.auto_awesome_rounded,
        AppColors.primary,
        const DailyGrowthPage(),
      ),
      _ActionData(
        'Focus timer',
        'Work in calm sprints',
        Icons.timer_rounded,
        const Color(0xFF9B8AFB),
        const PomodoroPage(),
      ),
      _ActionData(
        'Strict mode',
        'Protect your focus',
        Icons.shield_rounded,
        const Color(0xFF70A8F5),
        const StrictModePage(),
      ),
      _ActionData(
        'My events',
        'Plan what matters',
        Icons.event_available_rounded,
        const Color(0xFFE88E9B),
        const EventPage(),
      ),
      _ActionData(
        'Achievements',
        'Celebrate progress',
        Icons.emoji_events_rounded,
        const Color(0xFFF2C66D),
        AchievementsPage(progress: progress),
      ),
    ];

    return GridView.builder(
      itemCount: actions.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 11,
        crossAxisSpacing: 11,
        mainAxisExtent: 118,
      ),
      itemBuilder: (context, index) {
        final action = actions[index];
        return _ActionTile(
          action: action,
          onTap: () => onOpenFeature(action.page),
        );
      },
    );
  }
}

class _ActionData {
  const _ActionData(
    this.title,
    this.subtitle,
    this.icon,
    this.color,
    this.page,
  );

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Widget page;
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.action, required this.onTap});

  final _ActionData action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(action.icon, color: action.color, size: 23),
              const Spacer(),
              Text(
                action.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 3),
              Text(
                action.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.action, this.onTap});

  final String title;
  final String? action;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
        ),
        if (action != null)
          TextButton(
            onPressed: onTap,
            child: Text(action!, style: TextStyle(color: AppColors.primary)),
          ),
      ],
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(Icons.bolt_rounded, color: AppColors.primary, size: 21),
    );
  }
}
