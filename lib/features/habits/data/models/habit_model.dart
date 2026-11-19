import '../../domain/entities/habit_entity.dart';

class HabitModel extends HabitEntity {
  const HabitModel({
    required super.id,
    required super.title,
    required super.description,
    required super.category,
    required super.scheduledWeekdays,
    required super.createdAt,
    super.scheduledTimeMinutes,
    super.completedDates,
    super.isActive,
  });

  factory HabitModel.fromMap(Map<String, dynamic> map) {
    return HabitModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      category: map['category'] as String,
      scheduledWeekdays: List<int>.from(map['scheduled_weekdays'] ?? []),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      scheduledTimeMinutes: map['scheduled_time_minutes'] as int?,
      completedDates: List<String>.from(map['completed_dates'] ?? []),
      isActive: map['is_active'] as bool? ?? true,
    );
  }

  factory HabitModel.fromEntity(HabitEntity habit) {
    return HabitModel(
      id: habit.id,
      title: habit.title,
      description: habit.description,
      category: habit.category,
      scheduledWeekdays: habit.scheduledWeekdays,
      scheduledTimeMinutes: habit.scheduledTimeMinutes,
      createdAt: habit.createdAt,
      completedDates: habit.completedDates,
      isActive: habit.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'scheduled_weekdays': scheduledWeekdays,
      'created_at': createdAt.millisecondsSinceEpoch,
      'scheduled_time_minutes': scheduledTimeMinutes,
      'completed_dates': completedDates,
      'is_active': isActive,
    };
  }
}
