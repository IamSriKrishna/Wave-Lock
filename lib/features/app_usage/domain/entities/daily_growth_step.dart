class DailyGrowthStep {
  const DailyGrowthStep({
    required this.id,
    required this.title,
    required this.description,
    required this.goal,
    required this.estimatedMinutes,
  });

  final String id;
  final String title;
  final String description;
  final String goal;
  final int estimatedMinutes;
}
