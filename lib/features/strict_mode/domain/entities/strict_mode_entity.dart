import 'package:equatable/equatable.dart';

enum StrictModeStatus { disabled, active, completed }

enum StrictModeBlockingType { selectedApps, allEligibleApps }

enum StrictModeReleasePolicy { taskCompletionOnly }

class StrictModeEntity extends Equatable {
  final String id;
  final StrictModeStatus status;
  final StrictModeBlockingType blockingType;
  final StrictModeReleasePolicy releasePolicy;
  final List<String> blockedPackageNames;
  final String? linkedMissionId;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final bool isEnabled;
  final DateTime createdAt;

  const StrictModeEntity({
    required this.id,
    this.status = StrictModeStatus.disabled,
    this.blockingType = StrictModeBlockingType.allEligibleApps,
    this.releasePolicy = StrictModeReleasePolicy.taskCompletionOnly,
    this.blockedPackageNames = const [],
    this.linkedMissionId,
    this.startedAt,
    this.completedAt,
    this.isEnabled = false,
    required this.createdAt,
  });

  bool get isActive => status == StrictModeStatus.active && isEnabled;

  bool get blocksSelectedApps =>
      blockingType == StrictModeBlockingType.selectedApps;

  StrictModeEntity copyWith({
    StrictModeStatus? status,
    StrictModeBlockingType? blockingType,
    StrictModeReleasePolicy? releasePolicy,
    List<String>? blockedPackageNames,
    String? linkedMissionId,
    DateTime? startedAt,
    DateTime? completedAt,
    bool? isEnabled,
    bool clearLinkedMissionId = false,
    bool clearStartedAt = false,
    bool clearCompletedAt = false,
  }) {
    return StrictModeEntity(
      id: id,
      status: status ?? this.status,
      blockingType: blockingType ?? this.blockingType,
      releasePolicy: releasePolicy ?? this.releasePolicy,
      blockedPackageNames: blockedPackageNames ?? this.blockedPackageNames,
      linkedMissionId: clearLinkedMissionId
          ? null
          : linkedMissionId ?? this.linkedMissionId,
      startedAt: clearStartedAt ? null : startedAt ?? this.startedAt,
      completedAt: clearCompletedAt ? null : completedAt ?? this.completedAt,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    status,
    blockingType,
    releasePolicy,
    blockedPackageNames,
    linkedMissionId,
    startedAt,
    completedAt,
    isEnabled,
    createdAt,
  ];
}
