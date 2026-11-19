class UserEntity {
  final String id;
  final String name;
  final List<String> goals;
  final String experienceLevel;
  final int dailyAvailableMinutes;
  final String preferredStartTime;
  final String preferredEndTime;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.name,
    required this.goals,
    required this.experienceLevel,
    required this.dailyAvailableMinutes,
    required this.preferredStartTime,
    required this.preferredEndTime,
    required this.createdAt,
  });
}
