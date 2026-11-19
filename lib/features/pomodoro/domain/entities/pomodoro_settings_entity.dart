import 'package:equatable/equatable.dart';

class PomodoroSettingsEntity extends Equatable {
  final int focusDurationMinutes;
  final int shortBreakMinutes;
  final int longBreakMinutes;
  final int sessionsBeforeLongBreak;
  final bool autoStartBreaks;
  final bool autoStartFocus;

  const PomodoroSettingsEntity({
    this.focusDurationMinutes = 25,
    this.shortBreakMinutes = 5,
    this.longBreakMinutes = 15,
    this.sessionsBeforeLongBreak = 4,
    this.autoStartBreaks = false,
    this.autoStartFocus = false,
  });

  int get focusDurationSeconds => focusDurationMinutes * 60;

  int get shortBreakDurationSeconds => shortBreakMinutes * 60;

  int get longBreakDurationSeconds => longBreakMinutes * 60;

  PomodoroSettingsEntity copyWith({
    int? focusDurationMinutes,
    int? shortBreakMinutes,
    int? longBreakMinutes,
    int? sessionsBeforeLongBreak,
    bool? autoStartBreaks,
    bool? autoStartFocus,
  }) {
    return PomodoroSettingsEntity(
      focusDurationMinutes: focusDurationMinutes ?? this.focusDurationMinutes,
      shortBreakMinutes: shortBreakMinutes ?? this.shortBreakMinutes,
      longBreakMinutes: longBreakMinutes ?? this.longBreakMinutes,
      sessionsBeforeLongBreak:
          sessionsBeforeLongBreak ?? this.sessionsBeforeLongBreak,
      autoStartBreaks: autoStartBreaks ?? this.autoStartBreaks,
      autoStartFocus: autoStartFocus ?? this.autoStartFocus,
    );
  }

  @override
  List<Object?> get props => [
    focusDurationMinutes,
    shortBreakMinutes,
    longBreakMinutes,
    sessionsBeforeLongBreak,
    autoStartBreaks,
    autoStartFocus,
  ];
}
