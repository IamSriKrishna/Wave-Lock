import 'package:sembast/sembast.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_stores.dart';
import '../../domain/entities/user_progress_entity.dart';
import '../../domain/repositories/progress_repository.dart';
import '../models/user_progress_model.dart';

class ProgressRepositoryImpl implements ProgressRepository {
  final AppDatabase appDatabase;

  ProgressRepositoryImpl(this.appDatabase);

  static const String _progressKey = 'current_user_progress';

  @override
  Future<UserProgressEntity> getProgress() async {
    final database = await appDatabase.database;

    final data = await DatabaseStores.gamification
        .record(_progressKey)
        .get(database);

    if (data == null) {
      return const UserProgressEntity();
    }

    return UserProgressModel.fromMap(data);
  }

  @override
  Future<void> saveProgress(UserProgressEntity progress) async {
    final database = await appDatabase.database;

    final model = UserProgressModel.fromEntity(progress);

    await DatabaseStores.gamification
        .record(_progressKey)
        .put(database, model.toMap());
  }
}
