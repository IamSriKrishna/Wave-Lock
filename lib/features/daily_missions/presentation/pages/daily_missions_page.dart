import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../motivational_quotes/presentation/widgets/motivational_quote_dialog.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/mission_entity.dart';
import '../bloc/mission_bloc.dart';
import '../bloc/mission_event.dart';
import '../bloc/mission_state.dart';

import '../../../gamification/domain/services/achievement_engine.dart';
import '../../../gamification/presentation/widgets/achievement_unlock_dialog.dart';

class DailyMissionsPage extends StatelessWidget {
  const DailyMissionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<MissionBloc>()..add(const LoadDailyMissions()),
      child: BlocListener<MissionBloc, MissionState>(
        listenWhen: (previous, current) =>
            (current.newlyUnlockedAchievements.isNotEmpty &&
                previous.newlyUnlockedAchievements !=
                    current.newlyUnlockedAchievements) ||
            (current.startedMissionId != null &&
                previous.startedMissionId != current.startedMissionId) ||
            (current.completedMissionId != null &&
                previous.completedMissionId != current.completedMissionId),
        listener: (context, state) async {
          if (state.startedMissionId != null) {
            final mission = state.missions.firstWhere(
              (item) => item.id == state.startedMissionId,
            );
            await showMotivationalQuoteDialog(
              context,
              title: 'Mission started: ${mission.title}',
            );
            if (!context.mounted) return;
          }

          if (state.completedMissionId != null) {
            final mission = state.missions.firstWhere(
              (item) => item.id == state.completedMissionId,
            );
            await showMotivationalQuoteDialog(
              context,
              title: 'Mission completed: ${mission.title}',
            );
            if (!context.mounted) return;
          }

          for (final id in state.newlyUnlockedAchievements) {
            final achievement = AchievementEngine.achievements.firstWhere(
              (item) => item.id == id,
            );

            await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => AchievementUnlockDialog(achievement: achievement),
            );
          }

          if (context.mounted) {
            context.read<MissionBloc>().add(ClearNewlyUnlockedAchievements());
          }
        },

        child: const _DailyMissionsView(),
      ),
    );
  }
}

Future<void> _promptBeforeMissionAction(
  BuildContext context,
  String action,
  String missionTitle,
  VoidCallback onContinue,
) async {
  final shouldContinue = await showMotivationalQuoteDialog(
    context,
    title: 'Ready to $action $missionTitle?',
    canCancel: true,
  );
  if (shouldContinue && context.mounted) onContinue();
}

class _DailyMissionsView extends StatelessWidget {
  const _DailyMissionsView();

