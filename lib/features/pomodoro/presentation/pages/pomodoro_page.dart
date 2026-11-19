import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/strict_mode_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/pomodoro_session_entity.dart';
import '../../../motivational_quotes/presentation/widgets/motivational_quote_dialog.dart';
import '../bloc/pomodoro_bloc.dart';
import '../bloc/pomodoro_event.dart';
import '../bloc/pomodoro_state.dart';
import 'pomodoro_settings_page.dart';
import '../widgets/pomodoro_controls.dart';
import '../widgets/pomodoro_timer_card.dart';

class PomodoroPage extends StatelessWidget {
  const PomodoroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PomodoroBloc>()..add(const LoadPomodoro()),
      child: const _PomodoroView(),
    );
  }
}

class _PomodoroView extends StatelessWidget {
  const _PomodoroView();

  String _sessionTitle(PomodoroSessionType type) {
    return switch (type) {
      PomodoroSessionType.focus => 'Focus Time',
      PomodoroSessionType.shortBreak => 'Short Break',
      PomodoroSessionType.longBreak => 'Long Break',
    };
  }

  Future<void> _selectType(
    BuildContext context,
    PomodoroState state,
    PomodoroSessionType type,
  ) async {
    final session = state.session;
    if (session == null || session.type == type) return;

    if (state.isRunning) {
      final shouldSwitch = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Switch timer?'),
          content: const Text(
            'Changing the timer will reset the current session. Continue?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Switch'),
            ),
          ],
        ),
      );

      if (shouldSwitch != true || !context.mounted) return;
    }

    context.read<PomodoroBloc>().add(SelectPomodoroType(type));
  }

  Future<void> _startFocus(
    BuildContext context,
    PomodoroState state, {
    required bool resume,
  }) async {
    final session = state.session;
    if (session?.isFocus != true) {
      context.read<PomodoroBloc>().add(
        resume ? const ResumePomodoro() : const StartPomodoro(),
      );
      return;
    }

    final strictModeService = getIt<StrictModeService>();
    if (!strictModeService.isSupported) {
      context.read<PomodoroBloc>().add(
        resume ? const ResumePomodoro() : const StartPomodoro(),
      );
      return;
    }

    if (!await strictModeService.isAccessibilityEnabled()) {
      if (!context.mounted) return;

      final openSettings = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Enable Strict Mode'),
          content: const Text(
            'Strict Mode allows WhatsApp and Phone during focus and blocks '
            'other apps. Enable WakeLock in Android Accessibility settings, '
            'then return and start focus again.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Not now'),
            ),
            FilledButton(
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
    context.read<PomodoroBloc>().add(
      resume ? const ResumePomodoro() : const StartPomodoro(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Focus Timer'),
        backgroundColor: AppColors.background,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<PomodoroBloc>(),
                    child: const PomodoroSettingsPage(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocListener<PomodoroBloc, PomodoroState>(
        listenWhen: (previous, current) =>
            previous.status == PomodoroStatus.ready &&
            current.status == PomodoroStatus.ready &&
            current.history.length > previous.history.length,
        listener: (context, state) async {
          await showMotivationalQuoteDialog(
            context,
            title: 'Pomodoro complete!',
          );
        },
        child: BlocBuilder<PomodoroBloc, PomodoroState>(
          builder: (context, state) {
            if (state.status == PomodoroStatus.loading ||
                state.status == PomodoroStatus.initial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == PomodoroStatus.failure) {
              return Center(
                child: Text(
                  state.errorMessage ?? 'Unable to load timer',
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }

            final session = state.session;

            if (session == null) {
              return const Center(
                child: Text(
                  'No timer session available',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            final bloc = context.read<PomodoroBloc>();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Text(
                    _sessionTitle(session.type),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),

                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    children: [
                      _SessionTab(
                        label: 'Focus',
                        selected: session.type == PomodoroSessionType.focus,
                        onTap: () => _selectType(
                          context,
                          state,
                          PomodoroSessionType.focus,
                        ),
                      ),
                      _SessionTab(
                        label: 'Short Break',
                        selected:
                            session.type == PomodoroSessionType.shortBreak,
                        onTap: () => _selectType(
                          context,
                          state,
                          PomodoroSessionType.shortBreak,
                        ),
                      ),
                      _SessionTab(
                        label: 'Long Break',
                        selected: session.type == PomodoroSessionType.longBreak,
                        onTap: () => _selectType(
                          context,
                          state,
                          PomodoroSessionType.longBreak,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 35),

                  PomodoroTimerCard(
                    remainingSeconds: session.remainingSeconds,
                    durationSeconds: session.durationSeconds,
                    progress: session.progress,
                  ),

                  const SizedBox(height: 35),

                  PomodoroControls(
                    isRunning: state.isRunning,
                    isPaused: state.isPaused,
                    onStart: () => _startFocus(context, state, resume: false),
                    onPause: () => bloc.add(const PausePomodoro()),
                    onResume: () => _startFocus(context, state, resume: true),
                    onReset: () => bloc.add(const ResetPomodoro()),
                  ),

                  const SizedBox(height: 35),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'COMPLETED FOCUS SESSIONS',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${session.completedFocusSessions}',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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

class _SessionTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SessionTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.surface,
      labelStyle: TextStyle(
        color: selected ? Colors.black : Colors.white,
        fontWeight: FontWeight.w600,
      ),
      side: BorderSide.none,
    );
  }
}
