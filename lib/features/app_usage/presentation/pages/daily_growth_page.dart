import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../injection_container.dart';
import '../../../onboarding/domain/entities/user_entity.dart';
import '../../../onboarding/domain/repositories/user_repository.dart';
import '../../data/repositories/daily_growth_progress_repository.dart';
import '../../domain/entities/app_usage_snapshot.dart';
import '../../domain/entities/daily_growth_step.dart';
import '../../domain/services/app_usage_service.dart';
import '../../domain/services/daily_growth_plan_generator.dart';

class DailyGrowthPage extends StatefulWidget {
  const DailyGrowthPage({super.key});

  @override
  State<DailyGrowthPage> createState() => _DailyGrowthPageState();
}

class _DailyGrowthPageState extends State<DailyGrowthPage>
    with WidgetsBindingObserver {
  final _userRepository = getIt<UserRepository>();
  final _usageService = getIt<AppUsageService>();
  final _progressRepository = getIt<DailyGrowthProgressRepository>();
  final _planGenerator = getIt<DailyGrowthPlanGenerator>();

  UserEntity? _user;
  AppUsageSnapshot? _usage;
  List<DailyGrowthStep> _steps = const [];
  Set<String> _completedStepIds = {};
  String? _usageError;
  String? _error;
  String? _savingStepId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadPlan();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadPlan();
    }
  }

  Future<void> _loadPlan() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = await _userRepository.getUser();
      if (user == null) {
        throw StateError('Your profile was not found. Please complete setup.');
      }

      AppUsageSnapshot? usage;
      String? usageError;
      try {
        usage = await _usageService.getWeeklyUsage();
      } catch (error) {
        usageError = error.toString();
      }

      final dateKey = _todayKey;
      final completedStepIds = await _progressRepository.getCompletedStepIds(
        dateKey,
      );
      final steps = _planGenerator.generate(user: user, usage: usage);
      final validStepIds = steps.map((step) => step.id).toSet();
      if (!mounted) return;
      setState(() {
        _user = user;
        _usage = usage;
        _usageError = usageError;
        _completedStepIds = completedStepIds.intersection(validStepIds);
        _steps = steps;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleStep(DailyGrowthStep step, bool isComplete) async {
    final updated = {..._completedStepIds};
    if (isComplete) {
      updated.add(step.id);
    } else {
      updated.remove(step.id);
    }

    setState(() {
      _savingStepId = step.id;
      _error = null;
    });
    try {
      await _progressRepository.saveCompletedStepIds(_todayKey, updated);
      if (!mounted) return;
      setState(() {
        _completedStepIds = updated;
        _savingStepId = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _savingStepId = null;
        _error = 'Could not save your progress: $error';
      });
    }
  }

  Future<void> _openUsageSettings() async {
    try {
      await _usageService.openUsageAccessSettings();
    } catch (error) {
      if (!mounted) return;
      setState(() => _usageError = error.toString());
    }
  }

  String get _todayKey {
    final today = DateTime.now();
    return '${today.year.toString().padLeft(4, '0')}-'
        '${today.month.toString().padLeft(2, '0')}-'
        '${today.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = _completedStepIds.length;
    final progress = _steps.isEmpty ? 0.0 : completedCount / _steps.length;
    final todayUsage = _usage?.days.where((day) {
      final now = DateTime.now();
      return day.date.year == now.year &&
          day.date.month == now.month &&
          day.date.day == now.day;
    }).firstOrNull;

    return Scaffold(
      appBar: AppBar(title: const Text('Daily Growth')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null && _user == null
          ? _ErrorState(message: _error!, onRetry: _loadPlan)
          : RefreshIndicator(
              onRefresh: _loadPlan,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    _user?.name.isNotEmpty == true
                        ? 'Small steps, ${_user!.name}.'
                        : 'Small steps, real progress.',
                    style: const TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'A daily challenge built around your goals and screen-time habits. Complete each stage to earn points.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      height: 1.45,
                    ),
                  ),
                  if (_user != null) ...[
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _user!.goals
                          .map((goal) => Chip(label: Text(goal)))
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 18),
                  _ProgressCard(
                    completed: completedCount,
                    total: _steps.length,
                    progress: progress,
                  ),
                  const SizedBox(height: 16),
                  if (_usageError != null)
                    _InfoCard(
                      icon: Icons.info_outline,
                      text: 'Usage details could not be loaded: $_usageError',
                    )
                  else if (_usage?.isSupported == false)
                    const _InfoCard(
                      icon: Icons.phone_android,
                      text: 'App usage insights are available on Android. Your goal-based stages still work here.',
                    )
                  else if (_usage?.hasAccess == false)
                    _InfoCard(
                      icon: Icons.insights_outlined,
                      text: 'Enable Usage Access to personalize your screen-time challenge using your app activity.',
                      action: TextButton(
                        onPressed: _openUsageSettings,
                        child: const Text('Enable'),
                      ),
                    )
                  else if (todayUsage != null)
                    _InfoCard(
                      icon: Icons.phone_android,
                      text:
                          'Today: ${_formatDuration(todayUsage.totalUsage)} across your other apps. Your first stage is based on your highest-use app.',
                    ),
                  const SizedBox(height: 18),
                  ..._steps.indexed.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _GrowthStepCard(
                        stage: entry.$1 + 1,
                        step: entry.$2,
                        isComplete: _completedStepIds.contains(entry.$2.id),
                        isSaving: _savingStepId == entry.$2.id,
                        onChanged: _savingStepId == null
                            ? (value) => _toggleStep(entry.$2, value)
                            : null,
                      ),
                    ),
                  ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _error!,
                        style: const TextStyle(color: AppColors.danger),
                      ),
                    ),
                  if (_steps.isNotEmpty && completedCount == _steps.length)
                    const _InfoCard(
                      icon: Icons.emoji_events_outlined,
                      text: 'Challenge complete! You showed up for your goals today. Your progress is saved.',
                    ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  static String _formatDuration(Duration duration) {
    final hours = duration.inMinutes ~/ 60;
    final minutes = duration.inMinutes % 60;
    if (hours == 0) return '$minutes min';
    if (minutes == 0) return '$hours h';
    return '$hours h $minutes min';
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.completed,
    required this.total,
    required this.progress,
  });

  final int completed;
  final int total;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.stars_rounded, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$completed / $total stages complete',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                '+${completed * 20} pts',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            borderRadius: BorderRadius.circular(8),
            backgroundColor: AppColors.surfaceLight,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _GrowthStepCard extends StatelessWidget {
  const _GrowthStepCard({
    required this.stage,
    required this.step,
    required this.isComplete,
    required this.isSaving,
    required this.onChanged,
  });

  final int stage;
  final DailyGrowthStep step;
  final bool isComplete;
  final bool isSaving;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isComplete ? AppColors.success : AppColors.surfaceLight,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: isComplete,
            onChanged: isSaving || onChanged == null
                ? null
                : (value) => onChanged!(value ?? false),
            activeColor: AppColors.success,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'STAGE $stage · ${step.estimatedMinutes} MIN',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.7,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  step.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  step.goal,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  step.description,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          if (isSaving)
            const Padding(
              padding: EdgeInsets.only(left: 8, top: 8),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.icon, required this.text, this.action});

  final IconData icon;
  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
          ?action,
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}
