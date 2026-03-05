import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/auth_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../wedding/data/wedding_providers.dart';

/// Default items seeded on first visit (no local items exist in DB yet).
const _defaultSeedItems = [
  {'title': 'Réserver le lieu de la cérémonie', 'category': 'Lieu & Réception', 'sort_order': 0},
  {'title': 'Réserver le lieu de la réception', 'category': 'Lieu & Réception', 'sort_order': 1},
  {'title': 'Visiter les lieux potentiels', 'category': 'Lieu & Réception', 'sort_order': 2},
  {'title': 'Confirmer les horaires', 'category': 'Lieu & Réception', 'sort_order': 3},
  {'title': 'Choisir le traiteur', 'category': 'Traiteur & Boissons', 'sort_order': 4},
  {'title': 'Dégustation du menu', 'category': 'Traiteur & Boissons', 'sort_order': 5},
  {'title': 'Confirmer le menu final', 'category': 'Traiteur & Boissons', 'sort_order': 6},
  {'title': 'Commander le gâteau', 'category': 'Traiteur & Boissons', 'sort_order': 7},
  {'title': 'Essayage robe/costume', 'category': 'Tenue & Beauté', 'sort_order': 8},
  {'title': 'Choisir les alliances', 'category': 'Tenue & Beauté', 'sort_order': 9},
  {'title': 'Essai coiffure et maquillage', 'category': 'Tenue & Beauté', 'sort_order': 10},
  {'title': 'Tenue des témoins', 'category': 'Tenue & Beauté', 'sort_order': 11},
  {'title': 'Choisir le fleuriste', 'category': 'Décoration & Fleurs', 'sort_order': 12},
  {'title': 'Définir le thème de décoration', 'category': 'Décoration & Fleurs', 'sort_order': 13},
  {'title': 'Commander les centres de table', 'category': 'Décoration & Fleurs', 'sort_order': 14},
  {'title': 'Bouquet de la mariée', 'category': 'Décoration & Fleurs', 'sort_order': 15},
  {'title': 'Réserver DJ/groupe musical', 'category': 'Musique & Animation', 'sort_order': 16},
  {'title': 'Playlist de la cérémonie', 'category': 'Musique & Animation', 'sort_order': 17},
  {'title': 'Animation de la soirée', 'category': 'Musique & Animation', 'sort_order': 18},
  {'title': 'Photobooth', 'category': 'Musique & Animation', 'sort_order': 19},
  {'title': 'Démarches mairie', 'category': 'Démarches', 'sort_order': 20},
  {'title': 'Dossier de mariage', 'category': 'Démarches', 'sort_order': 21},
  {'title': 'Contrat d\'assurance', 'category': 'Démarches', 'sort_order': 22},
  {'title': 'Faire-part envoyés', 'category': 'Démarches', 'sort_order': 23},
];

const _categoryIcons = <String, IconData>{
  'Lieu & Réception': Icons.location_on_rounded,
  'Traiteur & Boissons': Icons.restaurant_rounded,
  'Tenue & Beauté': Icons.checkroom_rounded,
  'Décoration & Fleurs': Icons.local_florist_rounded,
  'Musique & Animation': Icons.music_note_rounded,
  'Démarches': Icons.description_rounded,
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
                            '$doneTasks / $totalTasks tâches',
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
