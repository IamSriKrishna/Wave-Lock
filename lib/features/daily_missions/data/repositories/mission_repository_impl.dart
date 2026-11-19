import 'package:sembast/sembast.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_stores.dart';
import '../../domain/entities/mission_entity.dart';
import '../../domain/repositories/mission_repository.dart';
import '../models/mission_model.dart';

class MissionRepositoryImpl implements MissionRepository {
  final AppDatabase appDatabase;

  MissionRepositoryImpl({required this.appDatabase});

  @override
  Future<List<MissionEntity>> getMissionsForDate(String dateKey) async {
    final database = await appDatabase.database;

    final data = await DatabaseStores.dailyTasks.record(dateKey).get(database);

    if (data == null) return [];

    final rawMissions = data['missions'] as List<dynamic>? ?? [];

    return rawMissions.map((item) {
      return MissionModel.fromMap(Map<String, dynamic>.from(item as Map));
    }).toList();
  }

  @override
  Future<void> saveDraft(String dateKey, List<MissionEntity> missions) async {
    final database = await appDatabase.database;

    final models = missions.map(MissionModel.fromEntity).toList();

    await DatabaseStores.dailyTasks.record(dateKey).put(database, {
      'date_key': dateKey,
      'missions': models.map((mission) => mission.toMap()).toList(),
    });
  }

  @override
  Future<void> acceptSelected(
    String dateKey,
    List<MissionEntity> missions,
  ) async {
    final database = await appDatabase.database;

    final accepted = missions
        .where((mission) => mission.isSelected)
        .map(
          (mission) =>
              MissionModel.fromEntity(mission.copyWith(status: 'accepted')),
        )
        .toList();

    await DatabaseStores.dailyTasks.record(dateKey).put(database, {
      'date_key': dateKey,
      'missions': accepted.map((mission) => mission.toMap()).toList(),
    });
  }

  @override
  Future<void> saveMissions(
    String dateKey,
    List<MissionEntity> missions,
  ) async {
    final database = await appDatabase.database;

    final models = missions.map(MissionModel.fromEntity).toList();

    await DatabaseStores.dailyTasks.record(dateKey).put(database, {
      'date_key': dateKey,
      'missions': models.map((mission) => mission.toMap()).toList(),
    });
  }
}
