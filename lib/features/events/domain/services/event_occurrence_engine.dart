import '../entities/event_entity.dart';

class EventOccurrenceEngine {
  List<DateTime> generateOccurrences({
    required EventEntity event,
    required DateTime from,
    required DateTime to,
  }) {
    if (to.isBefore(from)) return [];

    final occurrences = <DateTime>[];

    final firstDate = DateTime(
      event.eventDate.year,
      event.eventDate.month,
      event.eventDate.day,
    );

    final rangeStart = DateTime(from.year, from.month, from.day);
    final rangeEnd = DateTime(to.year, to.month, to.day);

    final recurrenceEnd = event.recurrenceEndDate == null
        ? null
        : DateTime(
            event.recurrenceEndDate!.year,
            event.recurrenceEndDate!.month,
            event.recurrenceEndDate!.day,
          );

    bool isWithinBounds(DateTime date) {
      return !date.isBefore(firstDate) &&
          !date.isBefore(rangeStart) &&
          !date.isAfter(rangeEnd) &&
          (recurrenceEnd == null || !date.isAfter(recurrenceEnd));
    }

    switch (event.recurrence) {
      case EventRecurrence.none:
        if (isWithinBounds(firstDate)) {
          occurrences.add(firstDate);
        }

      case EventRecurrence.daily:
        var current = firstDate.isBefore(rangeStart) ? rangeStart : firstDate;

        while (!current.isAfter(rangeEnd)) {
          if (isWithinBounds(current)) {
            occurrences.add(current);
          }

          current = current.add(const Duration(days: 1));
        }

      case EventRecurrence.weekly:
        var current = firstDate.isBefore(rangeStart) ? rangeStart : firstDate;

        while (current.weekday != firstDate.weekday) {
          current = current.add(const Duration(days: 1));
        }

        while (!current.isAfter(rangeEnd)) {
          if (isWithinBounds(current)) {
            occurrences.add(current);
          }

          current = current.add(const Duration(days: 7));
        }

      case EventRecurrence.monthly:
        var monthOffset = 0;

        if (rangeStart.isAfter(firstDate)) {
          monthOffset =
              (rangeStart.year - firstDate.year) * 12 +
              rangeStart.month -
              firstDate.month;
        }

        while (true) {
          final year =
              firstDate.year + (firstDate.month - 1 + monthOffset) ~/ 12;

          final month = (firstDate.month - 1 + monthOffset) % 12 + 1;

          final lastDayOfMonth = DateTime(year, month + 1, 0).day;

          final occurrence = DateTime(
            year,
            month,
            firstDate.day > lastDayOfMonth ? lastDayOfMonth : firstDate.day,
          );

          if (occurrence.isAfter(rangeEnd)) break;

          if (isWithinBounds(occurrence)) {
            occurrences.add(occurrence);
          }

          monthOffset++;
        }
    }

    return occurrences;
  }
}
