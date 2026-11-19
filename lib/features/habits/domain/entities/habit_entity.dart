import 'package:equatable/equatable.dart';

class HabitEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String category;
  final List<int> scheduledWeekdays;
  final int? scheduledTimeMinutes;
  final DateTime createdAt;
  final List<String> completedDates;
  final bool isActive;

  const HabitEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.scheduledWeekdays,
    required this.createdAt,
    this.scheduledTimeMinutes,
    this.completedDates = const [],
    this.isActive = true,
  });

  String dateKey(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  bool isScheduledOn(DateTime date) {
    if (scheduledWeekdays.isEmpty) return true;

    return scheduledWeekdays.contains(date.weekday);
  }

  bool isCompletedOn(DateTime date) {
    return completedDates.contains(dateKey(date));
  }

  HabitEntity copyWith({
    String? title,
    String? description,
    String? category,
    List<int>? scheduledWeekdays,
    List<String>? completedDates,
    bool? isActive,
    int? scheduledTimeMinutes,
    bool clearScheduledTime = false,
  }) {
    return HabitEntity(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      scheduledWeekdays: scheduledWeekdays ?? this.scheduledWeekdays,
      createdAt: createdAt,
      completedDates: completedDates ?? this.completedDates,
      isActive: isActive ?? this.isActive,
      scheduledTimeMinutes: clearScheduledTime
          ? null
          : scheduledTimeMinutes ?? this.scheduledTimeMinutes,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    scheduledTimeMinutes,
    category,
    scheduledWeekdays,
    createdAt,
    completedDates,
    isActive,
  ];
}
