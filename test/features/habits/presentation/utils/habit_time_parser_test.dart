import 'package:flutter_test/flutter_test.dart';
import 'package:wakelock/features/habits/presentation/utils/habit_time_parser.dart';

void main() {
  group('parseTimeMinutesFromTitle', () {
    test('parses an hour with pm', () {
      expect(parseTimeMinutesFromTitle('Read 20 pages at 6pm'), 18 * 60);
    });

    test('parses minutes with pm and optional spacing', () {
      expect(parseTimeMinutesFromTitle('Read at 6:01pm'), 18 * 60 + 1);
      expect(parseTimeMinutesFromTitle('Read at 6:01 PM'), 18 * 60 + 1);
    });

    test('parses am and midnight correctly', () {
      expect(parseTimeMinutesFromTitle('Walk at 6am'), 6 * 60);
      expect(parseTimeMinutesFromTitle('Sleep at 12:30am'), 30);
    });

    test('ignores invalid and absent times', () {
      expect(parseTimeMinutesFromTitle('Read 20 pages'), isNull);
      expect(parseTimeMinutesFromTitle('Read at 13pm'), isNull);
      expect(parseTimeMinutesFromTitle('Read at 6:60pm'), isNull);
    });
  });
}
