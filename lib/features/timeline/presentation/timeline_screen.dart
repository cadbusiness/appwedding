import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../wedding/data/wedding_providers.dart';

class TimelineScreen extends ConsumerStatefulWidget {
  const TimelineScreen({super.key});

  @override
  ConsumerState<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends ConsumerState<TimelineScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  // Sample timeline events
  final List<_TimelineEvent> _events = [
    _TimelineEvent(
      title: 'Cérémonie civile',
      time: '10:00',
      location: 'Mairie',
      icon: Icons.account_balance_rounded,
    ),
    _TimelineEvent(
      title: 'Cérémonie religieuse',
      time: '14:00',
      location: 'Église',
      icon: Icons.church_rounded,
    ),
    _TimelineEvent(
      title: 'Cocktail',
      time: '16:00',
      location: 'Jardin du château',
      icon: Icons.local_bar_rounded,
    ),
    _TimelineEvent(
      title: 'Photos de groupe',
      time: '17:00',
      location: 'Parc',
      icon: Icons.camera_alt_rounded,
    ),
    _TimelineEvent(
      title: 'Dîner',
      time: '19:30',
      location: 'Salle de réception',
      icon: Icons.restaurant_rounded,
    ),
    _TimelineEvent(
      title: 'Ouverture du bal',
      time: '22:00',
      location: 'Piste de danse',
      icon: Icons.music_note_rounded,
    ),
    _TimelineEvent(
      title: 'Soirée dansante',
      time: '22:30',
      location: 'Salle de réception',
      icon: Icons.nightlife_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final weddingAsync = ref.watch(weddingProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Planning'),
        centerTitle: false,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Calendar
            Container(
              color: Colors.white,
              child: TableCalendar(
                firstDay: DateTime.utc(2024, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                locale: 'fr_FR',
                calendarFormat: _calendarFormat,
                onFormatChanged: (format) =>
                    setState(() => _calendarFormat = format),
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selected, focused) {
                  setState(() {
                    _selectedDay = selected;
                    _focusedDay = focused;
                  });
                },
                headerStyle: HeaderStyle(
                  formatButtonVisible: true,
                  titleCentered: true,
                  formatButtonDecoration: BoxDecoration(
                    border: Border.all(color: AppTheme.primary),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  formatButtonTextStyle: TextStyle(
                    color: AppTheme.primary,
                    fontSize: 13,
                  ),
                ),
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: AppTheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Day timeline
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Déroulé du jour J',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 12),
            ..._events.asMap().entries.map((entry) {
              final index = entry.key;
              final event = entry.value;
              final isLast = index == _events.length - 1;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Timeline line
                      SizedBox(
                        width: 50,
                        child: Column(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: AppTheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            if (!isLast)
                              Expanded(
                                child: Container(
                                  width: 2,
                                  color: AppTheme.primary.withOpacity(0.2),
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Event card
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade100),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppTheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  event.icon,
                                  color: AppTheme.primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      event.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      event.location,
                                      style: TextStyle(
                                        color: Colors.grey.shade500,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                event.time,
                                style: TextStyle(
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _TimelineEvent {
  final String title;
  final String time;
  final String location;
  final IconData icon;

  _TimelineEvent({
    required this.title,
    required this.time,
    required this.location,
    required this.icon,
  });
}
