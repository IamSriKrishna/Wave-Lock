import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/services/strict_mode_service.dart';
import '../../domain/entities/pomodoro_session_entity.dart';
import '../../domain/entities/pomodoro_settings_entity.dart';
import '../../domain/repositories/pomodoro_repository.dart';
import '../../domain/repositories/pomodoro_settings_repository.dart';
import '../../domain/services/pomodoro_timer_engine.dart';
import 'pomodoro_event.dart';
import 'pomodoro_state.dart';

class PomodoroBloc extends Bloc<PomodoroEvent, PomodoroState> {
  final PomodoroRepository repository;
  final PomodoroSettingsRepository settingsRepository;
  final PomodoroTimerEngine timerEngine;
  final StrictModeService strictModeService;

  final Uuid _uuid = const Uuid();

  Timer? _ticker;

  PomodoroBloc({
    required this.repository,
    required this.settingsRepository,
    required this.timerEngine,
    required this.strictModeService,
  }) : super(const PomodoroState()) {
    on<LoadPomodoro>(_onLoad);
    on<StartPomodoro>(_onStart);
    on<PausePomodoro>(_onPause);
    on<ResumePomodoro>(_onResume);
    on<ResetPomodoro>(_onReset);
    on<SelectPomodoroType>(_onSelectType);
    on<UpdatePomodoroSettings>(_onUpdateSettings);
    on<PomodoroTick>(_onTick);
  }

  Future<void> _onLoad(LoadPomodoro event, Emitter<PomodoroState> emit) async {
    emit(state.copyWith(status: PomodoroStatus.loading));

    try {
      final settings = await settingsRepository.getSettings();
      final savedSession = await repository.getActiveSession();
      // final history = await repository.getSessionHistory();

      var session = savedSession;

      if (session != null && session.status == PomodoroSessionStatus.running) {
        if (timerEngine.isExpired(session)) {
          session = timerEngine.complete(session);

          await _saveCompletedSession(session);
          session = _createNextSession(session, settings);
        } else {
          session = session.copyWith(
            remainingSeconds: timerEngine.remainingSeconds(session),
          );
        }
      }

      session ??= _createSession(PomodoroSessionType.focus, settings);

      await repository.saveActiveSession(session);
      await _syncStrictMode(session);

      emit(
        state.copyWith(
          status: PomodoroStatus.ready,
          session: session,
          settings: settings,
          history: await repository.getSessionHistory(),
          clearError: true,
        ),
      );

      if (session.isRunning) {
        _startTicker();
      }
    } catch (error) {
      emit(
        state.copyWith(
          status: PomodoroStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onStart(
    StartPomodoro event,
    Emitter<PomodoroState> emit,
  ) async {
    final current = state.session;
    if (current == null) return;

    final session = timerEngine.start(current);

    await repository.saveActiveSession(session);
    await _syncStrictMode(session);

    emit(state.copyWith(session: session, clearError: true));
    _startTicker();
  }

  Future<void> _onPause(
    PausePomodoro event,
    Emitter<PomodoroState> emit,
  ) async {
    final current = state.session;
    if (current == null) return;

    _cancelTicker();

    final session = timerEngine.pause(current);

    await repository.saveActiveSession(session);
    await _syncStrictMode(session);

    emit(state.copyWith(session: session));
  }

  Future<void> _onResume(
    ResumePomodoro event,
    Emitter<PomodoroState> emit,
  ) async {
    final current = state.session;
    if (current == null) return;

    final session = timerEngine.resume(current);

    await repository.saveActiveSession(session);
    await _syncStrictMode(session);

    emit(state.copyWith(session: session));
    _startTicker();
  }

  Future<void> _onReset(
    ResetPomodoro event,
    Emitter<PomodoroState> emit,
  ) async {
    _cancelTicker();

    final current = state.session;
    if (current == null) return;

    final session = timerEngine.reset(current);

    await repository.saveActiveSession(session);
    await _syncStrictMode(session);

    emit(state.copyWith(session: session));
  }

  Future<void> _onSelectType(
    SelectPomodoroType event,
    Emitter<PomodoroState> emit,
  ) async {
    _cancelTicker();

    final session = _createSession(
      event.type,
      state.settings,
      completedFocusSessions: state.session?.completedFocusSessions ?? 0,
    );

    await repository.saveActiveSession(session);
    await _syncStrictMode(session);

    emit(state.copyWith(session: session));
  }

  Future<void> _onUpdateSettings(
    UpdatePomodoroSettings event,
    Emitter<PomodoroState> emit,
  ) async {
    await settingsRepository.saveSettings(event.settings);

    var session = state.session;

    if (session != null && session.status == PomodoroSessionStatus.idle) {
      session = timerEngine.createSession(
        id: session.id,
        type: session.type,
        settings: event.settings,
        completedFocusSessions: session.completedFocusSessions,
      );

      await repository.saveActiveSession(session);
    }

    emit(state.copyWith(settings: event.settings, session: session));
  }

  Future<void> _onTick(PomodoroTick event, Emitter<PomodoroState> emit) async {
    final current = state.session;

    if (current == null || current.status != PomodoroSessionStatus.running) {
      _cancelTicker();
      return;
    }

    if (timerEngine.isExpired(current)) {
      _cancelTicker();

      final completed = timerEngine.complete(current);

      await _saveCompletedSession(completed);

      final nextSession = _createNextSession(completed, state.settings);

      await repository.saveActiveSession(nextSession);
      await _syncStrictMode(nextSession);

      emit(
        state.copyWith(
          session: nextSession,
          history: await repository.getSessionHistory(),
        ),
      );

      return;
    }

    final updated = current.copyWith(
      remainingSeconds: timerEngine.remainingSeconds(current),
    );

    emit(state.copyWith(session: updated));
  }

  PomodoroSessionEntity _createSession(
    PomodoroSessionType type,
    PomodoroSettingsEntity settings, {
    int completedFocusSessions = 0,
  }) {
    return timerEngine.createSession(
      id: _uuid.v4(),
      type: type,
      settings: settings,
      completedFocusSessions: completedFocusSessions,
    );
  }

  PomodoroSessionEntity _createNextSession(
    PomodoroSessionEntity completed,
    PomodoroSettingsEntity settings,
  ) {
    var completedFocusSessions = completed.completedFocusSessions;

    if (completed.type == PomodoroSessionType.focus) {
      completedFocusSessions++;
    }

    final nextType = switch (completed.type) {
      PomodoroSessionType.focus =>
        timerEngine.shouldUseLongBreak(
              completedFocusSessions: completedFocusSessions,
              settings: settings,
            )
            ? PomodoroSessionType.longBreak
            : PomodoroSessionType.shortBreak,
      PomodoroSessionType.shortBreak ||
      PomodoroSessionType.longBreak => PomodoroSessionType.focus,
    };

    return _createSession(
      nextType,
      settings,
      completedFocusSessions: completedFocusSessions,
    );
  }

  Future<void> _saveCompletedSession(PomodoroSessionEntity session) async {
    await repository.saveCompletedSession(session);
  }

  Future<void> _syncStrictMode(PomodoroSessionEntity session) {
    final active =
        session.isFocus && session.status == PomodoroSessionStatus.running;

    return strictModeService.setActive(
      active: active,
      endTime: active ? session.endTime : null,
    );
  }

  void _startTicker() {
    _cancelTicker();

    _ticker = Timer.periodic(
      const Duration(seconds: 1),
      (_) => add(const PomodoroTick()),
    );
  }

  void _cancelTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  @override
  Future<void> close() {
    _cancelTicker();
    return super.close();
  }
}
