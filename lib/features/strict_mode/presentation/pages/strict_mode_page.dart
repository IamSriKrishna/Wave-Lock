import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/strict_mode_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../injection_container.dart';

import '../../../daily_missions/presentation/bloc/mission_bloc.dart';
import '../../../daily_missions/presentation/bloc/mission_event.dart';
import '../../../daily_missions/presentation/bloc/mission_state.dart';
import '../../../daily_missions/domain/entities/mission_entity.dart';

import '../../domain/entities/strict_mode_entity.dart';
import '../bloc/strict_mode_bloc.dart';
import '../bloc/strict_mode_event.dart';
import '../bloc/strict_mode_state.dart';

import 'app_selection_page.dart';

class StrictModePage extends StatelessWidget {
  const StrictModePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<StrictModeBloc>()..add(const LoadStrictMode()),
      child: const _StrictModeView(),
    );
  }
}

class _StrictModeView extends StatelessWidget {
  const _StrictModeView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Strict Mode'),
        backgroundColor: AppColors.background,
      ),
      body: BlocConsumer<StrictModeBloc, StrictModeState>(
        listener: (context, state) {
          if (state.status == StrictModeLoadStatus.failure &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
        },
        builder: (context, state) {
          if (state.isLoading || state.settings == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final settings = state.settings!;
          final bloc = context.read<StrictModeBloc>();

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildStatusCard(settings),
              const SizedBox(height: 24),

              const Text(
                'Blocking configuration',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              _buildBlockingOption(
                title: 'Selected applications',
                subtitle: 'Block only apps you choose.',
                value: StrictModeBlockingType.selectedApps,
                groupValue: settings.blockingType,
                enabled: !settings.isActive,
                onChanged: (value) {
                  if (value != null) {
                    bloc.add(UpdateBlockingType(value));
                  }
                },
              ),

              _buildBlockingOption(
                title: 'All eligible applications',
                subtitle: 'Block all eligible third-party apps.',
                value: StrictModeBlockingType.allEligibleApps,
                groupValue: settings.blockingType,
                enabled: !settings.isActive,
                onChanged: (value) {
                  if (value != null) {
                    bloc.add(UpdateBlockingType(value));
                  }
                },
              ),

              if (settings.blocksSelectedApps) ...[
                const SizedBox(height: 16),
                ListTile(
                  tileColor: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: const Text(
                    'Choose applications',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    '${settings.blockedPackageNames.length} selected',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppColors.primary,
                  ),
                  enabled: !settings.isActive,
                  onTap: () async {
                    final selected = await Navigator.push<List<String>>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AppSelectionPage(
                          initiallySelectedPackages:
                              settings.blockedPackageNames,
                        ),
                      ),
                    );

                    if (selected != null && context.mounted) {
                      bloc.add(UpdateSelectedApps(selected));
                    }
                  },
                ),
              ],

              const SizedBox(height: 24),

              if (settings.isActive)
                _buildActiveSession(settings)
              else
                _buildEnableButton(context, settings),

              const SizedBox(height: 16),

              const Text(
                'Strict Mode uses Android Accessibility Service '
                'with your explicit permission. Essential system '
                'functions, emergency calling and device settings '
                'remain accessible.',
                style: TextStyle(color: Colors.grey, fontSize: 12, height: 1.5),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatusCard(StrictModeEntity settings) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: settings.isActive ? AppColors.primary : Colors.white12,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            settings.isActive ? Icons.lock : Icons.lock_open,
            color: AppColors.primary,
            size: 36,
          ),
          const SizedBox(height: 12),
          Text(
            settings.isActive ? 'Strict Mode Active' : 'Strict Mode Off',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            settings.isActive
                ? 'All eligible apps are blocked until you complete your linked mission.'
                : 'Protect your focus by limiting distracting apps.',
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildBlockingOption({
    required String title,
    required String subtitle,
    required StrictModeBlockingType value,
    required StrictModeBlockingType groupValue,
    required bool enabled,
    required ValueChanged<StrictModeBlockingType?> onChanged,
  }) {
    return RadioListTile<StrictModeBlockingType>(
      value: value,
      groupValue: groupValue,
      onChanged: enabled ? onChanged : null,
      activeColor: AppColors.primary,
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey)),
      tileColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  Widget _buildActiveSession(StrictModeEntity settings) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Linked mission ID',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Text(
            settings.linkedMissionId ?? 'Unknown mission',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Complete the linked mission to release Strict Mode.',
            style: TextStyle(color: AppColors.primary, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildEnableButton(BuildContext context, StrictModeEntity settings) {
    return ElevatedButton(
      onPressed: () async {
        final strictModeService = getIt<StrictModeService>();
        if (!await strictModeService.isAccessibilityEnabled()) {
          if (!context.mounted) return;

          final openSettings = await showDialog<bool>(
            context: context,
            builder: (dialogContext) => AlertDialog(
              backgroundColor: AppColors.surface,
              title: const Text(
                'Enable Strict Mode',
                style: TextStyle(color: Colors.white),
              ),
              content: const Text(
                'Allow WakeLock in Android Accessibility settings to block '
                'other apps while you work on the linked mission.',
                style: TextStyle(color: Colors.white70),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Not now'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: const Text('Open Settings'),
                ),
              ],
            ),
          );

          if (openSettings == true) {
            await strictModeService.openAccessibilitySettings();
          }
          return;
        }

        if (!context.mounted) return;

        final missionId = await showModalBottomSheet<String>(
          context: context,
          isScrollControlled: true,
          backgroundColor: AppColors.surface,
          builder: (_) {
            return BlocProvider(
              create: (_) =>
                  getIt<MissionBloc>()..add(const LoadDailyMissions()),
              child: const _MissionSelectionSheet(),
            );
          },
        );

        if (!context.mounted || missionId == null) return;

        final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              title: const Text(
                'Enable Strict Mode?',
                style: TextStyle(color: Colors.white),
              ),
              content: const Text(
                'Strict Mode will be linked to this mission. '
                'All eligible apps will be blocked until it is completed. '
                'Your selected-app list will not be used for this mission.',
                style: TextStyle(color: Colors.white70),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext, false);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext, true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Confirm'),
                ),
              ],
            );
          },
        );

        if (!context.mounted || confirmed != true) return;

        context.read<StrictModeBloc>().add(EnableStrictMode(missionId));
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: const Text(
        'Enable Strict Mode',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _MissionSelectionSheet extends StatelessWidget {
  const _MissionSelectionSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FractionallySizedBox(
        heightFactor: 0.75,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select a mission',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Choose the mission that will release Strict Mode.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: BlocBuilder<MissionBloc, MissionState>(
                  builder: (context, state) {
                    if (state.status == MissionStatus.initial ||
                        state.status == MissionStatus.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state.status == MissionStatus.failure) {
                      return Center(
                        child: Text(
                          state.errorMessage ?? 'Unable to load missions.',
                          style: const TextStyle(color: Colors.redAccent),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    final eligibleMissions = state.missions.where((mission) {
                      return mission.status == 'accepted' ||
                          mission.status == 'inProgress' ||
                          mission.status == 'paused';
                    }).toList();

                    if (eligibleMissions.isEmpty) {
                      return const Center(
                        child: Text(
                          'No available missions.\n\n'
                          'Please accept your daily missions first.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70, height: 1.6),
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: eligibleMissions.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final mission = eligibleMissions[index];

                        return _buildMissionTile(context, mission);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMissionTile(BuildContext context, MissionEntity mission) {
    return ListTile(
      tileColor: AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      leading: const CircleAvatar(
        backgroundColor: AppColors.primary,
        child: Icon(Icons.flag_rounded, color: Colors.black),
      ),
      title: Text(
        mission.title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        '${mission.durationMinutes} minutes • ${mission.status}',
        style: const TextStyle(color: Colors.grey),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.primary),
      onTap: () {
        Navigator.pop(context, mission.id);
      },
    );
  }
}
