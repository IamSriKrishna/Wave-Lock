import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakelock/features/gamification/domain/repositories/progress_repository.dart';
import 'package:wakelock/features/gamification/domain/services/achievement_engine.dart';
import 'package:wakelock/features/gamification/domain/services/progress_reward_engine.dart';

import '../../../../core/services/strict_mode_service.dart';
import '../../../../features/onboarding/domain/repositories/user_repository.dart';
import '../../../strict_mode/domain/repositories/strict_mode_repository.dart';
import '../../../strict_mode/domain/services/strict_mode_management_service.dart';
import '../../domain/entities/mission_entity.dart';
import '../../domain/repositories/mission_repository.dart';
import '../../domain/services/mission_recommendation_engine.dart';
import 'mission_event.dart';
import 'mission_state.dart';

class MissionBloc extends Bloc<MissionEvent, MissionState> {
  final UserRepository userRepository;
  final MissionRepository missionRepository;
  final MissionRecommendationEngine recommendationEngine;
  final ProgressRepository progressRepository;
  final ProgressRewardEngine rewardEngine;
  final AchievementEngine achievementEngine;
  final StrictModeRepository strictModeRepository;
  final StrictModeManagementService strictModeManagementService;
  final StrictModeService strictModeService;

  Timer? _clockTimer;

  MissionBloc({
    required this.userRepository,
    required this.missionRepository,
    required this.achievementEngine,
    required this.recommendationEngine,
    required this.progressRepository,
    required this.rewardEngine,
    required this.strictModeRepository,
    required this.strictModeManagementService,
    required this.strictModeService,
  }) : super(MissionState()) {
    on<LoadDailyMissions>(_onLoad);
    on<ToggleMissionSelection>(_onToggle);
    on<RegenerateMissions>(_onRegenerate);
    on<AcceptMissions>(_onAccept);
    on<StartMission>(_onStart);
    on<PauseMission>(_onPause);
    on<ResumeMission>(_onResume);
    on<CompleteMission>(_onComplete);
    on<MissionClockTick>(_onClockTick);
    on<ClearNewlyUnlockedAchievements>((event, emit) {
      emit(
        state.copyWith(
          clearNewlyUnlockedAchievements: true,
          clearMotivationalPrompts: true,
        ),
      );
    });
  }

