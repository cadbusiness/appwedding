import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/providers/auth_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../wedding/data/wedding_providers.dart';

/// Default items seeded on first visit.
const _defaultSeedItems = [
  {
    'title': 'Reservar el lugar de la ceremonia',
    'category': 'Lugar y Recepción',
    'sort_order': 0,
  },
  {
    'title': 'Reservar el lugar de la recepción',
    'category': 'Lugar y Recepción',
    'sort_order': 1,
  },
  {
    'title': 'Visitar los lugares potenciales',
    'category': 'Lugar y Recepción',
    'sort_order': 2,
  },
  {
    'title': 'Confirmar los horarios',
    'category': 'Lugar y Recepción',
    'sort_order': 3,
  },
  {
    'title': 'Elegir el banquete',
    'category': 'Banquete y Bebidas',
    'sort_order': 4,
  },
  {
    'title': 'Degustación del menú',
    'category': 'Banquete y Bebidas',
    'sort_order': 5,
  },
  {
    'title': 'Confirmar el menú final',
    'category': 'Banquete y Bebidas',
    'sort_order': 6,
  },
  {
    'title': 'Pedir el pastel',
    'category': 'Banquete y Bebidas',
    'sort_order': 7,
  },
  {
    'title': 'Prueba de vestido/traje',
    'category': 'Vestuario y Belleza',
    'sort_order': 8,
  },
  {
    'title': 'Elegir los anillos',
    'category': 'Vestuario y Belleza',
    'sort_order': 9,
  },
  {
    'title': 'Prueba de peinado y maquillaje',
    'category': 'Vestuario y Belleza',
    'sort_order': 10,
  },
  {
    'title': 'Vestuario de los padrinos',
    'category': 'Vestuario y Belleza',
    'sort_order': 11,
  },
  {
    'title': 'Elegir el florista',
    'category': 'Decoración y Flores',
    'sort_order': 12,
  },
  {
    'title': 'Definir el tema de decoración',
    'category': 'Decoración y Flores',
    'sort_order': 13,
  },
  {
    'title': 'Pedir los centros de mesa',
    'category': 'Decoración y Flores',
    'sort_order': 14,
  },
  {
    'title': 'Ramo de la novia',
    'category': 'Decoración y Flores',
    'sort_order': 15,
  },
  {
    'title': 'Reservar DJ/grupo musical',
    'category': 'Música y Animación',
    'sort_order': 16,
  },
  {
    'title': 'Playlist de la ceremonia',
    'category': 'Música y Animación',
    'sort_order': 17,
  },
  {
    'title': 'Animación de la fiesta',
    'category': 'Música y Animación',
    'sort_order': 18,
  },
  {'title': 'Photobooth', 'category': 'Música y Animación', 'sort_order': 19},
  {
    'title': 'Trámites en el registro civil',
    'category': 'Trámites',
    'sort_order': 20,
  },
  {
    'title': 'Expediente de matrimonio',
    'category': 'Trámites',
    'sort_order': 21,
  },
  {'title': 'Seguro del evento', 'category': 'Trámites', 'sort_order': 22},
  {'title': 'Invitaciones enviadas', 'category': 'Trámites', 'sort_order': 23},
];

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
        .map(
          (item) => {...item, 'wedding_id': weddingId, 'is_completed': false},
        )
        .toList();
    await supabase.from('wedding_checklist_items').insert(rows);
    ref.invalidate(weddingChecklistProvider);
  }

  Future<void> _toggleItem(String id, bool current) async {
    final supabase = ref.read(supabaseProvider);
    await supabase
        .from('wedding_checklist_items')
        .update({'is_completed': !current})
        .eq('id', id);
    ref.invalidate(weddingChecklistProvider);
  }

  Future<void> _deleteItem(String id) async {
    final supabase = ref.read(supabaseProvider);
    await supabase.from('wedding_checklist_items').delete().eq('id', id);
    ref.invalidate(weddingChecklistProvider);
  }

  Future<void> _addItem(String weddingId, String title, String category) async {
    final supabase = ref.read(supabaseProvider);
    await supabase.from('wedding_checklist_items').insert({
      'wedding_id': weddingId,
      'title': title,
      'category': category,
      'is_completed': false,
      'sort_order': 99,
    });
    ref.invalidate(weddingChecklistProvider);
  }

  void _showAddItemDialog(String weddingId, List<String> existingCategories) {
    final titleCtrl = TextEditingController();
    String selectedCategory = existingCategories.isNotEmpty
        ? existingCategories.first
        : '';
    bool creatingNew = false;
    final newCatCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocalState) => Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nueva tarea',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleCtrl,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Nombre de la tarea',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Categoría',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  ...existingCategories.map(
                    (cat) => GestureDetector(
                      onTap: () => setLocalState(() {
                        selectedCategory = cat;
                        creatingNew = false;
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: selectedCategory == cat && !creatingNew
                              ? AppTheme.primary
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          cat,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: selectedCategory == cat && !creatingNew
                                ? Colors.white
                                : Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setLocalState(() => creatingNew = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: creatingNew ? AppTheme.primary : null,
                        border: Border.all(
                          color: creatingNew
                              ? AppTheme.primary
                              : Colors.grey.shade300,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '+ Nueva',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: creatingNew
                              ? Colors.white
                              : Colors.grey.shade500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (creatingNew) ...[
                const SizedBox(height: 8),
                TextField(
                  controller: newCatCtrl,
                  decoration: InputDecoration(
                    hintText: 'Ej: Transporte, Regalos…',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  style: GoogleFonts.inter(fontSize: 13),
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final title = titleCtrl.text.trim();
                    final cat = creatingNew
                        ? newCatCtrl.text.trim()
                        : selectedCategory;
                    if (title.isNotEmpty && cat.isNotEmpty) {
                      _addItem(weddingId, title, cat);
                      Navigator.pop(ctx);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Agregar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final weddingAsync = ref.watch(weddingProvider);
    final checklistAsync = ref.watch(weddingChecklistProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          'Checklist',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: checklistAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (items) {
          final wedding = weddingAsync.value;
          if (items.isEmpty && wedding != null) {
            Future.microtask(() => _seedDefaults(wedding['id']));
            return const Center(child: CircularProgressIndicator());
          }

          final totalTasks = items.length;
          final doneTasks = items
              .where((i) => i['is_completed'] == true)
              .length;
          final progress = totalTasks > 0 ? doneTasks / totalTasks : 0.0;

          // Group by category (preserve order)
          final categories = <String, List<Map<String, dynamic>>>{};
          for (final item in items) {
            final cat = (item['category'] ?? 'Otro') as String;
            categories.putIfAbsent(cat, () => []).add(item);
          }

          final categoryKeys = categories.keys.toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header row ──
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$doneTasks / $totalTasks tareas',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${(progress * 100).round()}%',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // ── Progress bar ──
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 5,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Add button ──
                GestureDetector(
                  onTap: () {
                    if (wedding != null) {
                      _showAddItemDialog(wedding['id'], categoryKeys);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.add, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'Agregar tarea',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Categories ──
                ...categories.entries.map((entry) {
                  final catDone = entry.value
                      .where((i) => i['is_completed'] == true)
                      .length;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Theme(
                      data: Theme.of(
                        context,
                      ).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        initiallyExpanded: true,
                        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                entry.key,
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Text(
                              '$catDone / ${entry.value.length}',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                        children: entry.value.map((item) {
                          final checked = item['is_completed'] == true;
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 0,
                            ),
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(color: Colors.grey.shade100),
                              ),
                            ),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: checked,
                                  onChanged: (_) =>
                                      _toggleItem(item['id'], checked),
                                  activeColor: AppTheme.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    item['title'] ?? '',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      decoration: checked
                                          ? TextDecoration.lineThrough
                                          : null,
                                      color: checked
                                          ? Colors.grey
                                          : Colors.black87,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => _deleteItem(item['id']),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Icon(
                                      Icons.delete_outline,
                                      size: 16,
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