  String formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainingSeconds = seconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${remainingSeconds.toString().padLeft(2, '0')}';
    }

    return '${minutes.toString().padLeft(2, '0')}:'
        '${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Daily Missions'), centerTitle: true),
      body: BlocBuilder<MissionBloc, MissionState>(
        builder: (context, state) {
          if (state.status == MissionStatus.initial ||
              state.status == MissionStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == MissionStatus.failure) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 40),
                    const SizedBox(height: 12),
                    Text(
                      state.errorMessage ?? 'Something went wrong.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () {
                        context.read<MissionBloc>().add(
                          const LoadDailyMissions(),
                        );
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final isReview =
              state.missions.isNotEmpty &&
              state.missions.every((mission) => mission.status == 'draft');

          final completed = state.completedCount;
          final total = state.totalCount;

          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Text(
                        isReview ? 'Plan your day.' : 'Make today count.',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isReview
                            ? 'Review your recommended missions and choose what you want to accomplish.'
                            : 'Stay focused. Make progress one mission at a time.',
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),

                      if (!isReview) ...[
                        _ProgressCard(
                          completed: completed,
                          total: total,
                          progress: state.completionProgress,
                        ),
                        const SizedBox(height: 20),
                      ],

                      ...state.missions.map((mission) {
                        return _MissionCard(
                          mission: mission,
                          elapsedSeconds: mission.elapsedAt(state.clockNow),
                          isReview: isReview,
                          formatDuration: formatDuration,
                        );
                      }),

                      if (state.errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          state.errorMessage!,
                          style: TextStyle(color: colors.error),
                        ),
                      ],
                    ],
                  ),
                ),

                if (isReview)
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          '${state.selectedCount} missions · '
                          '${state.selectedMinutes} minutes selected',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: state.status == MissionStatus.accepting
                              ? null
                              : () {
                                  context.read<MissionBloc>().add(
                                    const AcceptMissions(),
                                  );
                                },
                          child: state.status == MissionStatus.accepting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Accept Selected Missions'),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            context.read<MissionBloc>().add(
                              const RegenerateMissions(),
                            );
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Generate Again'),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final int completed;
  final int total;
  final double progress;

  const _ProgressCard({
    required this.completed,
    required this.total,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Daily progress',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('$completed / $total completed'),
              ],
            ),
            const SizedBox(height: 14),
            LinearProgressIndicator(
              value: progress,
              minHeight: 9,
              borderRadius: BorderRadius.circular(20),
              color: colors.primary,
            ),
            const SizedBox(height: 8),
            Text(
              '${(progress * 100).round()}% completed',
              style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _MissionCard extends StatelessWidget {
  final MissionEntity mission;
  final int elapsedSeconds;
  final bool isReview;
  final String Function(int) formatDuration;

  const _MissionCard({
    required this.mission,
    required this.elapsedSeconds,
    required this.isReview,
    required this.formatDuration,
  });

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<MissionBloc>();
    final colors = Theme.of(context).colorScheme;

    final isRunning = mission.status == 'inProgress';
    final isPaused = mission.status == 'paused';
    final isCompleted = mission.status == 'completed';

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    mission.title,
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                if (isReview)
                  Checkbox(
                    value: mission.isSelected,
                    onChanged: (_) {
                      bloc.add(ToggleMissionSelection(mission.id));
                    },
                  )
                else
                  _StatusLabel(status: mission.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              mission.description,
              style: TextStyle(color: colors.onSurfaceVariant, height: 1.4),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoChip(icon: Icons.flag_outlined, text: mission.goal),
                _InfoChip(
                  icon: Icons.schedule,
                  text: '${mission.durationMinutes} min target',
                ),
                _InfoChip(icon: Icons.trending_up, text: mission.difficulty),
              ],
            ),

            if (!isReview) ...[
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      formatDuration(elapsedSeconds),
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontFeatures: const [],
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ACTUAL TIME SPENT',
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 10,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              if (mission.status == 'accepted')
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      _promptBeforeMissionAction(
                        context,
                        'start',
                        mission.title,
                        () => bloc.add(StartMission(mission.id)),
                      );
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start Mission'),
                  ),
                ),

              if (isRunning)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          bloc.add(PauseMission(mission.id));
                        },
                        icon: const Icon(Icons.pause),
                        label: const Text('Pause'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {
                          _promptBeforeMissionAction(
                            context,
                            'complete',
                            mission.title,
                            () => bloc.add(CompleteMission(mission.id)),
                          );
                        },
                        icon: const Icon(Icons.check),
                        label: const Text('Complete'),
                      ),
                    ),
                  ],
                ),

              if (isPaused)
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {
                          _promptBeforeMissionAction(
                            context,
                            'resume',
                            mission.title,
                            () => bloc.add(ResumeMission(mission.id)),
                          );
                        },
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Resume'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _promptBeforeMissionAction(
                            context,
                            'complete',
                            mission.title,
                            () => bloc.add(CompleteMission(mission.id)),
                          );
                        },
                        icon: const Icon(Icons.check),
                        label: const Text('Complete'),
                      ),
                    ),
                  ],
                ),

              if (isCompleted)
                Row(
                  children: [
                    Icon(Icons.check_circle, color: colors.primary),
                    const SizedBox(width: 8),
                    const Text('Mission completed'),
                  ],
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusLabel extends StatelessWidget {
  final String status;

  const _StatusLabel({required this.status});

  @override
  Widget build(BuildContext context) {
    final label = switch (status) {
      'accepted' => 'READY',
      'inProgress' => 'IN PROGRESS',
      'paused' => 'PAUSED',
      'completed' => 'COMPLETED',
      _ => status.toUpperCase(),
    };

    return Text(
      label,
      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13),
          const SizedBox(width: 5),
          Text(text, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}
