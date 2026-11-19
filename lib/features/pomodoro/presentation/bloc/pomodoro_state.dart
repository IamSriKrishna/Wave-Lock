import 'package:equatable/equatable.dart';

import '../../domain/entities/pomodoro_session_entity.dart';
import '../../domain/entities/pomodoro_settings_entity.dart';

enum PomodoroStatus { initial, loading, ready, failure }

class PomodoroState extends Equatable {
  final PomodoroStatus status;
  final PomodoroSessionEntity? session;
  final PomodoroSettingsEntity settings;
  final List<PomodoroSessionEntity> history;
  final String? errorMessage;

  const PomodoroState({
    this.status = PomodoroStatus.initial,
    this.session,
    this.settings = const PomodoroSettingsEntity(),
    this.history = const [],
    this.errorMessage,
  });

  int get remainingSeconds => session?.remainingSeconds ?? 0;

  bool get isRunning => session?.status == PomodoroSessionStatus.running;

  bool get isPaused => session?.status == PomodoroSessionStatus.paused;

  PomodoroState copyWith({
    PomodoroStatus? status,
    PomodoroSessionEntity? session,
    PomodoroSettingsEntity? settings,
    List<PomodoroSessionEntity>? history,
    String? errorMessage,
    bool clearSession = false,
    bool clearError = false,
  }) {
    return PomodoroState(
      status: status ?? this.status,
      session: clearSession ? null : session ?? this.session,
      settings: settings ?? this.settings,
      history: history ?? this.history,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, session, settings, history, errorMessage];
}
