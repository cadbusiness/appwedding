import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/empty_state.dart';
import '../../wedding/data/wedding_providers.dart';

// Simple local checklist items - can be extended to Supabase later
final _defaultCategories = [
  _ChecklistCategory('Lieu & Réception', Icons.location_on_rounded, [
    'Réserver le lieu de cérémonie',
    'Réserver le lieu de réception',
    'Visiter les lieux potentiels',
    'Confirmer les horaires',
  ]),
  _ChecklistCategory('Traiteur & Boissons', Icons.restaurant_rounded, [
    'Choisir le traiteur',
    'Dégustation menu',
    'Confirmer le menu final',
    'Commander le gâteau',
  ]),
  _ChecklistCategory('Tenues & Beauté', Icons.checkroom_rounded, [
    'Essayage robe/costume',
    'Choisir les alliances',
    'Coiffeur & maquillage essai',
    'Tenues témoins',
  ]),
  _ChecklistCategory('Décoration & Fleurs', Icons.local_florist_rounded, [
    'Choisir le fleuriste',
    'Définir le thème déco',
    'Commander les centres de table',
    'Bouquet de mariée',
  ]),
  _ChecklistCategory('Musique & Animation', Icons.music_note_rounded, [
    'Réserver DJ/orchestre',
    'Playlist cérémonie',
    'Animations soirée',
    'Photobooth',
  ]),
  _ChecklistCategory('Administratif', Icons.description_rounded, [
    'Publier les bans',
    'Dossier mairie',
    'Contrat assurance',
    'Faire-part envoyés',
  ]),
];

class ChecklistScreen extends ConsumerStatefulWidget {
  const ChecklistScreen({super.key});

  @override
  ConsumerState<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends ConsumerState<ChecklistScreen> {
  final Map<String, bool> _checked = {};

  @override
  Widget build(BuildContext context) {
    final totalTasks =
        _defaultCategories.fold<int>(0, (sum, c) => sum + c.tasks.length);
    final doneTasks = _checked.values.where((v) => v).length;
    final progress = totalTasks > 0 ? doneTasks / totalTasks : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Check-list'),
        centerTitle: false,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
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
            ..._defaultCategories.map((category) {
              final categoryDone = category.tasks
                  .where((t) => _checked['${category.title}_$t'] == true)
                  .length;
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
                      child: Icon(
                        category.icon,
                        color: AppTheme.primary,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      category.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    subtitle: Text(
                      '$categoryDone / ${category.tasks.length}',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 13,
                      ),
                    ),
                    children: category.tasks.map((task) {
                      final key = '${category.title}_$task';
                      return CheckboxListTile(
                        value: _checked[key] ?? false,
                        onChanged: (v) =>
                            setState(() => _checked[key] = v ?? false),
                        title: Text(
                          task,
                          style: TextStyle(
                            fontSize: 14,
                            decoration: _checked[key] == true
                                ? TextDecoration.lineThrough
                                : null,
                            color: _checked[key] == true
                                ? Colors.grey
                                : Colors.black87,
                          ),
                        ),
                        activeColor: AppTheme.primary,
                        controlAffinity: ListTileControlAffinity.leading,
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
      ),
    );
  }
}

class _ChecklistCategory {
  final String title;
  final IconData icon;
  final List<String> tasks;

  _ChecklistCategory(this.title, this.icon, this.tasks);
}
