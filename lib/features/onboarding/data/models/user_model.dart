import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.goals,
    required super.experienceLevel,
    required super.dailyAvailableMinutes,
    required super.preferredStartTime,
    required super.preferredEndTime,
    required super.createdAt,
  });

  factory UserModel.fromMap(Map<String, Object?> map) {
    return UserModel(
      id: map['id'] as String,
      name: map['name'] as String,
      goals: List<String>.from(map['goals'] as List),
      experienceLevel: map['experience_level'] as String,
      dailyAvailableMinutes: map['daily_available_minutes'] as int,
      preferredStartTime: map['preferred_start_time'] as String,
      preferredEndTime: map['preferred_end_time'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'goals': goals,
      'experience_level': experienceLevel,
      'daily_available_minutes': dailyAvailableMinutes,
      'preferred_start_time': preferredStartTime,
      'preferred_end_time': preferredEndTime,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      name: entity.name,
      goals: entity.goals,
      experienceLevel: entity.experienceLevel,
      dailyAvailableMinutes: entity.dailyAvailableMinutes,
      preferredStartTime: entity.preferredStartTime,
      preferredEndTime: entity.preferredEndTime,
      createdAt: entity.createdAt,
    );
  }
}
