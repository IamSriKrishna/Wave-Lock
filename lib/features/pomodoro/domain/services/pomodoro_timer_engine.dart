import '../entities/pomodoro_session_entity.dart';
import '../entities/pomodoro_settings_entity.dart';

class PomodoroTimerEngine {
  PomodoroSessionEntity createSession({
    required String id,
    required PomodoroSessionType type,
    required PomodoroSettingsEntity settings,
    int completedFocusSessions = 0,
  }) {
    final durationSeconds = switch (type) {
      PomodoroSessionType.focus => settings.focusDurationSeconds,
      PomodoroSessionType.shortBreak => settings.shortBreakDurationSeconds,
      PomodoroSessionType.longBreak => settings.longBreakDurationSeconds,
    };

    return PomodoroSessionEntity(
      id: id,
      type: type,
      status: PomodoroSessionStatus.idle,
      durationSeconds: durationSeconds,
      remainingSeconds: durationSeconds,
      completedFocusSessions: completedFocusSessions,
    );
  }

  PomodoroSessionEntity start(
    PomodoroSessionEntity session, {
    DateTime? referenceTime,
  }) {
    final now = referenceTime ?? DateTime.now();

    if (session.status == PomodoroSessionStatus.completed ||
        session.status == PomodoroSessionStatus.cancelled) {
      return session;
    }

    if (session.status == PomodoroSessionStatus.running) {
      return session;
    }

    return session.copyWith(
      status: PomodoroSessionStatus.running,
      startedAt: session.startedAt ?? now,
      endTime: now.add(Duration(seconds: session.remainingSeconds)),
      clearCompletedAt: true,
    );
  }

  PomodoroSessionEntity pause(
    PomodoroSessionEntity session, {
    DateTime? referenceTime,
  }) {
    if (session.status != PomodoroSessionStatus.running) {
      return session;
    }

    final remaining = remainingSeconds(session, referenceTime: referenceTime);

    return session.copyWith(
      status: PomodoroSessionStatus.paused,
      remainingSeconds: remaining,
      clearEndTime: true,
    );
  }

  PomodoroSessionEntity resume(
    PomodoroSessionEntity session, {
    DateTime? referenceTime,
  }) {
    return start(session, referenceTime: referenceTime);
  }

  PomodoroSessionEntity reset(PomodoroSessionEntity session) {
    return PomodoroSessionEntity(
      id: session.id,
      type: session.type,
      status: PomodoroSessionStatus.idle,
      durationSeconds: session.durationSeconds,
      remainingSeconds: session.durationSeconds,
      completedFocusSessions: session.completedFocusSessions,
    );
  }

  PomodoroSessionEntity complete(
    PomodoroSessionEntity session, {
    DateTime? referenceTime,
  }) {
    if (session.status != PomodoroSessionStatus.running) {
      return session;
    }

    return session.copyWith(
      status: PomodoroSessionStatus.completed,
      remainingSeconds: 0,
      completedAt: referenceTime ?? DateTime.now(),
      clearEndTime: true,
    );
  }

  int remainingSeconds(
    PomodoroSessionEntity session, {
    DateTime? referenceTime,
  }) {
    if (session.status == PomodoroSessionStatus.completed) {
      return 0;
    }

    if (session.status != PomodoroSessionStatus.running ||
        session.endTime == null) {
      return session.remainingSeconds;
    }

    final now = referenceTime ?? DateTime.now();

    final remaining = session.endTime!.difference(now).inSeconds;

    return remaining.clamp(0, session.durationSeconds);
  }

  bool isExpired(PomodoroSessionEntity session, {DateTime? referenceTime}) {
    if (session.status != PomodoroSessionStatus.running ||
        session.endTime == null) {
      return false;
    }

    final now = referenceTime ?? DateTime.now();

    return !now.isBefore(session.endTime!);
  }

  bool shouldUseLongBreak({
    required int completedFocusSessions,
    required PomodoroSettingsEntity settings,
  }) {
    return completedFocusSessions > 0 &&
        completedFocusSessions % settings.sessionsBeforeLongBreak == 0;
  }
}
