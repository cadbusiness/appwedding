import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/providers/auth_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../wedding/data/wedding_providers.dart';

// ── Segment model ──────────────────────────────────────────────
class BudgetSegment {
  final String id;
  final String segmentKey;
  final String label;
  final String emoji;
  final Color color;

  const BudgetSegment({
    required this.id,
    required this.segmentKey,
    required this.label,
    required this.emoji,
    required this.color,
  });
}

Color _hexToColor(String hex) {
  hex = hex.replaceAll('#', '');
  if (hex.length == 6) hex = 'FF$hex';
  return Color(int.parse(hex, radix: 16));
}

// ── Default segments (seeded on first visit) ───────────────────
const _defaultSegments = [
  {
    'segment_key': 'couple',
    'label': 'La Pareja',
    'emoji': '💍',
    'color': '#EDE9FE',
    'sort_order': 0,
  },
  {
    'segment_key': 'novia',
    'label': 'La Novia',
    'emoji': '👰',
    'color': '#FCE7F3',
    'sort_order': 1,
  },
  {
    'segment_key': 'novio',
    'label': 'El Novio',
    'emoji': '🤵',
    'color': '#DBEAFE',
    'sort_order': 2,
  },
  {
    'segment_key': 'padres_novia',
    'label': 'Padres de la Novia',
    'emoji': '👨‍👩‍👧',
    'color': '#FFE4E6',
    'sort_order': 3,
  },
  {
    'segment_key': 'padres_novio',
    'label': 'Padres del Novio',
    'emoji': '👨‍👩‍👦',
    'color': '#E0F2FE',
    'sort_order': 4,
  },
  {
    'segment_key': 'padrinos',
    'label': 'Padrinos',
    'emoji': '🤝',
    'color': '#FEF3C7',
    'sort_order': 5,
  },
  {
    'segment_key': 'otros',
    'label': 'Otro',
    'emoji': '📋',
    'color': '#F3F4F6',
    'sort_order': 6,
  },
];

// ── Default seed items ─────────────────────────────────────────
const _defaultBudgetSeed = [
  {
    'name': 'Renta del salón',
    'category': 'Lugar',
    'segment': 'couple',
    'estimated_cost': 5000,
    'sort_order': 0,
  },
  {
    'name': 'Hospedaje',
    'category': 'Lugar',
    'segment': 'couple',
    'estimated_cost': 1500,
    'sort_order': 1,
  },
  {
    'name': 'Comida y bebidas',
    'category': 'Banquete',
    'segment': 'couple',
    'estimated_cost': 8000,
    'sort_order': 2,
  },
  {
    'name': 'Invitaciones',
    'category': 'Varios',
    'segment': 'couple',
    'estimated_cost': 300,
    'sort_order': 3,
  },
  {
    'name': 'Anillos',
    'category': 'Accesorios',
    'segment': 'couple',
    'estimated_cost': 1000,
    'sort_order': 4,
  },
  {
    'name': 'Fotógrafo',
    'category': 'Foto',
    'segment': 'couple',
    'estimated_cost': 1800,
    'sort_order': 5,
  },
  {
    'name': 'Videógrafo',
    'category': 'Foto',
    'segment': 'couple',
    'estimated_cost': 1200,
    'sort_order': 6,
  },
  {
    'name': 'DJ / Grupo musical',
    'category': 'Música',
    'segment': 'couple',
    'estimated_cost': 1500,
    'sort_order': 7,
  },
  {
    'name': 'Flores y decoración',
    'category': 'Decoración',
    'segment': 'couple',
    'estimated_cost': 2000,
    'sort_order': 8,
  },
  {
    'name': 'Vestido de novia',
    'category': 'Vestuario',
    'segment': 'novia',
    'estimated_cost': 2500,
    'sort_order': 9,
  },
  {
    'name': 'Peinado y maquillaje',
    'category': 'Belleza',
    'segment': 'novia',
    'estimated_cost': 500,
    'sort_order': 10,
  },
  {
    'name': 'Accesorios (velo, zapatos)',
    'category': 'Vestuario',
    'segment': 'novia',
    'estimated_cost': 400,
    'sort_order': 11,
  },
  {
    'name': 'Ramo de la novia',
    'category': 'Flores',
    'segment': 'novia',
    'estimated_cost': 200,
    'sort_order': 12,
  },
  {
    'name': 'Traje del novio',
    'category': 'Vestuario',
    'segment': 'novio',
    'estimated_cost': 800,
    'sort_order': 13,
  },
  {
    'name': 'Zapatos + accesorios',
    'category': 'Vestuario',
    'segment': 'novio',
    'estimated_cost': 300,
    'sort_order': 14,
  },
  {
    'name': 'Boutonnière',
    'category': 'Flores',
    'segment': 'novio',
    'estimated_cost': 50,
    'sort_order': 15,
  },
  {
    'name': 'Ceremonia religiosa',
    'category': 'Ceremonia',
    'segment': 'padres_novia',
    'estimated_cost': 500,
    'sort_order': 16,
  },
  {
    'name': 'Pastel',
    'category': 'Banquete',
    'segment': 'padres_novia',
    'estimated_cost': 500,
    'sort_order': 17,
  },
  {
    'name': 'Brindis champagne',
    'category': 'Bebidas',
    'segment': 'padres_novio',
    'estimated_cost': 600,
    'sort_order': 18,
  },
  {
    'name': 'Recuerdos para invitados',
    'category': 'Varios',
    'segment': 'padres_novio',
    'estimated_cost': 400,
    'sort_order': 19,
  },
];

