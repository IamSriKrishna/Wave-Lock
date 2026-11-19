import '../entities/mission_entity.dart';

abstract class MissionRepository {
  Future<List<MissionEntity>> getMissionsForDate(String dateKey);

  Future<void> saveDraft(String dateKey, List<MissionEntity> missions);

  Future<void> acceptSelected(String dateKey, List<MissionEntity> missions);

  Future<void> saveMissions(String dateKey, List<MissionEntity> missions);
}
