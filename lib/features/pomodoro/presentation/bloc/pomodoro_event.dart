import 'package:equatable/equatable.dart';

import '../../domain/entities/pomodoro_session_entity.dart';
import '../../domain/entities/pomodoro_settings_entity.dart';

abstract class PomodoroEvent extends Equatable {
  const PomodoroEvent();

  @override
  List<Object?> get props => [];
}

class LoadPomodoro extends PomodoroEvent {
  const LoadPomodoro();
}

class StartPomodoro extends PomodoroEvent {
  const StartPomodoro();
}

class PausePomodoro extends PomodoroEvent {
  const PausePomodoro();
}

class ResumePomodoro extends PomodoroEvent {
  const ResumePomodoro();
}

class ResetPomodoro extends PomodoroEvent {
  const ResetPomodoro();
}

class SelectPomodoroType extends PomodoroEvent {
  final PomodoroSessionType type;

  const SelectPomodoroType(this.type);

  @override
  List<Object?> get props => [type];
}

class UpdatePomodoroSettings extends PomodoroEvent {
  final PomodoroSettingsEntity settings;

  const UpdatePomodoroSettings(this.settings);

  @override
  List<Object?> get props => [settings];
}

class PomodoroTick extends PomodoroEvent {
  const PomodoroTick();
}
