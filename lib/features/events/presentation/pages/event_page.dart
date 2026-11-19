import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakelock/features/events/presentation/pages/create_event_page.dart';
import 'package:wakelock/injection_container.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/event_entity.dart';
import '../../../motivational_quotes/presentation/widgets/motivational_quote_dialog.dart';
import '../bloc/event_bloc.dart';
import '../bloc/event_event.dart';
import '../bloc/event_state.dart';

class EventPage extends StatelessWidget {
  const EventPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<EventBloc>()..add(const LoadEvents()),
      child: const _EventView(),
    );
  }
}

class _EventView extends StatelessWidget {
  const _EventView();

  Future<void> _runEventAction(
    BuildContext context,
    EventEntity event, {
    required bool start,
  }) async {
    final action = start ? 'start' : 'complete';
    final ready = await showMotivationalQuoteDialog(
      context,
      title: 'Ready to $action ${event.title}?',
      canCancel: true,
    );
    if (!ready || !context.mounted) return;

    final bloc = context.read<EventBloc>();
    final result = bloc.stream.firstWhere((state) {
      if (state.status == EventStatus.failure) return true;

      final updatedEvent = state.events.where((item) => item.id == event.id);
      return updatedEvent.isNotEmpty &&
          (start
              ? updatedEvent.first.isStarted
              : updatedEvent.first.isCompleted);
    });

    bloc.add(start ? StartEvent(event.id) : ToggleEventCompletion(event.id));

    final state = await result;
    if (!context.mounted) return;

    if (state.status == EventStatus.failure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.errorMessage ?? 'Unable to update event.'),
        ),
      );
      return;
    }

    await showMotivationalQuoteDialog(
      context,
      title: start ? 'Event started!' : 'Event completed!',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('My Events')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<EventBloc>(),
                child: const CreateEventPage(),
              ),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Event'),
      ),
      body: BlocBuilder<EventBloc, EventState>(
        builder: (context, state) {
          if (state.status == EventStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == EventStatus.failure && state.events.isEmpty) {
            return Center(
              child: Text(
                state.errorMessage ?? 'Something went wrong',
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          final upcoming = state.upcomingEvents;
          final completed = state.completedEvents;

          if (upcoming.isEmpty && completed.isEmpty) {
            return const Center(
              child: Text(
                'No events yet. Create your first event!',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _SectionTitle(title: 'Upcoming Events', count: upcoming.length),
              const SizedBox(height: 12),
              if (upcoming.isEmpty)
                const Text(
                  'No upcoming events',
                  style: TextStyle(color: Colors.white54),
                ),
              ...upcoming.map(
                (event) => _EventCard(
                  event: event,
                  onStart: () => _runEventAction(context, event, start: true),
                  onToggle: () => event.isCompleted
                      ? context.read<EventBloc>().add(
                          ToggleEventCompletion(event.id),
                        )
                      : _runEventAction(context, event, start: false),
                  onDelete: () =>
                      context.read<EventBloc>().add(DeleteEvent(event.id)),
                ),
              ),
              const SizedBox(height: 28),
              _SectionTitle(title: 'Completed Events', count: completed.length),
              const SizedBox(height: 12),
              ...completed.map(
                (event) => _EventCard(
                  event: event,
                  onStart: () {},
                  onToggle: () => context.read<EventBloc>().add(
                    ToggleEventCompletion(event.id),
                  ),
                  onDelete: () =>
                      context.read<EventBloc>().add(DeleteEvent(event.id)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final int count;

  const _SectionTitle({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Text('($count)', style: const TextStyle(color: Colors.white54)),
      ],
    );
  }
}

class _EventCard extends StatelessWidget {
  final EventEntity event;
  final VoidCallback onStart;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _EventCard({
    required this.event,
    required this.onStart,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final date = event.eventDate;
    final timeMinutes = event.startTimeMinutes;

    return Card(
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          event.isCompleted ? Icons.check_circle : Icons.event,
          color: AppColors.primary,
        ),
        title: Text(event.title, style: const TextStyle(color: Colors.white)),
        subtitle: Text(
          '${date.day}/${date.month}/${date.year}'
          '${timeMinutes == null ? '' : ' • ${_formatTime(context, timeMinutes)}'}'
          '${event.isStarted && !event.isCompleted ? ' • Started' : ''}',
          style: const TextStyle(color: Colors.white54),
        ),
        trailing: PopupMenuButton<String>(
          iconColor: Colors.white70,
          onSelected: (value) {
            if (value == 'start') onStart();
            if (value == 'toggle') onToggle();
            if (value == 'delete') onDelete();
          },
          itemBuilder: (_) => [
            if (!event.isCompleted && !event.isStarted)
              const PopupMenuItem(value: 'start', child: Text('Start event')),
            PopupMenuItem(
              value: 'toggle',
              child: Text(event.isCompleted ? 'Undo completion' : 'Complete'),
            ),
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
      ),
    );
  }

  String _formatTime(BuildContext context, int minutes) {
    final time = TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);

    return time.format(context);
  }
}