  String get _todayKey {
    final now = DateTime.now();
    final year = now.year.toString().padLeft(4, '0');
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  Future<void> _onLoad(
    LoadDailyMissions event,
    Emitter<MissionState> emit,
  ) async {
    emit(state.copyWith(status: MissionStatus.loading, clearError: true));

    try {
      final saved = await missionRepository.getMissionsForDate(_todayKey);

      if (saved.isNotEmpty) {
        await _releaseStrictModeForCompletedMission(saved);

        final allAccepted = saved.every(
          (mission) => mission.status == 'accepted',
        );

        emit(
          MissionState(
            status: allAccepted ? MissionStatus.accepted : MissionStatus.ready,
            missions: saved,
          ),
        );

        _syncClockTimer();
        return;
      }

      final user = await userRepository.getUser();

      if (user == null) {
        throw Exception('User profile not found.');
      }

      final missions = recommendationEngine.generate(user);

      if (missions.isEmpty) {
        throw Exception('No missions could be generated.');
      }

      await missionRepository.saveDraft(_todayKey, missions);

      emit(MissionState(status: MissionStatus.ready, missions: missions));
    } catch (error) {
      emit(
        MissionState(
          status: MissionStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onToggle(
    ToggleMissionSelection event,
    Emitter<MissionState> emit,
  ) async {
    // Selection is only allowed while missions are still drafts.
    if (state.missions.any((mission) => mission.status != 'draft')) {
      return;
    }

    final updated = state.missions.map((mission) {
      if (mission.id == event.missionId) {
        return mission.copyWith(isSelected: !mission.isSelected);
      }
      return mission;
    }).toList();

    emit(state.copyWith(missions: updated, clearError: true));

    await missionRepository.saveDraft(_todayKey, updated);
  }

  Future<void> _onRegenerate(
    RegenerateMissions event,
    Emitter<MissionState> emit,
  ) async {
    if (state.missions.any((mission) => mission.status != 'draft')) {
      return;
    }

    emit(state.copyWith(status: MissionStatus.loading, clearError: true));

    try {
      final user = await userRepository.getUser();

      if (user == null) {
        throw Exception('User profile not found.');
      }

      final missions = recommendationEngine.generate(user);

      if (missions.isEmpty) {
        throw Exception('Unable to generate missions.');
      }

      await missionRepository.saveDraft(_todayKey, missions);

      emit(MissionState(status: MissionStatus.ready, missions: missions));
    } catch (error) {
      emit(
        MissionState(
          status: MissionStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onAccept(
    AcceptMissions event,
    Emitter<MissionState> emit,
  ) async {
    if (state.missions.any((mission) => mission.status != 'draft')) {
      return;
    }

    final selected = state.missions
        .where((mission) => mission.isSelected)
        .toList();

    if (selected.isEmpty) {
      emit(state.copyWith(errorMessage: 'Select at least one mission.'));
      return;
    }

    emit(state.copyWith(status: MissionStatus.accepting, clearError: true));

    try {
      await missionRepository.acceptSelected(_todayKey, selected);

      final accepted = selected
          .map((mission) => mission.copyWith(status: 'accepted'))
          .toList();

      emit(MissionState(status: MissionStatus.accepted, missions: accepted));
    } catch (error) {
      emit(
        state.copyWith(
          status: MissionStatus.ready,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onStart(StartMission event, Emitter<MissionState> emit) async {
    await _changeMission(event.missionId, emit, (mission) {
      if (mission.status != 'accepted') return mission;

      return mission.copyWith(status: 'inProgress', startedAt: DateTime.now());
    }, startedMissionId: event.missionId);
  }

  Future<void> _onPause(PauseMission event, Emitter<MissionState> emit) async {
    final now = DateTime.now();

    await _changeMission(event.missionId, emit, (mission) {
      if (mission.status != 'inProgress') return mission;

      return mission.copyWith(
        status: 'paused',
        elapsedSeconds: mission.elapsedAt(now),
        clearStartedAt: true,
      );
    });
  }

  Future<void> _onResume(
    ResumeMission event,
    Emitter<MissionState> emit,
  ) async {
    await _changeMission(event.missionId, emit, (mission) {
      if (mission.status != 'paused') return mission;

      return mission.copyWith(status: 'inProgress', startedAt: DateTime.now());
    }, startedMissionId: event.missionId);
  }

  Future<void> _onComplete(
    CompleteMission event,
    Emitter<MissionState> emit,
  ) async {
    final mission = state.missions.firstWhere(
      (item) => item.id == event.missionId,
      orElse: () => throw StateError('Mission not found'),
    );

    // Ignore duplicate completion events.
    if (mission.status == 'completed') return;

    if (mission.status != 'inProgress' && mission.status != 'paused') {
      return;
    }

    final now = DateTime.now();

    final completedMission = mission.copyWith(
      status: 'completed',
      elapsedSeconds: mission.status == 'inProgress'
          ? mission.elapsedAt(now)
          : mission.elapsedSeconds,
      clearStartedAt: true,
      completedAt: now,
    );

    // Update mission first.
    final updatedMissions = state.missions.map((item) {
      return item.id == event.missionId ? completedMission : item;
    }).toList();

    await missionRepository.saveMissions(_todayKey, updatedMissions);
    await _releaseStrictModeForCompletedMission(updatedMissions);

    // Calculate and save XP + streak.
    final currentProgress = await progressRepository.getProgress();

    final updatedProgress = rewardEngine.rewardMission(
      progress: currentProgress,
      missionId: completedMission.id,
      difficulty: completedMission.difficulty,
      completedAt: now,
    );

    final newlyUnlocked = achievementEngine.checkAchievements(
      progress: updatedProgress,
    );

    final bonusXp = newlyUnlocked.fold<int>(0, (total, id) {
      final achievement = AchievementEngine.achievements.firstWhere(
        (item) => item.id == id,
      );

      return total + achievement.bonusXp;
    });

    final finalProgress = updatedProgress.copyWith(
      totalXp: updatedProgress.totalXp + bonusXp,
      unlockedAchievements: [
        ...updatedProgress.unlockedAchievements,
        ...newlyUnlocked,
      ],
    );

    await progressRepository.saveProgress(finalProgress);

    emit(
      state.copyWith(
        missions: updatedMissions,
        clockNow: now,
        newlyUnlockedAchievements: newlyUnlocked,
        completedMissionId: completedMission.id,
      ),
    );

    _syncClockTimer();
  }

  Future<void> _changeMission(
    String missionId,
    Emitter<MissionState> emit,
    MissionEntity Function(MissionEntity) update, {
    String? startedMissionId,
  }) async {
    final updated = state.missions.map((mission) {
      if (mission.id == missionId) {
        return update(mission);
      }
      return mission;
    }).toList();

    try {
      await missionRepository.saveMissions(_todayKey, updated);

      emit(
        state.copyWith(
          missions: updated,
          status: MissionStatus.ready,
          clockNow: DateTime.now(),
          startedMissionId: startedMissionId,
          clearError: true,
        ),
      );

      _syncClockTimer();
    } catch (error) {
      emit(state.copyWith(errorMessage: error.toString()));
    }
  }

  void _syncClockTimer() {
    final hasRunningMission = state.missions.any(
      (mission) => mission.status == 'inProgress',
    );

    if (hasRunningMission && (_clockTimer?.isActive != true)) {
      _clockTimer = Timer.periodic(
        const Duration(seconds: 1),
        (_) => add(const MissionClockTick()),
      );
    } else if (!hasRunningMission) {
      _clockTimer?.cancel();
      _clockTimer = null;
    }
  }

  void _onClockTick(MissionClockTick event, Emitter<MissionState> emit) {
    emit(state.copyWith(clockNow: DateTime.now()));
  }

  Future<void> _releaseStrictModeForCompletedMission(
    List<MissionEntity> missions,
  ) async {
    final settings = await strictModeRepository.getSettings();
    if (settings == null || !settings.isActive) return;

    final linkedMission = missions.where(
      (mission) => mission.id == settings.linkedMissionId,
    );
    if (linkedMission.isEmpty || linkedMission.first.status != 'completed') {
      return;
    }

    await strictModeManagementService.completeStrictMode(settings);
    await strictModeService.setMissionActive(active: false);
  }

  @override
  Future<void> close() {
    _clockTimer?.cancel();
    return super.close();
  }
}
