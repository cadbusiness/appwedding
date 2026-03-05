import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/providers/auth_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../wedding/data/wedding_providers.dart';

const _defaultTimelineSeed = [
  {'title': 'Cérémonie civile', 'event_time': '10:00:00', 'location': 'Mairie', 'category': 'Cérémonie', 'sort_order': 0},
  {'title': 'Cérémonie religieuse', 'event_time': '14:00:00', 'location': 'Église', 'category': 'Cérémonie', 'sort_order': 1},
  {'title': 'Cocktail', 'event_time': '16:00:00', 'location': 'Jardin du château', 'category': 'Réception', 'sort_order': 2},
  {'title': 'Photos de groupe', 'event_time': '17:00:00', 'location': 'Parc', 'category': 'Photos', 'sort_order': 3},
  {'title': 'Dîner', 'event_time': '19:30:00', 'location': 'Salle de réception', 'category': 'Réception', 'sort_order': 4},
  {'title': 'Première danse', 'event_time': '22:00:00', 'location': 'Piste de danse', 'category': 'Soirée', 'sort_order': 5},
  {'title': 'Soirée dansante', 'event_time': '22:30:00', 'location': 'Salle de réception', 'category': 'Soirée', 'sort_order': 6},
];

const _categoryIcons = <String, IconData>{
  'Cérémonie': Icons.church_rounded,
  'Réception': Icons.restaurant_rounded,
  'Photos': Icons.camera_alt_rounded,
  'Soirée': Icons.nightlife_rounded,
};

class TimelineScreen extends ConsumerStatefulWidget {
  const TimelineScreen({super.key});

  @override
  ConsumerState<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends ConsumerState<TimelineScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  bool _seeded = false;

  Future<void> _seedDefaults(String weddingId) async {
    if (_seeded) return;
    _seeded = true;
    final supabase = ref.read(supabaseProvider);
    final rows = _defaultTimelineSeed
        .map((item) => {
              ...item,
              'wedding_id': weddingId,
            })
        .toList();
    await supabase.from('wedding_timeline_events').insert(rows);
    ref.invalidate(weddingTimelineProvider);
  }

  @override
  Widget build(BuildContext context) {
    final weddingAsync = ref.watch(weddingProvider);
    final timelineAsync = ref.watch(weddingTimelineProvider);

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
                'Programme du grand jour',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 12),

            timelineAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (events) {
                final wedding = weddingAsync.value;
                if (events.isEmpty && wedding != null) {
                  Future.microtask(() => _seedDefaults(wedding['id']));
                  return const Center(child: CircularProgressIndicator());
                }

                return Column(
                  children: events.asMap().entries.map((entry) {
                    final index = entry.key;
                    final event = entry.value;
                    final isLast = index == events.length - 1;
                    final time = (event['event_time'] as String?)
                            ?.substring(0, 5) ??
                        '--:--';
                    final icon =
                        _categoryIcons[event['category']] ??
                            Icons.event_rounded;

                    return Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 20),
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
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
                                        color: AppTheme.primary
                                            .withOpacity(0.2),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Container(
                                margin:
                                    const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(12),
                                  border: Border.all(
                                      color: Colors.grey.shade100),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: AppTheme.primary
                                            .withOpacity(0.1),
                                        borderRadius:
                                            BorderRadius.circular(
                                                10),
                                      ),
                                      child: Icon(
                                        icon,
                                        color: AppTheme.primary,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,
                                        children: [
                                          Text(
                                            event['title'] ?? '',
                                            style:
                                                const TextStyle(
                                              fontWeight:
                                                  FontWeight.w600,
                                              fontSize: 15,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            event['location'] ??
                                                '',
                                            style: TextStyle(
                                              color: Colors
                                                  .grey.shade500,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      time,
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
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
