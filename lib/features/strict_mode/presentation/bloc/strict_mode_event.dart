import 'package:equatable/equatable.dart';

import '../../domain/entities/strict_mode_entity.dart';

abstract class StrictModeEvent extends Equatable {
  const StrictModeEvent();

  @override
  List<Object?> get props => [];
}

class LoadStrictMode extends StrictModeEvent {
  const LoadStrictMode();
}

class UpdateBlockingType extends StrictModeEvent {
  final StrictModeBlockingType blockingType;

  const UpdateBlockingType(this.blockingType);

  @override
  List<Object?> get props => [blockingType];
}

class UpdateSelectedApps extends StrictModeEvent {
  final List<String> packageNames;

  const UpdateSelectedApps(this.packageNames);

  @override
  List<Object?> get props => [packageNames];
}

class EnableStrictMode extends StrictModeEvent {
  final String missionId;

  const EnableStrictMode(this.missionId);

  @override
  List<Object?> get props => [missionId];
}

class DisableStrictMode extends StrictModeEvent {
  const DisableStrictMode();
}

class CompleteStrictMode extends StrictModeEvent {
  const CompleteStrictMode();
}
