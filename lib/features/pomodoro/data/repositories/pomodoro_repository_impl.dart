import 'package:sembast/sembast.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_stores.dart';
import '../../domain/entities/pomodoro_session_entity.dart';
import '../../domain/repositories/pomodoro_repository.dart';
import '../models/pomodoro_session_model.dart';

class PomodoroRepositoryImpl implements PomodoroRepository {
  final AppDatabase appDatabase;

  PomodoroRepositoryImpl(this.appDatabase);

  static const String activeSessionKey = 'active_pomodoro_session';

  @override
  Future<void> saveActiveSession(PomodoroSessionEntity session) async {
    final database = await appDatabase.database;

    await DatabaseStores.pomodoro
        .record(activeSessionKey)
        .put(database, PomodoroSessionModel.fromEntity(session).toMap());
  }

  @override
  Future<PomodoroSessionEntity?> getActiveSession() async {
    final database = await appDatabase.database;

    final data = await DatabaseStores.pomodoro
        .record(activeSessionKey)
        .get(database);

    if (data == null) return null;

    return PomodoroSessionModel.fromMap(data);
  }

  @override
  Future<void> clearActiveSession() async {
    final database = await appDatabase.database;

    await DatabaseStores.pomodoro.record(activeSessionKey).delete(database);
  }

  @override
  Future<void> saveCompletedSession(PomodoroSessionEntity session) async {
    final database = await appDatabase.database;

    await DatabaseStores.pomodoro
        .record('history_${session.id}')
        .put(database, PomodoroSessionModel.fromEntity(session).toMap());
  }

  @override
  Future<List<PomodoroSessionEntity>> getSessionHistory() async {
    final database = await appDatabase.database;

    final records = await DatabaseStores.pomodoro.find(database);

    return records
        .where((record) => record.key.toString().startsWith('history_'))
        .map((record) => PomodoroSessionModel.fromMap(record.value))
        .toList()
      ..sort((a, b) {
        final aDate = a.completedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.completedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });
  }
}