// ── Providers ──────────────────────────────────────────────────
final budgetSegmentsProvider = FutureProvider<List<BudgetSegment>>((ref) async {
  final wedding = await ref.watch(weddingProvider.future);
  if (wedding == null) return [];
  final supabase = ref.watch(supabaseProvider);
  final rows = await supabase
      .from('wedding_budget_segments')
      .select()
      .eq('wedding_id', wedding['id'])
      .order('sort_order');
  return List<Map<String, dynamic>>.from(rows)
      .map(
        (r) => BudgetSegment(
          id: r['id'],
          segmentKey: r['segment_key'],
          label: r['label'],
          emoji: r['emoji'] ?? '📋',
          color: _hexToColor(r['color'] ?? '#F3F4F6'),
        ),
      )
      .toList();
});

class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({super.key});

  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> {
  final _currencyFormat = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
  bool _seeded = false;
  String? _activeSegment;
  bool _editingBudget = false;
  final _budgetController = TextEditingController();

  BudgetSegment _getSegment(List<BudgetSegment> segments, String key) =>
      segments.firstWhere(
        (s) => s.segmentKey == key,
        orElse: () => segments.isNotEmpty
            ? segments.first
            : BudgetSegment(
                id: '',
                segmentKey: key,
                label: key,
                emoji: '📋',
                color: const Color(0xFFF3F4F6),
              ),
      );

  Future<void> _seedDefaults(String weddingId) async {
    if (_seeded) return;
    _seeded = true;
    final supabase = ref.read(supabaseProvider);

    // Seed segments
    final segRows = _defaultSegments
        .map((s) => {...s, 'wedding_id': weddingId})
        .toList();
    await supabase.from('wedding_budget_segments').insert(segRows);

    // Seed items
    final itemRows = _defaultBudgetSeed
        .map(
          (item) => {
            ...item,
            'wedding_id': weddingId,
            'actual_cost': 0,
            'is_paid': false,
          },
        )
        .toList();
    await supabase.from('wedding_budget_items').insert(itemRows);

    ref.invalidate(weddingBudgetProvider);
    ref.invalidate(budgetSegmentsProvider);
  }

  Future<void> _updateGlobalBudget(String weddingId, double amount) async {
    final supabase = ref.read(supabaseProvider);
    await supabase
        .from('weddings')
        .update({'budget': amount})
        .eq('id', weddingId);
    ref.invalidate(weddingProvider);
    setState(() => _editingBudget = false);
  }

  Future<void> _addSegment(
    String weddingId,
    String label,
    String emoji,
    String colorHex,
  ) async {
    final supabase = ref.read(supabaseProvider);
    final key = label
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]'), '_')
        .replaceAll(RegExp(r'_+'), '_');
    await supabase.from('wedding_budget_segments').insert({
      'wedding_id': weddingId,
      'segment_key': key.length > 30 ? key.substring(0, 30) : key,
      'label': label,
      'emoji': emoji,
      'color': colorHex,
      'sort_order': 99,
    });
    ref.invalidate(budgetSegmentsProvider);
  }

  Future<void> _deleteSegment(String segmentId) async {
    final supabase = ref.read(supabaseProvider);
    await supabase.from('wedding_budget_segments').delete().eq('id', segmentId);
    ref.invalidate(budgetSegmentsProvider);
  }

  Future<void> _addItem(
    String weddingId,
    String name,
    String category,
    String segment,
    double estimated,
  ) async {
    final supabase = ref.read(supabaseProvider);
    await supabase.from('wedding_budget_items').insert({
      'wedding_id': weddingId,
      'name': name,
      'category': category,
      'segment': segment,
      'estimated_cost': estimated,
      'actual_cost': 0,
      'is_paid': false,
      'sort_order': 99,
    });
    ref.invalidate(weddingBudgetProvider);
  }

  Future<void> _deleteItem(String itemId) async {
    final supabase = ref.read(supabaseProvider);
    await supabase.from('wedding_budget_items').delete().eq('id', itemId);
    ref.invalidate(weddingBudgetProvider);
  }

  Future<void> _updateItem(String itemId, Map<String, dynamic> updates) async {
    final supabase = ref.read(supabaseProvider);
    await supabase
        .from('wedding_budget_items')
        .update(updates)
        .eq('id', itemId);
    ref.invalidate(weddingBudgetProvider);
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final weddingAsync = ref.watch(weddingProvider);
    final budgetAsync = ref.watch(weddingBudgetProvider);
    final segmentsAsync = ref.watch(budgetSegmentsProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          'Presupuesto',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: budgetAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (items) {
          final wedding = weddingAsync.value;
          final segments = segmentsAsync.value ?? [];

          if (items.isEmpty && segments.isEmpty && wedding != null) {
            Future.microtask(() => _seedDefaults(wedding['id']));
            return const Center(child: CircularProgressIndicator());
          }

          // ── Filtered items ──
          final displayItems = _activeSegment == null
              ? items
              : items.where((i) => i['segment'] == _activeSegment).toList();

          // ── Global totals ──
          final totalEstimated = items.fold<double>(
            0,
            (s, i) => s + ((i['estimated_cost'] as num?)?.toDouble() ?? 0),
          );
          final totalActual = items.fold<double>(
            0,
            (s, i) => s + ((i['actual_cost'] as num?)?.toDouble() ?? 0),
          );
          final weddingBudget = (wedding?['budget'] as num?)?.toDouble();
          final totalBudget = weddingBudget ?? totalEstimated;
          final remaining = totalBudget - totalActual;

          // ── Group by category ──
          final categories = <String, List<Map<String, dynamic>>>{};
          for (final item in displayItems) {
            final cat = (item['category'] ?? 'Otro') as String;
            categories.putIfAbsent(cat, () => []).add(item);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header: Budget total (tappable to edit) ──
                GestureDetector(
                  onTap: () {
                    _budgetController.text = totalBudget > 0
                        ? totalBudget.toStringAsFixed(0)
                        : '';
                    setState(() => _editingBudget = true);
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_editingBudget && wedding != null) ...[
                              Row(
                                children: [
                                  SizedBox(
                                    width: 140,
                                    height: 36,
                                    child: TextField(
                                      controller: _budgetController,
                                      autofocus: true,
                                      keyboardType: TextInputType.number,
                                      style: GoogleFonts.inter(fontSize: 14),
                                      decoration: InputDecoration(
                                        hintText: 'Ej: 30000',
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        suffixText: '\$',
                                      ),
                                      onSubmitted: (v) {
                                        final val = double.tryParse(
                                          v.replaceAll(',', '.'),
                                        );
                                        if (val != null && val > 0)
                                          _updateGlobalBudget(
                                            wedding['id'],
                                            val,
                                          );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () {
                                      final val = double.tryParse(
                                        _budgetController.text.replaceAll(
                                          ',',
                                          '.',
                                        ),
                                      );
                                      if (val != null && val > 0)
                                        _updateGlobalBudget(
                                          wedding['id'],
                                          val,
                                        );
                                    },
                                    child: const Icon(
                                      Icons.check_circle_outline,
                                      color: Colors.green,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  GestureDetector(
                                    onTap: () =>
                                        setState(() => _editingBudget = false),
                                    child: Icon(
                                      Icons.close,
                                      color: Colors.grey.shade400,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ] else ...[
                              Text(
                                weddingBudget != null
                                    ? '${_currencyFormat.format(totalActual)} gastado de ${_currencyFormat.format(totalBudget)}'
                                    : '${_currencyFormat.format(totalActual)} gastado · Definir presupuesto',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${remaining >= 0 ? '+' : ''}${_currencyFormat.format(remaining)}',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: remaining < 0
                                  ? AppTheme.error
                                  : AppTheme.primary,
                            ),
                          ),
                          Text(
                            'restante',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // ── Progress bar ──
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: totalBudget > 0
                        ? (totalActual / totalBudget).clamp(0.0, 1.0)
                        : 0,
                    minHeight: 5,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation(
                      totalActual > totalBudget
                          ? AppTheme.error
                          : AppTheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ── Segment filter chips ──
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _FilterChip(
                      label: 'Todos',
                      isActive: _activeSegment == null,
                      onTap: () => setState(() => _activeSegment = null),
                    ),
                    ...segments.map(
                      (seg) => _FilterChip(
                        label: '${seg.emoji} ${seg.label}',
                        isActive: _activeSegment == seg.segmentKey,
                        onTap: () => setState(
                          () =>
                              _activeSegment = _activeSegment == seg.segmentKey
                              ? null
                              : seg.segmentKey,
                        ),
                        bgColor: _activeSegment == seg.segmentKey
                            ? null
                            : seg.color,
                      ),
                    ),
                    // Add segment button
                    GestureDetector(
                      onTap: () => _showAddSegmentDialog(wedding?['id']),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.add,
                          size: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),

                // ── Edit/delete segment link ──
                if (_activeSegment != null) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      final seg = segments.firstWhere(
                        (s) => s.segmentKey == _activeSegment,
                        orElse: () => segments.first,
                      );
                      _showEditSegmentDialog(seg);
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.palette_outlined,
                          size: 14,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Modificar segmento',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),

                // ── Items header + Add button ──
                Row(
                  children: [
                    Text(
                      '${displayItems.length} gasto${displayItems.length != 1 ? 's' : ''}',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () =>
                          _showAddItemDialog(wedding?['id'], segments, items),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
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
                              'Agregar',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // ── Budget items by category ──
                if (categories.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Text(
                        'Sin gastos',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ),
                  ),

                ...categories.entries.map((entry) {
                  final catTotal = entry.value.fold<double>(
                    0,
                    (s, i) =>
                        s + ((i['estimated_cost'] as num?)?.toDouble() ?? 0),
                  );
                  final catActual = entry.value.fold<double>(
                    0,
                    (s, i) => s + ((i['actual_cost'] as num?)?.toDouble() ?? 0),
                  );

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
                        initiallyExpanded: false,
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
                              '${_currencyFormat.format(catActual)} / ${_currencyFormat.format(catTotal)}',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                        children: entry.value.map((item) {
                          final seg = _getSegment(
                            segments,
                            (item['segment'] ?? 'couple') as String,
                          );
                          final isPaid = item['is_paid'] == true;
                          final estimated =
                              (item['estimated_cost'] as num?)?.toDouble() ?? 0;
                          final actual =
                              (item['actual_cost'] as num?)?.toDouble() ?? 0;

                          return GestureDetector(
                            onTap: () => _showEditItemDialog(
                              item,
                              segments,
                              items,
                            ),
                            child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(color: Colors.grey.shade100),
                              ),
                            ),
                            child: Column(
                              children: [
                                // Name + segment emoji + actions
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item['name'] ?? '',
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    if (_activeSegment == null)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          right: 8,
                                        ),
                                        child: Text(
                                          seg.emoji,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ),
                                    GestureDetector(
                                      onTap: () => _updateItem(item['id'], {
                                        'is_paid': !isPaid,
                                      }),
                                      child: Icon(
                                        isPaid
                                            ? Icons.check_circle
                                            : Icons.circle_outlined,
                                        size: 20,
                                        color: isPaid
                                            ? Colors.green
                                            : Colors.grey.shade300,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () => _deleteItem(item['id']),
                                      child: Icon(
                                        Icons.delete_outline,
                                        size: 18,
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                // Estimado / Real row
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Estimado',
                                            style: GoogleFonts.inter(
                                              fontSize: 10,
                                              color: Colors.grey.shade400,
                                            ),
                                          ),
                                          Text(
                                            _currencyFormat.format(estimated),
                                            style: GoogleFonts.inter(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Real',
                                            style: GoogleFonts.inter(
                                              fontSize: 10,
                                              color: Colors.grey.shade400,
                                            ),
                                          ),
                                          Text(
                                            _currencyFormat.format(actual),
                                            style: GoogleFonts.inter(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Segmento',
                                            style: GoogleFonts.inter(
                                              fontSize: 10,
                                              color: Colors.grey.shade400,
                                            ),
                                          ),
                                          Text(
                                            '${seg.emoji} ${seg.label}',
                                            style: GoogleFonts.inter(
                                              fontSize: 11,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
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

  // ── Dialogs ──────────────────────────────────────────────────

  void _showEditItemDialog(
    Map<String, dynamic> item,
    List<BudgetSegment> segments,
    List<Map<String, dynamic>> allItems,
  ) {
    final nameCtrl = TextEditingController(text: item['name'] ?? '');
    final estimatedCtrl = TextEditingController(
      text: ((item['estimated_cost'] as num?)?.toDouble() ?? 0)
          .toStringAsFixed(0),
    );
    final actualCtrl = TextEditingController(
      text: ((item['actual_cost'] as num?)?.toDouble() ?? 0)
          .toStringAsFixed(0),
    );
    String segment = (item['segment'] ?? 'couple') as String;
    String category = (item['category'] ?? '') as String;
    bool isPaid = item['is_paid'] == true;

    final existingCats =
        allItems.map((i) => (i['category'] ?? '') as String).toSet().toList()
          ..sort();

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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Title ──
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Editar gasto',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        _deleteItem(item['id']);
                        Navigator.pop(ctx);
                      },
                      child: Icon(
                        Icons.delete_outline,
                        color: AppTheme.error,
                        size: 22,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Name ──
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Nombre',
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

                // ── Estimated + Actual side by side ──
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: estimatedCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Estimado',
                          suffixText: '\$',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: actualCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Real',
                          suffixText: '\$',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // ── Paid toggle ──
                GestureDetector(
                  onTap: () => setLocalState(() => isPaid = !isPaid),
                  child: Row(
                    children: [
                      Icon(
                        isPaid
                            ? Icons.check_circle
                            : Icons.circle_outlined,
                        color: isPaid ? Colors.green : Colors.grey.shade400,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isPaid ? 'Pagado' : 'No pagado',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: isPaid ? Colors.green : Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // ── Category chips ──
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
                  children: existingCats
                      .where((c) => c.isNotEmpty)
                      .map(
                        (c) => GestureDetector(
                          onTap: () => setLocalState(() => category = c),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: category == c
                                  ? AppTheme.primary
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              c,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: category == c
                                    ? Colors.white
                                    : Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 12),

                // ── Segment picker ──
                Text(
                  'Pagado por',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: segments
                      .map(
                        (s) => GestureDetector(
                          onTap: () =>
                              setLocalState(() => segment = s.segmentKey),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: segment == s.segmentKey
                                  ? AppTheme.primary
                                  : s.color,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              '${s.emoji} ${s.label}',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: segment == s.segmentKey
                                    ? Colors.white
                                    : AppTheme.primary,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 20),

                // ── Save button ──
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final updates = <String, dynamic>{
                        'name': nameCtrl.text.trim(),
                        'estimated_cost':
                            double.tryParse(estimatedCtrl.text) ?? 0,
                        'actual_cost': double.tryParse(actualCtrl.text) ?? 0,
                        'segment': segment,
                        'category': category,
                        'is_paid': isPaid,
                      };
                      _updateItem(item['id'], updates);
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Guardar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddSegmentDialog(String? weddingId) {
    if (weddingId == null) return;
    final nameCtrl = TextEditingController();
    String emoji = '📋';
    String color = '#F3F4F6';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
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
              'Nuevo segmento',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                hintText: 'Nombre del segmento',
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
            // Emoji picker row
            Text(
              'Emoji',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 6),
            StatefulBuilder(
              builder: (ctx, setLocalState) => Wrap(
                spacing: 8,
                children:
                    [
                          '💍',
                          '👰',
                          '🤵',
                          '🤝',
                          '📋',
                          '🎉',
                          '🏠',
                          '💐',
                          '🍰',
                          '🎵',
                          '📷',
                          '✈️',
                          '💄',
                          '💎',
                          '🥂',
                          '🎁',
                          '❤️',
                          '⭐',
                          '🌸',
                          '🦋',
                        ]
                        .map(
                          (e) => GestureDetector(
                            onTap: () => setLocalState(() => emoji = e),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: emoji == e ? Colors.grey.shade200 : null,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                e,
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                          ),
                        )
                        .toList(),
              ),
            ),
            const SizedBox(height: 12),
            // Color picker row
            Text(
              'Color',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 6),
            StatefulBuilder(
              builder: (ctx, setLocalState) => Wrap(
                spacing: 8,
                children:
                    [
                          '#EDE9FE',
                          '#FCE7F3',
                          '#DBEAFE',
                          '#FFE4E6',
                          '#E0F2FE',
                          '#FEF3C7',
                          '#F3F4F6',
                          '#D1FAE5',
                          '#FEE2E2',
                          '#E0E7FF',
                          '#ECFCCB',
                        ]
                        .map(
                          (c) => GestureDetector(
                            onTap: () => setLocalState(() => color = c),
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: _hexToColor(c),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: color == c
                                      ? Colors.black
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (nameCtrl.text.trim().isNotEmpty) {
                    _addSegment(weddingId, nameCtrl.text.trim(), emoji, color);
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
    );
  }

  void _showEditSegmentDialog(BudgetSegment segment) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${segment.emoji} ${segment.label}',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  _deleteSegment(segment.id);
                  setState(() => _activeSegment = null);
                  Navigator.pop(ctx);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.error,
                  side: BorderSide(color: AppTheme.error.withOpacity(0.3)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Eliminar segmento'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddItemDialog(
    String? weddingId,
    List<BudgetSegment> segments,
    List<Map<String, dynamic>> items,
  ) {
    if (weddingId == null || segments.isEmpty) return;
    final nameCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    String category = '';
    String segment = _activeSegment ?? segments.first.segmentKey;

    // Existing categories
    final existingCats =
        items.map((i) => (i['category'] ?? '') as String).toSet().toList()
          ..sort();

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
                'Nuevo gasto',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              // Category chips
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
                  ...existingCats
                      .where((c) => c.isNotEmpty)
                      .map(
                        (c) => GestureDetector(
                          onTap: () => setLocalState(() => category = c),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: category == c
                                  ? AppTheme.primary
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              c,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: category == c
                                    ? Colors.white
                                    : Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ),
                      ),
                  GestureDetector(
                    onTap: () async {
                      final result = await showDialog<String>(
                        context: ctx,
                        builder: (dCtx) {
                          final ctrl = TextEditingController();
                          return AlertDialog(
                            title: const Text('Nueva categoría'),
                            content: TextField(
                              controller: ctrl,
                              autofocus: true,
                              decoration: const InputDecoration(
                                hintText: 'Ej: Transporte',
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(dCtx),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(dCtx, ctrl.text),
                                child: const Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                      if (result != null && result.trim().isNotEmpty) {
                        setLocalState(() => category = result.trim());
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '+ Nueva',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  hintText: 'Descripción',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Monto estimado',
                  suffixText: '\$',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Segment picker
              Text(
                'Pagado por',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: segments
                    .map(
                      (s) => GestureDetector(
                        onTap: () =>
                            setLocalState(() => segment = s.segmentKey),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: segment == s.segmentKey
                                ? AppTheme.primary
                                : s.color,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '${s.emoji} ${s.label}',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: segment == s.segmentKey
                                  ? Colors.white
                                  : AppTheme.primary,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (nameCtrl.text.trim().isNotEmpty &&
                        category.isNotEmpty) {
                      final amount = double.tryParse(amountCtrl.text) ?? 0;
                      _addItem(
                        weddingId,
                        nameCtrl.text.trim(),
                        category,
                        segment,
                        amount,
                      );
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
}

// ── Filter Chip ────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final Color? bgColor;

  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
    this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.primary
              : (bgColor ?? Colors.grey.shade100),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isActive ? Colors.white : AppTheme.primary,
          ),
        ),
      ),
    );
  }
}
