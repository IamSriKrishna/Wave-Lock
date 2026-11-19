import '../../domain/entities/user_progress_entity.dart';

enum GamificationStatus { initial, loading, loaded, failure }

class GamificationState {
  final GamificationStatus status;
  final UserProgressEntity progress;
  final String? errorMessage;

  const GamificationState({
    this.status = GamificationStatus.initial,
    this.progress = const UserProgressEntity(),
    this.errorMessage,
  });

  GamificationState copyWith({
    GamificationStatus? status,
    UserProgressEntity? progress,
    String? errorMessage,
  }) {
    return GamificationState(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      errorMessage: errorMessage,
    );
  }
}
