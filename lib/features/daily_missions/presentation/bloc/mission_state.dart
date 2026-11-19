import 'package:equatable/equatable.dart';

import '../../domain/entities/mission_entity.dart';

enum MissionStatus { initial, loading, ready, accepting, accepted, failure }

class MissionState extends Equatable {
  final MissionStatus status;
  final List<MissionEntity> missions;
  final String? errorMessage;
  final List<String> newlyUnlockedAchievements;
  final DateTime clockNow;

  MissionState({
    this.status = MissionStatus.initial,
    this.missions = const [],
    this.errorMessage,
    this.newlyUnlockedAchievements = const [],
    DateTime? clockNow,
  }) : clockNow = clockNow ?? DateTime.now();

  int get selectedMinutes {
    return missions
        .where((mission) => mission.isSelected)
        .fold(0, (total, mission) => total + mission.durationMinutes);
  }

  int get selectedCount {
    return missions.where((mission) => mission.isSelected).length;
  }

  int get completedCount {
    return missions.where((mission) => mission.status == 'completed').length;
  }

  int get totalCount => missions.length;

  double get completionProgress {
    if (totalCount == 0) return 0;
    return completedCount / totalCount;
  }

  MissionState copyWith({
    MissionStatus? status,
    List<MissionEntity>? missions,
    String? errorMessage,
    DateTime? clockNow,
    List<String>? newlyUnlockedAchievements,

    bool clearNewlyUnlockedAchievements = false,
    bool clearError = false,
  }) {
    return MissionState(
      status: status ?? this.status,
      missions: missions ?? this.missions,
      newlyUnlockedAchievements: clearNewlyUnlockedAchievements
          ? const []
          : newlyUnlockedAchievements ?? this.newlyUnlockedAchievements,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      clockNow: clockNow ?? this.clockNow,
    );
  }

  @override
  List<Object?> get props => [
    status,
    missions,
    errorMessage,
    clockNow,
    newlyUnlockedAchievements,
  ];
}
