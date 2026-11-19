import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../bloc/pomodoro_bloc.dart';
import '../bloc/pomodoro_event.dart';
import '../bloc/pomodoro_state.dart';

class PomodoroSettingsPage extends StatefulWidget {
  const PomodoroSettingsPage({super.key});

  @override
  State<PomodoroSettingsPage> createState() => _PomodoroSettingsPageState();
}

class _PomodoroSettingsPageState extends State<PomodoroSettingsPage> {
  final _formKey = GlobalKey<FormState>();

  final _focusController = TextEditingController();
  final _shortBreakController = TextEditingController();
  final _longBreakController = TextEditingController();
  final _sessionsController = TextEditingController();

  bool _autoStartBreaks = false;
  bool _autoStartFocus = false;
  bool _initialized = false;

  @override
  void dispose() {
    _focusController.dispose();
    _shortBreakController.dispose();
    _longBreakController.dispose();
    _sessionsController.dispose();
    super.dispose();
  }

  void _loadSettings(PomodoroState state) {
    if (_initialized) return;

    final settings = state.settings;

    _focusController.text = '${settings.focusDurationMinutes}';
    _shortBreakController.text = '${settings.shortBreakMinutes}';
    _longBreakController.text = '${settings.longBreakMinutes}';
    _sessionsController.text = '${settings.sessionsBeforeLongBreak}';

    _autoStartBreaks = settings.autoStartBreaks;
    _autoStartFocus = settings.autoStartFocus;

    _initialized = true;
  }

  String? _validateDuration(String? value) {
    final duration = int.tryParse(value ?? '');

    if (duration == null || duration < 1 || duration > 180) {
      return 'Enter a duration between 1 and 180 minutes';
    }

    return null;
  }

  String? _validateSessions(String? value) {
    final sessions = int.tryParse(value ?? '');

    if (sessions == null || sessions < 2 || sessions > 12) {
      return 'Enter a value between 2 and 12';
    }

    return null;
  }

  void _saveSettings(PomodoroState state) {
    if (!_formKey.currentState!.validate()) return;

    final updatedSettings = state.settings.copyWith(
      focusDurationMinutes: int.parse(_focusController.text),
      shortBreakMinutes: int.parse(_shortBreakController.text),
      longBreakMinutes: int.parse(_longBreakController.text),
      sessionsBeforeLongBreak: int.parse(_sessionsController.text),
      autoStartBreaks: _autoStartBreaks,
      autoStartFocus: _autoStartFocus,
    );

    context.read<PomodoroBloc>().add(UpdatePomodoroSettings(updatedSettings));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PomodoroBloc, PomodoroState>(
      builder: (context, state) {
        if (state.status == PomodoroStatus.loading ||
            state.status == PomodoroStatus.initial) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        _loadSettings(state);

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Pomodoro Settings'),
            backgroundColor: AppColors.background,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SESSION DURATIONS',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 20),

                  _DurationField(
                    label: 'Focus Duration',
                    controller: _focusController,
                    validator: _validateDuration,
                  ),
                  const SizedBox(height: 16),

                  _DurationField(
                    label: 'Short Break',
                    controller: _shortBreakController,
                    validator: _validateDuration,
                  ),
                  const SizedBox(height: 16),

                  _DurationField(
                    label: 'Long Break',
                    controller: _longBreakController,
                    validator: _validateDuration,
                  ),
                  const SizedBox(height: 16),

                  _DurationField(
                    label: 'Focus Sessions Before Long Break',
                    controller: _sessionsController,
                    validator: _validateSessions,
                  ),

                  const SizedBox(height: 32),

                  const Text(
                    'AUTOMATION',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),

                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Auto-start breaks',
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: const Text(
                      'Start the next break automatically',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    value: _autoStartBreaks,
                    activeThumbColor: AppColors.primary,
                    onChanged: (value) {
                      setState(() => _autoStartBreaks = value);
                    },
                  ),

                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Auto-start focus',
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: const Text(
                      'Start the next focus session automatically',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    value: _autoStartFocus,
                    activeThumbColor: AppColors.primary,
                    onChanged: (value) {
                      setState(() => _autoStartFocus = value);
                    },
                  ),

                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => _saveSettings(state),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Save Settings',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DurationField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? Function(String?) validator;

  const _DurationField({
    required this.label,
    required this.controller,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          validator: validator,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            suffixText: label.contains('Sessions') ? 'sessions' : 'minutes',
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
