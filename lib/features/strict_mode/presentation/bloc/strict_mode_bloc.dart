import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/strict_mode_service.dart';
import '../../domain/services/strict_mode_management_service.dart';
import 'strict_mode_event.dart';
import 'strict_mode_state.dart';

class StrictModeBloc extends Bloc<StrictModeEvent, StrictModeState> {
  final StrictModeManagementService _managementService;
  final StrictModeService strictModeService;

  StrictModeBloc({
    required this._managementService,
    required this.strictModeService,
  }) : super(const StrictModeState()) {
    on<LoadStrictMode>(_onLoad);
    on<UpdateBlockingType>(_onUpdateBlockingType);
    on<UpdateSelectedApps>(_onUpdateSelectedApps);
    on<EnableStrictMode>(_onEnable);
    on<DisableStrictMode>(_onDisable);
    on<CompleteStrictMode>(_onComplete);
  }

  Future<void> _onLoad(
    LoadStrictMode event,
    Emitter<StrictModeState> emit,
  ) async {
    emit(
      state.copyWith(status: StrictModeLoadStatus.loading, clearError: true),
    );

    try {
      final settings = await _managementService.getOrCreateSettings();
      await strictModeService.setMissionActive(active: settings.isActive);

      emit(
        state.copyWith(status: StrictModeLoadStatus.loaded, settings: settings),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: StrictModeLoadStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onUpdateBlockingType(
    UpdateBlockingType event,
    Emitter<StrictModeState> emit,
  ) async {
    final settings = state.settings;
    if (settings == null) return;

    emit(state.copyWith(status: StrictModeLoadStatus.saving, clearError: true));

    try {
      final updated = await _managementService.updateBlockingType(
        settings,
        event.blockingType,
      );

      emit(
        state.copyWith(status: StrictModeLoadStatus.loaded, settings: updated),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: StrictModeLoadStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onUpdateSelectedApps(
    UpdateSelectedApps event,
    Emitter<StrictModeState> emit,
  ) async {
    final settings = state.settings;
    if (settings == null) return;

    emit(state.copyWith(status: StrictModeLoadStatus.saving, clearError: true));

    try {
      final updated = await _managementService.updateSelectedApps(
        settings,
        event.packageNames,
      );

      emit(
        state.copyWith(status: StrictModeLoadStatus.loaded, settings: updated),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: StrictModeLoadStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onEnable(
    EnableStrictMode event,
    Emitter<StrictModeState> emit,
  ) async {
    final settings = state.settings;
    if (settings == null) return;

    emit(state.copyWith(status: StrictModeLoadStatus.saving, clearError: true));

    try {
      final updated = await _managementService.enableStrictMode(
        settings,
        event.missionId,
      );
      await strictModeService.setMissionActive(active: true);

      emit(
        state.copyWith(status: StrictModeLoadStatus.loaded, settings: updated),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: StrictModeLoadStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onDisable(
    DisableStrictMode event,
    Emitter<StrictModeState> emit,
  ) async {
    final settings = state.settings;
    if (settings == null) return;

    try {
      final updated = await _managementService.disableStrictMode(settings);
      await strictModeService.setMissionActive(active: false);

      emit(
        state.copyWith(
          status: StrictModeLoadStatus.loaded,
          settings: updated,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: StrictModeLoadStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onComplete(
    CompleteStrictMode event,
    Emitter<StrictModeState> emit,
  ) async {
    final settings = state.settings;
    if (settings == null) return;

    try {
      final updated = await _managementService.completeStrictMode(settings);
      await strictModeService.setMissionActive(active: false);

      emit(
        state.copyWith(
          status: StrictModeLoadStatus.loaded,
          settings: updated,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: StrictModeLoadStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}
