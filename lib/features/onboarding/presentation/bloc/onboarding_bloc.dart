import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';

import 'onboarding_event.dart';
import 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final UserRepository _repository;

  OnboardingBloc({required this._repository}) : super(const OnboardingState()) {
    on<NameChanged>(_onNameChanged);
    on<GoalsChanged>(_onGoalsChanged);
    on<ExperienceChanged>(_onExperienceChanged);
    on<AvailabilityChanged>(_onAvailabilityChanged);
    on<WorkingHoursChanged>(_onWorkingHoursChanged);
    on<NextStepPressed>(_onNextStep);
    on<PreviousStepPressed>(_onPreviousStep);
    on<SubmitOnboarding>(_onSubmit);
  }

  void _onNameChanged(NameChanged event, Emitter<OnboardingState> emit) {
    emit(state.copyWith(name: event.name, clearError: true));
  }

  void _onGoalsChanged(GoalsChanged event, Emitter<OnboardingState> emit) {
    emit(state.copyWith(goals: List.unmodifiable(event.goals)));
  }

  void _onExperienceChanged(
    ExperienceChanged event,
    Emitter<OnboardingState> emit,
  ) {
    emit(state.copyWith(experienceLevel: event.experience));
  }

  void _onAvailabilityChanged(
    AvailabilityChanged event,
    Emitter<OnboardingState> emit,
  ) {
    emit(state.copyWith(dailyAvailableMinutes: event.minutes));
  }

  void _onWorkingHoursChanged(
    WorkingHoursChanged event,
    Emitter<OnboardingState> emit,
  ) {
    emit(
      state.copyWith(
        preferredStartTime: event.startTime,
        preferredEndTime: event.endTime,
      ),
    );
  }

  void _onNextStep(NextStepPressed event, Emitter<OnboardingState> emit) {
    if (!_isCurrentStepValid()) {
      emit(state.copyWith(errorMessage: _validationMessage()));
      return;
    }

    if (state.currentStep < 5) {
      emit(
        state.copyWith(currentStep: state.currentStep + 1, clearError: true),
      );
    }
  }

  void _onPreviousStep(
    PreviousStepPressed event,
    Emitter<OnboardingState> emit,
  ) {
    if (state.currentStep > 0) {
      emit(
        state.copyWith(currentStep: state.currentStep - 1, clearError: true),
      );
    }
  }

  bool _isCurrentStepValid() {
    switch (state.currentStep) {
      case 0:
        return state.name.trim().length >= 2;
      case 1:
        return state.goals.isNotEmpty;
      case 2:
        return state.experienceLevel.isNotEmpty;
      case 3:
        return state.dailyAvailableMinutes > 0;
      case 4:
        return _isValidWorkingHours();
      default:
        return true;
    }
  }

  String _validationMessage() {
    switch (state.currentStep) {
      case 0:
        return 'Please enter a name with at least 2 characters.';
      case 1:
        return 'Please select at least one goal.';
      case 4:
        return 'End time must be later than start time.';
      default:
        return 'Please complete this step.';
    }
  }

  bool _isValidWorkingHours() {
    final start = _timeToMinutes(state.preferredStartTime);
    final end = _timeToMinutes(state.preferredEndTime);

    return end > start;
  }

  int _timeToMinutes(String time) {
    final parts = time.split(':');

    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  Future<void> _onSubmit(
    SubmitOnboarding event,
    Emitter<OnboardingState> emit,
  ) async {
    if (state.status == OnboardingStatus.saving) return;

    if (state.name.trim().length < 2 ||
        state.goals.isEmpty ||
        !_isValidWorkingHours()) {
      emit(
        state.copyWith(errorMessage: 'Please review your onboarding details.'),
      );
      return;
    }

    emit(state.copyWith(status: OnboardingStatus.saving, clearError: true));

    try {
      final user = UserEntity(
        id: const Uuid().v4(),
        name: state.name.trim(),
        goals: state.goals,
        experienceLevel: state.experienceLevel,
        dailyAvailableMinutes: state.dailyAvailableMinutes,
        preferredStartTime: state.preferredStartTime,
        preferredEndTime: state.preferredEndTime,
        createdAt: DateTime.now(),
      );

      await _repository.saveUser(user);

      await _repository.setOnboardingCompleted(true);

      emit(state.copyWith(status: OnboardingStatus.success));
    } catch (error) {
      emit(
        state.copyWith(
          status: OnboardingStatus.failure,
          errorMessage: 'Unable to save your profile: $error',
        ),
      );
    }
  }
}
