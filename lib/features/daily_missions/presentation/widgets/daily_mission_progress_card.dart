import 'package:flutter/material.dart';

import '../../../../injection_container.dart';
import '../../domain/repositories/mission_repository.dart';

class DailyMissionProgressCard extends StatelessWidget {
  const DailyMissionProgressCard({super.key});

  String get todayKey {
    final now = DateTime.now();

    return '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getIt<MissionRepository>().getMissionsForDate(todayKey),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final missions = snapshot.data!;
        final completed = missions
            .where((mission) => mission.status == 'completed')
            .length;

        final progress = completed / missions.length;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Today's Progress",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('$completed of ${missions.length} missions'),
                    Text('${(progress * 100).round()}%'),
                  ],
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(20),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
