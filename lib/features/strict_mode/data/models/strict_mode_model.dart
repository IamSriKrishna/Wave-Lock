import '../../domain/entities/strict_mode_entity.dart';

class StrictModeModel extends StrictModeEntity {
  const StrictModeModel({
    required super.id,
    super.status,
    super.blockingType,
    super.releasePolicy,
    super.blockedPackageNames,
    super.linkedMissionId,
    super.startedAt,
    super.completedAt,
    super.isEnabled,
    required super.createdAt,
  });

  factory StrictModeModel.fromEntity(StrictModeEntity entity) {
    return StrictModeModel(
      id: entity.id,
      status: entity.status,
      blockingType: entity.blockingType,
      releasePolicy: entity.releasePolicy,
      blockedPackageNames: entity.blockedPackageNames,
      linkedMissionId: entity.linkedMissionId,
      startedAt: entity.startedAt,
      completedAt: entity.completedAt,
      isEnabled: entity.isEnabled,
      createdAt: entity.createdAt,
    );
  }

  factory StrictModeModel.fromMap(Map<String, dynamic> map) {
    return StrictModeModel(
      id: map['id'] as String,
      status: StrictModeStatus.values.firstWhere(
        (value) => value.name == map['status'],
        orElse: () => StrictModeStatus.disabled,
      ),
      blockingType: StrictModeBlockingType.values.firstWhere(
        (value) => value.name == map['blocking_type'],
        orElse: () => StrictModeBlockingType.allEligibleApps,
      ),
      releasePolicy: StrictModeReleasePolicy.values.firstWhere(
        (value) => value.name == map['release_policy'],
        orElse: () => StrictModeReleasePolicy.taskCompletionOnly,
      ),
      blockedPackageNames: List<String>.from(
        map['blocked_package_names'] ?? [],
      ),
      linkedMissionId: map['linked_mission_id'] as String?,
      startedAt: map['started_at'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(map['started_at'] as int),
      completedAt: map['completed_at'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(map['completed_at'] as int),
      isEnabled: map['is_enabled'] as bool? ?? false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'status': status.name,
      'blocking_type': blockingType.name,
      'release_policy': releasePolicy.name,
      'blocked_package_names': blockedPackageNames,
      'linked_mission_id': linkedMissionId,
      'started_at': startedAt?.millisecondsSinceEpoch,
      'completed_at': completedAt?.millisecondsSinceEpoch,
      'is_enabled': isEnabled,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }
}
