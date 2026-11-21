import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme_controller.dart';
import '../../../../injection_container.dart';
import '../../../app_usage/presentation/pages/app_usage_page.dart';
import '../../../daily_missions/presentation/pages/daily_missions_page.dart';
import 'dashboard_home_page.dart';
import 'dashboard_tools_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _themeController = getIt<AppThemeController>();
  int _selectedTab = 0;
  int _homeRevision = 0;

  void _selectTab(int index) {
    if (index == 0 && _selectedTab != 0) {
      setState(() {
        _homeRevision++;
        _selectedTab = index;
      });
      return;
    }

    setState(() => _selectedTab = index);
  }

  Future<void> _openFeature(Widget page) async {
    await Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => page));
    if (!mounted) return;
    setState(() => _homeRevision++);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _themeController,
      builder: (context, _) => Scaffold(
        backgroundColor: AppColors.background,
        body: IndexedStack(
          index: _selectedTab,
          children: [
            DashboardHomePage(
              key: ValueKey(_homeRevision),
              onOpenMissions: () => _selectTab(1),
              onOpenFeature: _openFeature,
            ),
            DailyMissionsPage(),
            AppUsagePage(),
            DashboardToolsPage(onOpenFeature: _openFeature),
          ],
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          minimum: const EdgeInsets.fromLTRB(12, 4, 12, 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: NavigationBarTheme(
              data: NavigationBarThemeData(
                labelTextStyle: WidgetStateProperty.resolveWith((states) {
                  return TextStyle(
                    fontSize: 11,
                    fontWeight: states.contains(WidgetState.selected)
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: states.contains(WidgetState.selected)
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  );
                }),
              ),
              child: NavigationBar(
                height: 68,
                selectedIndex: _selectedTab,
                onDestinationSelected: _selectTab,
                backgroundColor: AppColors.surface,
                indicatorColor: AppColors.primary.withValues(alpha: 0.18),
                surfaceTintColor: Colors.transparent,
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.space_dashboard_outlined),
                    selectedIcon: Icon(Icons.space_dashboard_rounded),
                    label: 'Home',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.flag_outlined),
                    selectedIcon: Icon(Icons.flag_rounded),
                    label: 'Missions',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.insights_outlined),
                    selectedIcon: Icon(Icons.insights_rounded),
                    label: 'Usage',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.grid_view_rounded),
                    selectedIcon: Icon(Icons.grid_view_rounded),
                    label: 'Explore',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
