import '../../domain/entities/pomodoro_settings_entity.dart';

class PomodoroSettingsModel extends PomodoroSettingsEntity {
  const PomodoroSettingsModel({
    super.focusDurationMinutes,
    super.shortBreakMinutes,
    super.longBreakMinutes,
    super.sessionsBeforeLongBreak,
    super.autoStartBreaks,
    super.autoStartFocus,
  });

  factory PomodoroSettingsModel.fromMap(Map<String, dynamic> map) {
    return PomodoroSettingsModel(
      focusDurationMinutes: map['focus_duration_minutes'] ?? 25,
      shortBreakMinutes: map['short_break_minutes'] ?? 5,
      longBreakMinutes: map['long_break_minutes'] ?? 15,
      sessionsBeforeLongBreak: map['sessions_before_long_break'] ?? 4,
      autoStartBreaks: map['auto_start_breaks'] ?? false,
      autoStartFocus: map['auto_start_focus'] ?? false,
    );
  }

  factory PomodoroSettingsModel.fromEntity(PomodoroSettingsEntity entity) {
    return PomodoroSettingsModel(
      focusDurationMinutes: entity.focusDurationMinutes,
      shortBreakMinutes: entity.shortBreakMinutes,
      longBreakMinutes: entity.longBreakMinutes,
      sessionsBeforeLongBreak: entity.sessionsBeforeLongBreak,
      autoStartBreaks: entity.autoStartBreaks,
      autoStartFocus: entity.autoStartFocus,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'focus_duration_minutes': focusDurationMinutes,
      'short_break_minutes': shortBreakMinutes,
      'long_break_minutes': longBreakMinutes,
      'sessions_before_long_break': sessionsBeforeLongBreak,
      'auto_start_breaks': autoStartBreaks,
      'auto_start_focus': autoStartFocus,
    };
  }
}
