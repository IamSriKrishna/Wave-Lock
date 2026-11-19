import '../entities/pomodoro_session_entity.dart';

abstract class PomodoroRepository {
  Future<void> saveActiveSession(PomodoroSessionEntity session);

  Future<PomodoroSessionEntity?> getActiveSession();

  Future<void> clearActiveSession();

  Future<void> saveCompletedSession(PomodoroSessionEntity session);

  Future<List<PomodoroSessionEntity>> getSessionHistory();
}
