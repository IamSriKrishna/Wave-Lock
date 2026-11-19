import 'package:equatable/equatable.dart';

enum OnboardingStatus { initial, saving, success, failure }

class OnboardingState extends Equatable {
  final String name;
  final List<String> goals;
  final String experienceLevel;
  final int dailyAvailableMinutes;
  final String preferredStartTime;
  final String preferredEndTime;

  final int currentStep;
  final OnboardingStatus status;
  final String? errorMessage;

  const OnboardingState({
    this.name = '',
    this.goals = const [],
    this.experienceLevel = 'beginner',
    this.dailyAvailableMinutes = 120,
    this.preferredStartTime = '09:00',
    this.preferredEndTime = '18:00',
    this.currentStep = 0,
    this.status = OnboardingStatus.initial,
    this.errorMessage,
  });

  OnboardingState copyWith({
    String? name,
    List<String>? goals,
    String? experienceLevel,
    int? dailyAvailableMinutes,
    String? preferredStartTime,
    String? preferredEndTime,
    int? currentStep,
    OnboardingStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return OnboardingState(
      name: name ?? this.name,
      goals: goals ?? this.goals,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      dailyAvailableMinutes:
          dailyAvailableMinutes ?? this.dailyAvailableMinutes,
      preferredStartTime: preferredStartTime ?? this.preferredStartTime,
      preferredEndTime: preferredEndTime ?? this.preferredEndTime,
      currentStep: currentStep ?? this.currentStep,
      status: status ?? this.status,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    name,
    goals,
    experienceLevel,
    dailyAvailableMinutes,
    preferredStartTime,
    preferredEndTime,
    currentStep,
    status,
    errorMessage,
  ];
}
