import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/app_usage_snapshot.dart';
import '../../domain/services/app_usage_service.dart';

class AppUsageDashboardCard extends StatefulWidget {
  const AppUsageDashboardCard({super.key, AppUsageService? service})
    : _service = service ?? const AppUsageService();

  final AppUsageService _service;

  @override
  State<AppUsageDashboardCard> createState() => _AppUsageDashboardCardState();
}

class _AppUsageDashboardCardState extends State<AppUsageDashboardCard>
    with WidgetsBindingObserver {
  AppUsageSnapshot? _snapshot;
  DateTime? _selectedDate;
  Object? _loadError;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadUsage();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadUsage();
    }
  }

  Future<void> _loadUsage() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final snapshot = await widget._service.getWeeklyUsage();
      if (!mounted) return;
      setState(() {
        _snapshot = snapshot;
        _selectedDate = snapshot.days.isEmpty
            ? null
            : DateUtils.dateOnly(snapshot.days.last.date);
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = error;
        _isLoading = false;
      });
    }
  }

  Future<void> _openSettings() async {
    try {
      await widget._service.openUsageAccessSettings();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = _snapshot;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart_rounded, color: AppColors.primary),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'App usage',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                tooltip: 'Refresh app usage',
                onPressed: _isLoading ? null : _loadUsage,
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Screen time across your apps, by day',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 18),
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_loadError != null)
            _Message(
              message: 'Could not load app usage: $_loadError',
              actionLabel: 'Retry',
              onPressed: _loadUsage,
            )
          else if (snapshot == null || !snapshot.isSupported)
            const _Message(
              message: 'App usage reports are available on Android only.',
            )
          else if (!snapshot.hasAccess)
            _Message(
              message: 'Allow Usage Access to see how much time you spend in other apps.',
              actionLabel: 'Enable Usage Access',
              onPressed: _openSettings,
            )
          else
            _usageContent(snapshot),
        ],
      ),
    );
  }

  Widget _usageContent(AppUsageSnapshot snapshot) {
    if (snapshot.days.isEmpty) {
      return Text(
        'No app usage data is available yet.',
        style: TextStyle(color: AppColors.textSecondary),
      );
    }

    final selectedDay = snapshot.days.firstWhere(
      (day) => DateUtils.isSameDay(day.date, _selectedDate),
      orElse: () => snapshot.days.last,
    );
    final maxMinutes = snapshot.days
        .map((day) => day.totalUsage.inMinutes)
        .fold<int>(0, (max, minutes) => minutes > max ? minutes : max);
    final sortedApps = [...selectedDay.apps]
      ..sort((first, second) => second.duration.compareTo(first.duration));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: snapshot.days.map((day) {
            final isSelected = DateUtils.isSameDay(day.date, selectedDay.date);
            final fraction = maxMinutes == 0
                ? 0.0
                : day.totalUsage.inMinutes / maxMinutes;
            return Expanded(
              child: Semantics(
                button: true,
                selected: isSelected,
                label:
                    '${DateFormat('EEEE').format(day.date)}, ${_formatDuration(day.totalUsage)}',
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => setState(() => _selectedDate = day.date),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      children: [
                        Text(
                          _formatCompactDuration(day.totalUsage),
                          style: TextStyle(
                            fontSize: 10,
                            color: isSelected
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          height: 74,
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              height: 8 + (58 * fraction),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.primary.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          DateFormat('E').format(day.date),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        Text(
          '${DateFormat('EEEE, MMM d').format(selectedDay.date)} · ${_formatDuration(selectedDay.totalUsage)}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        if (sortedApps.isEmpty)
          Text(
            'No usage recorded for this day.',
            style: TextStyle(color: AppColors.textSecondary),
          )
        else
          ...sortedApps
              .take(6)
              .map(
                (app) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          app.appName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _formatDuration(app.duration),
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
      ],
    );
  }

  static String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (hours == 0) return '${remainingMinutes}m';
    if (remainingMinutes == 0) return '${hours}h';
    return '${hours}h ${remainingMinutes}m';
  }

  static String _formatCompactDuration(Duration duration) {
    final hours = duration.inMinutes ~/ 60;
    if (hours > 0) return '${hours}h';
    return '${duration.inMinutes}m';
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.message, this.actionLabel, this.onPressed});

  final String message;
  final String? actionLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(message, style: TextStyle(color: AppColors.textSecondary)),
        if (actionLabel != null && onPressed != null) ...[
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onPressed, child: Text(actionLabel!)),
        ],
      ],
    );
  }
}
