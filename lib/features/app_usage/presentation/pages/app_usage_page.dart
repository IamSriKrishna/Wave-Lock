import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'daily_growth_page.dart';
import '../widgets/app_usage_dashboard_card.dart';

class AppUsagePage extends StatelessWidget {
  const AppUsagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('App Usage')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Understand your screen time',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Review your daily usage and see which apps take up the most time.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          SizedBox(height: 20),
          const AppUsageDashboardCard(),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.emoji_events_outlined,
                color: AppColors.primary,
              ),
              title: const Text('Turn insights into action'),
              subtitle: const Text(
                'Open your goal-based daily growth challenge',
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DailyGrowthPage()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
