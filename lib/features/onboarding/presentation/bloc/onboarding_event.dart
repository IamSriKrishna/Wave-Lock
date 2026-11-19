import 'package:equatable/equatable.dart';

abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

class NameChanged extends OnboardingEvent {
  final String name;

  const NameChanged(this.name);

  @override
  List<Object?> get props => [name];
}

class GoalsChanged extends OnboardingEvent {
  final List<String> goals;

  const GoalsChanged(this.goals);

  @override
  List<Object?> get props => [goals];
}

class ExperienceChanged extends OnboardingEvent {
  final String experience;

  const ExperienceChanged(this.experience);

  @override
  List<Object?> get props => [experience];
}

class AvailabilityChanged extends OnboardingEvent {
  final int minutes;

  const AvailabilityChanged(this.minutes);

  @override
  List<Object?> get props => [minutes];
}

class WorkingHoursChanged extends OnboardingEvent {
  final String startTime;
  final String endTime;

  const WorkingHoursChanged({required this.startTime, required this.endTime});

  @override
  List<Object?> get props => [startTime, endTime];
}

class NextStepPressed extends OnboardingEvent {}

class PreviousStepPressed extends OnboardingEvent {}

class SubmitOnboarding extends OnboardingEvent {}
