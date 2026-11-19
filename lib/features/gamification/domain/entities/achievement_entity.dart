import 'package:equatable/equatable.dart';

class AchievementEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int target;
  final String type;
  final int bonusXp;

  const AchievementEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.target,
    required this.bonusXp,
    required this.type,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    icon,
    target,
    type,
    bonusXp,
  ];
}
