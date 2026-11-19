import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/progress_repository.dart';
import 'gamification_event.dart';
import 'gamification_state.dart';

class GamificationBloc extends Bloc<GamificationEvent, GamificationState> {
  final ProgressRepository progressRepository;

  GamificationBloc({required this.progressRepository})
    : super(const GamificationState()) {
    on<LoadGamification>(_onLoad);
  }

  Future<void> _onLoad(
    LoadGamification event,
    Emitter<GamificationState> emit,
  ) async {
    emit(state.copyWith(status: GamificationStatus.loading));

    try {
      final progress = await progressRepository.getProgress();

      emit(
        state.copyWith(status: GamificationStatus.loaded, progress: progress),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: GamificationStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
