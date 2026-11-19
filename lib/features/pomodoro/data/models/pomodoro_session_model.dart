import '../../domain/entities/pomodoro_session_entity.dart';

class PomodoroSessionModel extends PomodoroSessionEntity {
  const PomodoroSessionModel({
    required super.id,
    required super.type,
    required super.status,
    required super.durationSeconds,
    required super.remainingSeconds,
    super.startedAt,
    super.endTime,
    super.completedAt,
    super.completedFocusSessions,
  });

  factory PomodoroSessionModel.fromMap(Map<String, dynamic> map) {
    return PomodoroSessionModel(
      id: map['id'],
      type: PomodoroSessionType.values.firstWhere(
        (value) => value.name == map['type'],
        orElse: () => PomodoroSessionType.focus,
      ),
      status: PomodoroSessionStatus.values.firstWhere(
        (value) => value.name == map['status'],
        orElse: () => PomodoroSessionStatus.idle,
      ),
      durationSeconds: map['duration_seconds'] ?? 1500,
      remainingSeconds: map['remaining_seconds'] ?? 1500,
      startedAt: map['started_at'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(map['started_at']),
      endTime: map['end_time'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(map['end_time']),
      completedAt: map['completed_at'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(map['completed_at']),
      completedFocusSessions: map['completed_focus_sessions'] ?? 0,
    );
  }

  factory PomodoroSessionModel.fromEntity(PomodoroSessionEntity entity) {
    return PomodoroSessionModel(
      id: entity.id,
      type: entity.type,
      status: entity.status,
      durationSeconds: entity.durationSeconds,
      remainingSeconds: entity.remainingSeconds,
      startedAt: entity.startedAt,
      endTime: entity.endTime,
      completedAt: entity.completedAt,
      completedFocusSessions: entity.completedFocusSessions,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'status': status.name,
      'duration_seconds': durationSeconds,
      'remaining_seconds': remainingSeconds,
      'started_at': startedAt?.millisecondsSinceEpoch,
      'end_time': endTime?.millisecondsSinceEpoch,
      'completed_at': completedAt?.millisecondsSinceEpoch,
      'completed_focus_sessions': completedFocusSessions,
    };
  }
}
