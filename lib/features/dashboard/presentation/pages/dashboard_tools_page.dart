import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme_controller.dart';
import '../../../app_usage/presentation/pages/daily_growth_page.dart';
import '../../../events/presentation/pages/event_page.dart';
import '../../../gamification/domain/repositories/progress_repository.dart';
import '../../../gamification/presentation/pages/achievements_page.dart';
import '../../../habits/presentation/pages/habit_page.dart';
import '../../../pomodoro/presentation/pages/pomodoro_page.dart';
import '../../../strict_mode/presentation/pages/strict_mode_page.dart';
import '../../../../injection_container.dart';

class DashboardToolsPage extends StatelessWidget {
  const DashboardToolsPage({required this.onOpenFeature, super.key});

  final ValueChanged<Widget> onOpenFeature;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Explore')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          const Text(
            'Everything you need to build better days.',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose a tool and keep moving toward your goals.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 22),
          const _ThemePickerCard(),
          const SizedBox(height: 22),
          _ToolTile(
            icon: Icons.auto_awesome_rounded,
            color: AppColors.primary,
            title: 'Daily Growth',
            subtitle: 'Goal-based steps and screen-time guidance',
            onTap: () => onOpenFeature(const DailyGrowthPage()),
          ),
          _ToolTile(
            icon: Icons.track_changes_rounded,
            color: const Color(0xFF63B8A8),
            title: 'Habits',
            subtitle: 'Build routines and see your consistency',
            onTap: () => onOpenFeature(const HabitPage()),
          ),
          _ToolTile(
            icon: Icons.timer_rounded,
            color: const Color(0xFF9B8AFB),
            title: 'Pomodoro Focus',
            subtitle: 'Turn focused time into meaningful progress',
            onTap: () => onOpenFeature(const PomodoroPage()),
          ),
          _ToolTile(
            icon: Icons.shield_rounded,
            color: const Color(0xFF70A8F5),
            title: 'Strict Mode',
            subtitle: 'Reduce distractions while you work',
            onTap: () => onOpenFeature(const StrictModePage()),
          ),
          _ToolTile(
            icon: Icons.event_available_rounded,
            color: const Color(0xFFE88E9B),
            title: 'Events',
            subtitle: 'Plan important moments and reminders',
            onTap: () => onOpenFeature(const EventPage()),
          ),
          _ToolTile(
            icon: Icons.emoji_events_rounded,
            color: const Color(0xFFF2C66D),
            title: 'Achievements',
            subtitle: 'Review milestones you have unlocked',
            onTap: () async {
              try {
                final progress = await getIt<ProgressRepository>()
                    .getProgress();
                if (!context.mounted) return;
                onOpenFeature(AchievementsPage(progress: progress));
              } catch (error) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Could not load achievements: $error'),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class _ThemePickerCard extends StatefulWidget {
  const _ThemePickerCard();

  @override
  State<_ThemePickerCard> createState() => _ThemePickerCardState();
}

class _ThemePickerCardState extends State<_ThemePickerCard> {
  final _themeController = getIt<AppThemeController>();
  bool _isSaving = false;

  Future<void> _selectPalette(AppColorPalette palette) async {
    setState(() => _isSaving = true);
    try {
      await _themeController.selectPalette(palette);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${palette.name} theme applied')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not save theme: $error')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _themeController,
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.18),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(
                      Icons.palette_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Make it yours',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Choose your app colors',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_isSaving)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
              const SizedBox(height: 17),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: AppColorPalette.values.map((palette) {
                  final selected = palette == _themeController.palette;
                  return Tooltip(
                    message: '${palette.name} · ${palette.description}',
                    child: Semantics(
                      button: true,
                      selected: selected,
                      label: '${palette.name} theme',
                      child: InkWell(
                        onTap: _isSaving ? null : () => _selectPalette(palette),
                        borderRadius: BorderRadius.circular(18),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 49,
                          height: 49,
                          decoration: BoxDecoration(
                            color: palette.surfaceLight,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: selected
                                  ? palette.primary
                                  : Colors.white.withValues(alpha: 0.08),
                              width: selected ? 2 : 1,
                            ),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: palette.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              if (selected)
                                Icon(
                                  Icons.check_rounded,
                                  color: palette.background,
                                  size: 17,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 11),
              Text(
                '${_themeController.palette.name} · ${_themeController.palette.description}',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ToolTile extends StatelessWidget {
  const _ToolTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(17),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 7,
          ),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: color),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text(
              subtitle,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios_rounded,
            size: 15,
            color: AppColors.textSecondary,
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
