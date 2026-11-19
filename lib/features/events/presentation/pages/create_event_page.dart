import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/notification_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/event_entity.dart';
import '../bloc/event_bloc.dart';
import '../bloc/event_event.dart';
import '../bloc/event_state.dart';

class CreateEventPage extends StatefulWidget {
  const CreateEventPage({super.key});

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime _eventDate = DateUtils.dateOnly(DateTime.now());
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  EventRecurrence _recurrence = EventRecurrence.none;
  int? _reminderMinutes;
  bool _submitted = false;

  int? get _startTimeMinutes =>
      _startTime == null ? null : _startTime!.hour * 60 + _startTime!.minute;

  int? get _endTimeMinutes =>
      _endTime == null ? null : _endTime!.hour * 60 + _endTime!.minute;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _eventDate,
      firstDate: DateUtils.dateOnly(DateTime.now()),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );

    if (selected != null) {
      setState(() {
        _eventDate = DateUtils.dateOnly(selected);
      });
    }
  }

  Future<void> _selectStartTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
    );

    if (!mounted) return;

    if (selected != null) {
      setState(() {
        _startTime = selected;

        if (_endTime != null && _endTimeMinutes! <= _startTimeMinutes!) {
          _endTime = null;
        }
      });
    }
  }

  Future<void> _selectEndTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime:
          _endTime ??
          (_startTime == null
              ? TimeOfDay.now()
              : TimeOfDay(
                  hour: (_startTime!.hour + 1) % 24,
                  minute: _startTime!.minute,
                )),
    );

    if (!mounted) return;

    if (selected != null) {
      final minutes = selected.hour * 60 + selected.minute;

      if (_startTimeMinutes != null && minutes <= _startTimeMinutes!) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('End time must be after start time.')),
        );
        return;
      }

      setState(() => _endTime = selected);
    }
  }

  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) return;

    if (_startTime == null && _endTime != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select a start time before selecting an end time.'),
        ),
      );
      return;
    }

    setState(() => _submitted = true);

    if (_startTime != null) {
      await NotificationService.instance.requestPermissions();
      await NotificationService.instance.requestExactAlarmPermission();
      await NotificationService.instance.requestFullScreenIntentPermission();
    }

    if (!mounted) return;

    context.read<EventBloc>().add(
      CreateEvent(
        title: _titleController.text,
        description: _descriptionController.text,
        eventDate: _eventDate,
        startTimeMinutes: _startTimeMinutes,
        endTimeMinutes: _endTimeMinutes,
        recurrence: _recurrence,
        reminderMinutesBefore: _reminderMinutes,
      ),
    );
  }

  String _formatTime(TimeOfDay? time) {
    return time?.format(context) ?? 'Not selected';
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EventBloc, EventState>(
      listener: (context, state) {
        if (!_submitted) return;

        if (state.status == EventStatus.loaded) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Event created successfully!')),
          );
        }

        if (state.status == EventStatus.failure) {
          setState(() => _submitted = false);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Could not save event.'),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Create Event')),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildLabel('Event Title'),
              TextFormField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Enter event title'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Event title is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              _buildLabel('Description'),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Add some details'),
              ),
              const SizedBox(height: 24),

              _buildLabel('Event Date'),
              _buildSelectionTile(
                icon: Icons.calendar_month,
                title:
                    '${_eventDate.day}/${_eventDate.month}/${_eventDate.year}',
                onTap: _selectDate,
              ),
              const SizedBox(height: 20),

              _buildLabel('Start Time (Optional)'),
              _buildSelectionTile(
                icon: Icons.access_time,
                title: _formatTime(_startTime),
                onTap: _selectStartTime,
                trailing: _startTime == null
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          setState(() {
                            _startTime = null;
                            _endTime = null;
                          });
                        },
                      ),
              ),
              const SizedBox(height: 12),

              _buildLabel('End Time (Optional)'),
              _buildSelectionTile(
                icon: Icons.timer_outlined,
                title: _formatTime(_endTime),
                onTap: _selectEndTime,
                trailing: _endTime == null
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => setState(() => _endTime = null),
                      ),
              ),
              const SizedBox(height: 24),

              _buildLabel('Repeat'),
              DropdownButtonFormField<EventRecurrence>(
                value: _recurrence,
                dropdownColor: AppColors.surface,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Select recurrence'),
                items: EventRecurrence.values.map((value) {
                  return DropdownMenuItem(
                    value: value,
                    child: Text(_recurrenceLabel(value)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _recurrence = value);
                  }
                },
              ),
              const SizedBox(height: 20),

              _buildLabel('Reminder'),
              DropdownButtonFormField<int?>(
                value: _reminderMinutes,
                dropdownColor: AppColors.surface,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Select reminder'),
                items: const [
                  DropdownMenuItem<int?>(
                    value: null,
                    child: Text('No reminder'),
                  ),
                  DropdownMenuItem(value: 5, child: Text('5 minutes before')),
                  DropdownMenuItem(value: 10, child: Text('10 minutes before')),
                  DropdownMenuItem(value: 15, child: Text('15 minutes before')),
                  DropdownMenuItem(value: 30, child: Text('30 minutes before')),
                  DropdownMenuItem(value: 60, child: Text('1 hour before')),
                ],
                onChanged: (value) {
                  setState(() => _reminderMinutes = value);
                },
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _submitted ? null : _saveEvent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _submitted
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Create Event'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSelectionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return ListTile(
      onTap: onTap,
      tileColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing:
          trailing ?? const Icon(Icons.chevron_right, color: Colors.white54),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white38),
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  String _recurrenceLabel(EventRecurrence recurrence) {
    switch (recurrence) {
      case EventRecurrence.none:
        return 'Does not repeat';
      case EventRecurrence.daily:
        return 'Every day';
      case EventRecurrence.weekly:
        return 'Every week';
      case EventRecurrence.monthly:
        return 'Every month';
    }
  }
}
