import 'package:equatable/equatable.dart';

class InstalledAppEntity extends Equatable {
  final String packageName;
  final String appName;
  final bool isSystemApp;

  const InstalledAppEntity({
    required this.packageName,
    required this.appName,
    required this.isSystemApp,
  });

  @override
  List<Object?> get props => [packageName, appName, isSystemApp];
}
