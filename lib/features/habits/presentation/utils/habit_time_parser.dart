int? parseTimeMinutesFromTitle(String title) {
  final timePattern = RegExp(
    r'\b(\d{1,2})(?::(\d{2}))?\s*([ap])\.?m\.?\b',
    caseSensitive: false,
  );

  for (final match in timePattern.allMatches(title)) {
    final hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2) ?? '0');

    if (hour < 1 || hour > 12 || minute > 59) {
      continue;
    }

    final isAfternoon = match.group(3)!.toLowerCase() == 'p';
    final hourIn24HourFormat = hour % 12 + (isAfternoon ? 12 : 0);

    return hourIn24HourFormat * 60 + minute;
  }

  return null;
}
