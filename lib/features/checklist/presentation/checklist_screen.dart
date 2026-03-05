import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/auth_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../wedding/data/wedding_providers.dart';

/// Default items seeded on first visit (no local items exist in DB yet).
const _defaultSeedItems = [
  {'title': 'Reservar el lugar de la ceremonia', 'category': 'Lugar y Recepción', 'sort_order': 0},
  {'title': 'Reservar el lugar de la recepción', 'category': 'Lugar y Recepción', 'sort_order': 1},
  {'title': 'Visitar los lugares potenciales', 'category': 'Lugar y Recepción', 'sort_order': 2},
  {'title': 'Confirmar los horarios', 'category': 'Lugar y Recepción', 'sort_order': 3},
  {'title': 'Elegir el banquete', 'category': 'Banquete y Bebidas', 'sort_order': 4},
  {'title': 'Degustación del menú', 'category': 'Banquete y Bebidas', 'sort_order': 5},
  {'title': 'Confirmar el menú final', 'category': 'Banquete y Bebidas', 'sort_order': 6},
  {'title': 'Pedir el pastel', 'category': 'Banquete y Bebidas', 'sort_order': 7},
  {'title': 'Prueba de vestido/traje', 'category': 'Vestuario y Belleza', 'sort_order': 8},
  {'title': 'Elegir los anillos', 'category': 'Vestuario y Belleza', 'sort_order': 9},
  {'title': 'Prueba de peinado y maquillaje', 'category': 'Vestuario y Belleza', 'sort_order': 10},
  {'title': 'Vestuario de los padrinos', 'category': 'Vestuario y Belleza', 'sort_order': 11},
  {'title': 'Elegir el florista', 'category': 'Decoración y Flores', 'sort_order': 12},
  {'title': 'Definir el tema de decoración', 'category': 'Decoración y Flores', 'sort_order': 13},
  {'title': 'Pedir los centros de mesa', 'category': 'Decoración y Flores', 'sort_order': 14},
  {'title': 'Ramo de la novia', 'category': 'Decoración y Flores', 'sort_order': 15},
  {'title': 'Reservar DJ/grupo musical', 'category': 'Música y Animación', 'sort_order': 16},
  {'title': 'Playlist de la ceremonia', 'category': 'Música y Animación', 'sort_order': 17},
  {'title': 'Animación de la fiesta', 'category': 'Música y Animación', 'sort_order': 18},
  {'title': 'Photobooth', 'category': 'Música y Animación', 'sort_order': 19},
  {'title': 'Trámites en el registro civil', 'category': 'Trámites', 'sort_order': 20},
  {'title': 'Expediente de matrimonio', 'category': 'Trámites', 'sort_order': 21},
  {'title': 'Seguro del evento', 'category': 'Trámites', 'sort_order': 22},
  {'title': 'Invitaciones enviadas', 'category': 'Trámites', 'sort_order': 23},
];

const _categoryIcons = <String, IconData>{
  'Lugar y Recepción': Icons.location_on_rounded,
  'Banquete y Bebidas': Icons.restaurant_rounded,
  'Vestuario y Belleza': Icons.checkroom_rounded,
  'Decoración y Flores': Icons.local_florist_rounded,
  'Música y Animación': Icons.music_note_rounded,
  'Trámites': Icons.description_rounded,
};

class ChecklistScreen extends ConsumerStatefulWidget {
  const ChecklistScreen({super.key});

  @override
  ConsumerState<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends ConsumerState<ChecklistScreen> {
  bool _seeded = false;

  Future<void> _seedDefaults(String weddingId) async {
    if (_seeded) return;
    _seeded = true;
    final supabase = ref.read(supabaseProvider);
    final rows = _defaultSeedItems
        .map((item) => {
              ...item,
              'wedding_id': weddingId,
              'is_completed': false,
            })
        .toList();
    await supabase.from('wedding_checklist_items').insert(rows);
    ref.invalidate(weddingChecklistProvider);
  }

  Future<void> _toggleItem(String id, bool current) async {
    final supabase = ref.read(supabaseProvider);
    await supabase
        .from('wedding_checklist_items')
        .update({'is_completed': !current}).eq('id', id);
    ref.invalidate(weddingChecklistProvider);
  }

  @override
  Widget build(BuildContext context) {
    final weddingAsync = ref.watch(weddingProvider);
    final checklistAsync = ref.watch(weddingChecklistProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Checklist'),
        centerTitle: false,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: checklistAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (items) {
          // Auto-seed on first visit
          final wedding = weddingAsync.value;
          if (items.isEmpty && wedding != null) {
            Future.microtask(() => _seedDefaults(wedding['id']));
            return const Center(child: CircularProgressIndicator());
          }

          final totalTasks = items.length;
          final doneTasks =
              items.where((i) => i['is_completed'] == true).length;
          final progress = totalTasks > 0 ? doneTasks / totalTasks : 0.0;

          // Group by category
          final categories = <String, List<Map<String, dynamic>>>{};
          for (final item in items) {
            final cat = (item['category'] ?? 'Autres') as String;
            categories.putIfAbsent(cat, () => []).add(item);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$doneTasks / $totalTasks tareas',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '${(progress * 100).round()}%',
                            style: TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          backgroundColor: Colors.grey.shade100,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(AppTheme.primary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Categories
                ...categories.entries.map((entry) {
                  final catDone = entry.value
                      .where((i) => i['is_completed'] == true)
                      .length;
                  final icon =
                      _categoryIcons[entry.key] ?? Icons.check_circle_outline;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        dividerColor: Colors.transparent,
                      ),
                      child: ExpansionTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(icon, color: AppTheme.primary, size: 20),
                        ),
                        title: Text(
                          entry.key,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        subtitle: Text(
                          '$catDone / ${entry.value.length}',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 13,
                          ),
                        ),
                        children: entry.value.map((item) {
                          final checked = item['is_completed'] == true;
                          return CheckboxListTile(
                            value: checked,
                            onChanged: (_) =>
                                _toggleItem(item['id'], checked),
                            title: Text(
                              item['title'] ?? '',
                              style: TextStyle(
                                fontSize: 14,
                                decoration: checked
                                    ? TextDecoration.lineThrough
                                    : null,
                                color:
                                    checked ? Colors.grey : Colors.black87,
                              ),
                            ),
                            activeColor: AppTheme.primary,
                            controlAffinity:
                                ListTileControlAffinity.leading,
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 16),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}
