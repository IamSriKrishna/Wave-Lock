
import '../../domain/entities/mission_entity.dart';

class MissionModel extends MissionEntity {
  const MissionModel({
    required super.id,
    required super.title,
    required super.description,
    required super.goal,
    required super.durationMinutes,
    required super.difficulty,
    super.status,
    super.isSelected,
    super.elapsedSeconds,
    super.startedAt,
    super.completedAt,
  });

  factory MissionModel.fromMap(Map<String, dynamic> map) {
    return MissionModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      goal: map['goal'] as String,
      durationMinutes: map['duration_minutes'] as int,
      difficulty: map['difficulty'] as String,
      status: map['status'] as String? ?? 'draft',
      isSelected: map['is_selected'] as bool? ?? true,
      elapsedSeconds: map['elapsed_seconds'] as int? ?? 0,
      startedAt: map['started_at'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(
              map['started_at'] as int,
            ),
      completedAt: map['completed_at'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(
              map['completed_at'] as int,
            ),
    );
  }

  factory MissionModel.fromEntity(MissionEntity entity) {
    return MissionModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      goal: entity.goal,
      durationMinutes: entity.durationMinutes,
      difficulty: entity.difficulty,
      status: entity.status,
      isSelected: entity.isSelected,
      elapsedSeconds: entity.elapsedSeconds,
      startedAt: entity.startedAt,
      completedAt: entity.completedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'goal': goal,
      'duration_minutes': durationMinutes,
      'difficulty': difficulty,
      'status': status,
      'is_selected': isSelected,
      'elapsed_seconds': elapsedSeconds,
      'started_at': startedAt?.millisecondsSinceEpoch,
      'completed_at': completedAt?.millisecondsSinceEpoch,
    };
  }
}
