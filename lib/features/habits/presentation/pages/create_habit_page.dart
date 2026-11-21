import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/habit_alarm_platform_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/habit_bloc.dart';
import '../bloc/habit_event.dart';
import '../utils/habit_time_parser.dart';

class CreateHabitPage extends StatefulWidget {
  const CreateHabitPage({super.key});

  @override
  State<CreateHabitPage> createState() => _CreateHabitPageState();
}

class _CreateHabitPageState extends State<CreateHabitPage> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  final List<int> _selectedDays = [];

  TimeOfDay? _selectedTime;
  bool _timeWasAutoDetected = false;

  String _category = 'Personal Development';

  final List<String> _categories = [
    'Coding',
    'Learning',
    'Fitness',
    'Reading',
    'Professional Work',
    'Personal Development',
  ];

  final List<String> _weekdays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectHabitTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );

    if (!mounted) return;

    if (selected != null) {
      setState(() {
        _selectedTime = selected;
        _timeWasAutoDetected = false;
      });
    }
  }

  void _updateTimeFromTitle(String title) {
    final minutes = parseTimeMinutesFromTitle(title);

    if (minutes != null) {
      setState(() {
        _selectedTime = TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);
        _timeWasAutoDetected = true;
      });
    } else if (_timeWasAutoDetected) {
      setState(() {
        _selectedTime = null;
        _timeWasAutoDetected = false;
      });
    }
  }

  Future<void> _createHabit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedTime != null &&
        defaultTargetPlatform == TargetPlatform.android) {
      if (!await HabitAlarmPlatformService.canDrawOverlays()) {
        await HabitAlarmPlatformService.requestOverlayPermission();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Allow WakeLock to display over other apps, then tap Create Habit again.',
            ),
          ),
        );
        return;
      }

      final notifications = NotificationService.instance;
      await notifications.initialize();
      final exactAlarmGranted = await notifications
          .requestExactAlarmPermission();
      if (!exactAlarmGranted) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Allow Alarms & reminders for WakeLock, then tap Create Habit again.',
            ),
          ),
        );
        return;
      }
    }

    if (!mounted) return;

    context.read<HabitBloc>().add(
      CreateHabit(
        title: _titleController.text,
        description: _descriptionController.text,
        scheduledTimeMinutes: _selectedTime == null
            ? null
            : _selectedTime!.hour * 60 + _selectedTime!.minute,
        category: _category,
        scheduledWeekdays: _selectedDays,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Create Habit'),
        backgroundColor: AppColors.background,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Habit name',
                hintText: 'Example: Read 20 pages',
              ),
              onChanged: _updateTimeFromTitle,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter a habit name';
                }

                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _descriptionController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Why is this habit important?',
              ),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              initialValue: _category,
              dropdownColor: AppColors.surface,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Category'),
              items: _categories.map((category) {
                return DropdownMenuItem(value: category, child: Text(category));
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _category = value);
                }
              },
            ),
            const SizedBox(height: 28),

            const Text(
              'Preferred Time (Optional)',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time, color: Colors.orangeAccent),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _selectedTime == null
                          ? 'No specific time'
                          : _selectedTime!.format(context),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  TextButton(
                    onPressed: _selectHabitTime,
                    child: Text(_selectedTime == null ? 'Set time' : 'Change'),
                  ),
                  if (_selectedTime != null)
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _selectedTime = null;
                          _timeWasAutoDetected = false;
                        });
                      },
                      icon: const Icon(Icons.close, color: Colors.white54),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Schedule',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Leave all days unselected to schedule every day.',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              children: List.generate(7, (index) {
                final weekday = index + 1;
                final selected = _selectedDays.contains(weekday);

                return FilterChip(
                  label: Text(_weekdays[index]),
                  selected: selected,
                  selectedColor: AppColors.primary,
                  onSelected: (value) {
                    setState(() {
                      if (value) {
                        _selectedDays.add(weekday);
                      } else {
                        _selectedDays.remove(weekday);
                      }
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 36),
            ElevatedButton(
              onPressed: _createHabit,
              child: const Text('Create Habit'),
            ),
          ],
        ),
      ),
    );
  }
}
