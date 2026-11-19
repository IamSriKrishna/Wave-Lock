
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../injection_container.dart';
import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_event.dart';
import '../bloc/onboarding_state.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  static const _goals = [
    'Coding & Programming',
    'Learning',
    'Professional Work',
    'College & Academics',
    'Business',
    'Reading',
    'Fitness',
    'Personal Development',
  ];

  static const _experience = [
    'Beginner',
    'Intermediate',
    'Advanced',
  ];

  static const _availability = {
    '1 hour': 60,
    '2 hours': 120,
    '3 hours': 180,
    '4 hours': 240,
    '5 hours': 300,
  };

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<OnboardingBloc>(),
      child: BlocConsumer<OnboardingBloc, OnboardingState>(
        listener: (context, state) {
          if (state.status == OnboardingStatus.success) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => const DashboardPage(),
              ),
            );
          }
        },
        builder: (context, state) {
          final bloc = context.read<OnboardingBloc>();

          return Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(state),
                    const SizedBox(height: 32),

                    Expanded(
                      child: SingleChildScrollView(
                        child: _buildStep(
                          context,
                          state,
                        ),
                      ),
                    ),

                    if (state.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          state.errorMessage!,
                          style: const TextStyle(
                            color: AppColors.danger,
                            fontSize: 13,
                          ),
                        ),
                      ),

                    _buildNavigation(
                      context,
                      bloc,
                      state,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(OnboardingState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.bolt_rounded,
              color: AppColors.primary,
              size: 30,
            ),
            const SizedBox(width: 8),
            const Text(
              'WakeLock',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Text(
              '${state.currentStep + 1} / 6',
              style: const TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: (state.currentStep + 1) / 6,
            minHeight: 6,
            backgroundColor: AppColors.surfaceLight,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildStep(
    BuildContext context,
    OnboardingState state,
  ) {
    switch (state.currentStep) {
      case 0:
        return _nameStep(context, state);
      case 1:
        return _goalsStep(context, state);
      case 2:
        return _experienceStep(context, state);
      case 3:
        return _availabilityStep(context, state);
      case 4:
        return _workingHoursStep(context, state);
      case 5:
        return _reviewStep(state);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _stepTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 28),
      ],
    );
  }

  Widget _nameStep(
    BuildContext context,
    OnboardingState state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepTitle(
          'First, what should we call you?',
          'Your productivity journey starts with you.',
        ),
        TextField(
          onChanged: (value) {
            context.read<OnboardingBloc>().add(
              NameChanged(value),
            );
          },
          decoration: const InputDecoration(
            hintText: 'Enter your name',
            prefixIcon: Icon(Icons.person_outline),
          ),
        ),
        const SizedBox(height: 24),
        _infoCard(
          Icons.waving_hand_outlined,
          'A personal experience',
          'WakeLock will use your name to personalize your daily experience.',
        ),
      ],
    );
  }

  Widget _goalsStep(
    BuildContext context,
    OnboardingState state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepTitle(
          'What do you want to improve?',
          'Select all the areas you want WakeLock to help you with.',
        ),
        Wrap(
          spacing: 10,
          runSpacing: 12,
          children: _goals.map((goal) {
            final selected = state.goals.contains(goal);

            return FilterChip(
              label: Text(goal),
              selected: selected,
              showCheckmark: true,
              selectedColor: AppColors.primary.withValues(
                alpha: 0.2,
              ),
              checkmarkColor: AppColors.primary,
              onSelected: (value) {
                final updated = [...state.goals];

                if (value) {
                  updated.add(goal);
                } else {
                  updated.remove(goal);
                }

                context.read<OnboardingBloc>().add(
                  GoalsChanged(updated),
                );
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        Text(
          '${state.goals.length} goals selected',
          style: const TextStyle(
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _experienceStep(
    BuildContext context,
    OnboardingState state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepTitle(
          "What's your experience level?",
          "We'll adjust your daily missions based on your current level.",
        ),
        ..._experience.map((level) {
          final value = level.toLowerCase();
          final selected = state.experienceLevel == value;

          return _selectionCard(
            title: level,
            subtitle: switch (value) {
              'beginner' => 'I\'m just getting started.',
              'intermediate' => 'I have some experience.',
              _ => 'I\'m confident in my skills.',
            },
            selected: selected,
            onTap: () {
              context.read<OnboardingBloc>().add(
                ExperienceChanged(value),
              );
            },
          );
        }),
      ],
    );
  }

  Widget _availabilityStep(
    BuildContext context,
    OnboardingState state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepTitle(
          'How much time can you dedicate?',
          'Be realistic. Consistency matters more than intensity.',
        ),
        ..._availability.entries.map((entry) {
          return _selectionCard(
            title: entry.key,
            subtitle: 'Available daily',
            selected:
                state.dailyAvailableMinutes == entry.value,
            onTap: () {
              context.read<OnboardingBloc>().add(
                AvailabilityChanged(entry.value),
              );
            },
          );
        }),
      ],
    );
  }

  Widget _workingHoursStep(
    BuildContext context,
    OnboardingState state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepTitle(
          'When are you most productive?',
          'Choose your preferred working window.',
        ),
        _timeCard(
          context,
          title: 'Start time',
          value: state.preferredStartTime,
          onTap: () => _selectTime(
            context,
            state.preferredStartTime,
            true,
          ),
        ),
        const SizedBox(height: 16),
        _timeCard(
          context,
          title: 'End time',
          value: state.preferredEndTime,
          onTap: () => _selectTime(
            context,
            state.preferredEndTime,
            false,
          ),
        ),
      ],
    );
  }

  Future<void> _selectTime(
    BuildContext context,
    String current,
    bool isStart,
  ) async {
    final parts = current.split(':');

    final initial = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );

    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );

    if (picked == null || !context.mounted) return;

    final state = context.read<OnboardingBloc>().state;

    String format(TimeOfDay time) {
      return '${time.hour.toString().padLeft(2, '0')}:'
          '${time.minute.toString().padLeft(2, '0')}';
    }

    context.read<OnboardingBloc>().add(
      WorkingHoursChanged(
        startTime: isStart
            ? format(picked)
            : state.preferredStartTime,
        endTime: isStart
            ? state.preferredEndTime
            : format(picked),
      ),
    );
  }

  Widget _reviewStep(OnboardingState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepTitle(
          'Your productivity profile',
          "Here's what we've learned about you. You can go back and make changes.",
        ),
        _reviewItem('Name', state.name),
        _reviewItem('Goals', state.goals.join(', ')),
        _reviewItem(
          'Experience',
          state.experienceLevel,
        ),
        _reviewItem(
          'Daily availability',
          '${state.dailyAvailableMinutes ~/ 60}h '
              '${state.dailyAvailableMinutes % 60}m',
        ),
        _reviewItem(
          'Working hours',
          '${state.preferredStartTime} - '
              '${state.preferredEndTime}',
        ),
        const SizedBox(height: 20),
        _infoCard(
          Icons.auto_awesome,
          "You're ready!",
          'WakeLock will use these preferences to recommend your daily missions.',
        ),
      ],
    );
  }

  Widget _selectionCard({
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.10)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : AppColors.surfaceLight,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: selected
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _timeCard(
    BuildContext context, {
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.surfaceLight,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.access_time,
              color: AppColors.primary,
            ),
            const SizedBox(width: 14),
            Expanded(child: Text(title)),
            Text(
              value,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.edit_outlined, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _reviewItem(String title, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(
    IconData icon,
    String title,
    String description,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigation(
    BuildContext context,
    OnboardingBloc bloc,
    OnboardingState state,
  ) {
    final isLast = state.currentStep == 5;
    final isSaving = state.status == OnboardingStatus.saving;

    return Row(
      children: [
        if (state.currentStep > 0)
          OutlinedButton(
            onPressed: isSaving
                ? null
                : () => bloc.add(PreviousStepPressed()),
            child: const Text('Back'),
          ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton(
            onPressed: isSaving
                ? null
                : () {
                    if (isLast) {
                      bloc.add(SubmitOnboarding());
                    } else {
                      bloc.add(NextStepPressed());
                    }
                  },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    isLast ? 'Create my profile' : 'Continue',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
