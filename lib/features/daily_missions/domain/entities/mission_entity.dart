
import 'package:equatable/equatable.dart';

class MissionEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String goal;
  final int durationMinutes;
  final String difficulty;
  final String status;
  final bool isSelected;

  // Execution tracking
  final int elapsedSeconds;
  final DateTime? startedAt;
  final DateTime? completedAt;

  const MissionEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.goal,
    required this.durationMinutes,
    required this.difficulty,
    this.status = 'draft',
    this.isSelected = true,
    this.elapsedSeconds = 0,
    this.startedAt,
    this.completedAt,
  });

  int elapsedAt(DateTime now) {
    if (status != 'inProgress' || startedAt == null) {
      return elapsedSeconds;
    }

    final runningSeconds = now.difference(startedAt!).inSeconds;

    return elapsedSeconds +
        (runningSeconds > 0 ? runningSeconds : 0);
  }

  MissionEntity copyWith({
    String? status,
    bool? isSelected,
    int? elapsedSeconds,
    DateTime? startedAt,
    DateTime? completedAt,
    bool clearStartedAt = false,
    bool clearCompletedAt = false,
  }) {
    return MissionEntity(
      id: id,
      title: title,
      description: description,
      goal: goal,
      durationMinutes: durationMinutes,
      difficulty: difficulty,
      status: status ?? this.status,
      isSelected: isSelected ?? this.isSelected,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      startedAt: clearStartedAt
          ? null
          : startedAt ?? this.startedAt,
      completedAt: clearCompletedAt
          ? null
          : completedAt ?? this.completedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        goal,
        durationMinutes,
        difficulty,
        status,
        isSelected,
        elapsedSeconds,
        startedAt,
        completedAt,
      ];
}
