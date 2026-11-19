import '../entities/user_progress_entity.dart';

abstract class ProgressRepository {
  Future<UserProgressEntity> getProgress();

  Future<void> saveProgress(UserProgressEntity progress);
}
