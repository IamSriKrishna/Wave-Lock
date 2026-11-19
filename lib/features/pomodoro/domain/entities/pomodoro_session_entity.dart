import 'package:equatable/equatable.dart';

enum PomodoroSessionType { focus, shortBreak, longBreak }

enum PomodoroSessionStatus { idle, running, paused, completed, cancelled }

class PomodoroSessionEntity extends Equatable {
  final String id;
  final PomodoroSessionType type;
  final PomodoroSessionStatus status;
  final int durationSeconds;
  final int remainingSeconds;
  final DateTime? startedAt;
  final DateTime? endTime;
  final DateTime? completedAt;
  final int completedFocusSessions;

  const PomodoroSessionEntity({
    required this.id,
    required this.type,
    required this.status,
    required this.durationSeconds,
    required this.remainingSeconds,
    this.startedAt,
    this.endTime,
    this.completedAt,
    this.completedFocusSessions = 0,
  });

  bool get isRunning => status == PomodoroSessionStatus.running;

  bool get isFocus => type == PomodoroSessionType.focus;

  double get progress {
    if (durationSeconds <= 0) return 0;

    return (1 - remainingSeconds / durationSeconds).clamp(0.0, 1.0);
  }

  PomodoroSessionEntity copyWith({
    PomodoroSessionType? type,
    PomodoroSessionStatus? status,
    int? durationSeconds,
    int? remainingSeconds,
    DateTime? startedAt,
    DateTime? endTime,
    DateTime? completedAt,
    int? completedFocusSessions,
    bool clearStartedAt = false,
    bool clearEndTime = false,
    bool clearCompletedAt = false,
  }) {
    return PomodoroSessionEntity(
      id: id,
      type: type ?? this.type,
      status: status ?? this.status,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      startedAt: clearStartedAt ? null : startedAt ?? this.startedAt,
      endTime: clearEndTime ? null : endTime ?? this.endTime,
      completedAt: clearCompletedAt ? null : completedAt ?? this.completedAt,
      completedFocusSessions:
          completedFocusSessions ?? this.completedFocusSessions,
    );
  }

  @override
  List<Object?> get props => [
    id,
    type,
    status,
    durationSeconds,
    remainingSeconds,
    startedAt,
    endTime,
    completedAt,
    completedFocusSessions,
  ];
}
