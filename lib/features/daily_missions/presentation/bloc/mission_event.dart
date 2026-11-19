import 'package:equatable/equatable.dart';

abstract class MissionEvent extends Equatable {
  const MissionEvent();

  @override
  List<Object?> get props => [];
}

class LoadDailyMissions extends MissionEvent {
  const LoadDailyMissions();
}

class ToggleMissionSelection extends MissionEvent {
  final String missionId;

  const ToggleMissionSelection(this.missionId);

  @override
  List<Object?> get props => [missionId];
}

class RegenerateMissions extends MissionEvent {
  const RegenerateMissions();
}

class AcceptMissions extends MissionEvent {
  const AcceptMissions();
}

class StartMission extends MissionEvent {
  final String missionId;

  const StartMission(this.missionId);

  @override
  List<Object?> get props => [missionId];
}

class PauseMission extends MissionEvent {
  final String missionId;

  const PauseMission(this.missionId);

  @override
  List<Object?> get props => [missionId];
}

class ResumeMission extends MissionEvent {
  final String missionId;

  const ResumeMission(this.missionId);

  @override
  List<Object?> get props => [missionId];
}

class CompleteMission extends MissionEvent {
  final String missionId;

  const CompleteMission(this.missionId);

  @override
  List<Object?> get props => [missionId];
}

class MissionClockTick extends MissionEvent {
  const MissionClockTick();
}

class ClearNewlyUnlockedAchievements extends MissionEvent {
  const ClearNewlyUnlockedAchievements();
}
