import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/providers/auth_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../wedding/data/wedding_providers.dart';

// ── Segment definitions ────────────────────────────────────────
class BudgetSegment {
  final String id;
  final String label;
  final String emoji;
  final Color color;
  final Color textColor;

  const BudgetSegment({
    required this.id,
    required this.label,
    required this.emoji,
    required this.color,
    required this.textColor,
  });
}

const _segments = [
  BudgetSegment(id: 'couple',       label: 'La Pareja',          emoji: '💍', color: Color(0xFFEDE9FE), textColor: Color(0xFF6D28D9)),
  BudgetSegment(id: 'novia',        label: 'La Novia',           emoji: '👰', color: Color(0xFFFCE7F3), textColor: Color(0xFFBE185D)),
  BudgetSegment(id: 'novio',        label: 'El Novio',           emoji: '🤵', color: Color(0xFFDBEAFE), textColor: Color(0xFF1D4ED8)),
  BudgetSegment(id: 'padres_novia', label: 'Padres de la Novia', emoji: '👨‍👩‍👧', color: Color(0xFFFFE4E6), textColor: Color(0xFFBE123C)),
  BudgetSegment(id: 'padres_novio', label: 'Padres del Novio',   emoji: '👨‍👩‍👦', color: Color(0xFFE0F2FE), textColor: Color(0xFF0369A1)),
  BudgetSegment(id: 'padrinos',     label: 'Padrinos',           emoji: '🤝', color: Color(0xFFFEF3C7), textColor: Color(0xFFB45309)),
  BudgetSegment(id: 'otros',        label: 'Otro',               emoji: '📋', color: Color(0xFFF3F4F6), textColor: Color(0xFF4B5563)),
];

BudgetSegment _getSegment(String id) =>
    _segments.firstWhere((s) => s.id == id, orElse: () => _segments.first);

// ── Default seed with segments ─────────────────────────────────
const _defaultBudgetSeed = [
  // Couple
  {'name': 'Renta del salón',       'category': 'Lugar',      'segment': 'couple', 'estimated_cost': 5000, 'sort_order': 0},
  {'name': 'Hospedaje',             'category': 'Lugar',      'segment': 'couple', 'estimated_cost': 1500, 'sort_order': 1},
  {'name': 'Comida y bebidas',      'category': 'Banquete',   'segment': 'couple', 'estimated_cost': 8000, 'sort_order': 2},
  {'name': 'Invitaciones',          'category': 'Varios',     'segment': 'couple', 'estimated_cost': 300,  'sort_order': 3},
  {'name': 'Anillos',               'category': 'Accesorios', 'segment': 'couple', 'estimated_cost': 1000, 'sort_order': 4},
  {'name': 'Fotógrafo',             'category': 'Foto',       'segment': 'couple', 'estimated_cost': 1800, 'sort_order': 5},
  {'name': 'Videógrafo',            'category': 'Foto',       'segment': 'couple', 'estimated_cost': 1200, 'sort_order': 6},
  {'name': 'DJ / Grupo musical',    'category': 'Música',     'segment': 'couple', 'estimated_cost': 1500, 'sort_order': 7},
  {'name': 'Flores y decoración',   'category': 'Decoración', 'segment': 'couple', 'estimated_cost': 2000, 'sort_order': 8},
  // Novia
  {'name': 'Vestido de novia',      'category': 'Vestuario',  'segment': 'novia',  'estimated_cost': 2500, 'sort_order': 9},
  {'name': 'Peinado y maquillaje',  'category': 'Belleza',    'segment': 'novia',  'estimated_cost': 500,  'sort_order': 10},
  {'name': 'Accesorios (velo, zapatos)', 'category': 'Vestuario', 'segment': 'novia', 'estimated_cost': 400, 'sort_order': 11},
  {'name': 'Ramo de la novia',      'category': 'Flores',     'segment': 'novia',  'estimated_cost': 200,  'sort_order': 12},
  // Novio
  {'name': 'Traje del novio',       'category': 'Vestuario',  'segment': 'novio',  'estimated_cost': 800,  'sort_order': 13},
  {'name': 'Zapatos + accesorios',  'category': 'Vestuario',  'segment': 'novio',  'estimated_cost': 300,  'sort_order': 14},
  {'name': 'Boutonnière',           'category': 'Flores',     'segment': 'novio',  'estimated_cost': 50,   'sort_order': 15},
  // Padres Novia
  {'name': 'Ceremonia religiosa',   'category': 'Ceremonia',  'segment': 'padres_novia', 'estimated_cost': 500, 'sort_order': 16},
  {'name': 'Pastel',                'category': 'Banquete',   'segment': 'padres_novia', 'estimated_cost': 500, 'sort_order': 17},
  // Padres Novio
  {'name': 'Brindis champagne',     'category': 'Bebidas',    'segment': 'padres_novio', 'estimated_cost': 600, 'sort_order': 18},
  {'name': 'Recuerdos para invitados', 'category': 'Varios',  'segment': 'padres_novio', 'estimated_cost': 400, 'sort_order': 19},
];

class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({super.key});

  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> {
  final _currencyFormat = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
  bool _seeded = false;
  String? _activeSegment; // null = show all

  Future<void> _seedDefaults(String weddingId) async {
    if (_seeded) return;
    _seeded = true;
    final supabase = ref.read(supabaseProvider);
    final rows = _defaultBudgetSeed
        .map((item) => {
              ...item,
              'wedding_id': weddingId,
              'actual_cost': 0,
              'is_paid': false,
            })
        .toList();
    await supabase.from('wedding_budget_items').insert(rows);
    ref.invalidate(weddingBudgetProvider);
  }

  @override
  Widget build(BuildContext context) {
    final weddingAsync = ref.watch(weddingProvider);
    final budgetAsync = ref.watch(weddingBudgetProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Presupuesto'),
        centerTitle: false,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: budgetAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (items) {
          final wedding = weddingAsync.value;
          if (items.isEmpty && wedding != null) {
            Future.microtask(() => _seedDefaults(wedding['id']));
            return const Center(child: CircularProgressIndicator());
          }

          // ── Filtered items ──
          final displayItems = _activeSegment == null
              ? items
              : items.where((i) => i['segment'] == _activeSegment).toList();

          // ── Global totals ──
          final totalEstimated = items.fold<double>(
              0, (s, i) => s + ((i['estimated_cost'] as num?)?.toDouble() ?? 0));
          final totalActual = items.fold<double>(
              0, (s, i) => s + ((i['actual_cost'] as num?)?.toDouble() ?? 0));
          final totalBudget = totalEstimated;
          final remaining = totalBudget - totalActual;

          // ── Segment summaries ──
          final segmentSummaries = <String, Map<String, dynamic>>{};
          for (final seg in _segments) {
            final segItems = items.where((i) => i['segment'] == seg.id).toList();
            if (segItems.isEmpty && seg.id != 'couple') continue;
            final est = segItems.fold<double>(0, (s, i) => s + ((i['estimated_cost'] as num?)?.toDouble() ?? 0));
            final act = segItems.fold<double>(0, (s, i) => s + ((i['actual_cost'] as num?)?.toDouble() ?? 0));
            segmentSummaries[seg.id] = {
              'segment': seg,
              'estimated': est,
              'actual': act,
              'count': segItems.length,
              'percentage': totalEstimated > 0 ? (est / totalEstimated * 100) : 0.0,
            };
          }

          // ── Group displayed items by category ──
          final categories = <String, List<Map<String, dynamic>>>{};
          for (final item in displayItems) {
            final cat = (item['category'] ?? 'Otro') as String;
            categories.putIfAbsent(cat, () => []).add(item);
          }

          final activeSeg = _activeSegment != null ? segmentSummaries[_activeSegment] : null;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Summary Card ──
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF10B981),
                        const Color(0xFF10B981).withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Text('Presupuesto total',
                          style: TextStyle(color: Colors.white70, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text(_currencyFormat.format(totalBudget),
                          style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _SummaryCell(label: 'Gastado', value: _currencyFormat.format(totalActual), color: Colors.white)),
                          Container(width: 1, height: 30, color: Colors.white30),
                          Expanded(
                            child: _SummaryCell(
                              label: 'Restante',
                              value: _currencyFormat.format(remaining),
                              color: remaining >= 0 ? Colors.white : const Color(0xFFFCA5A5),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: totalBudget > 0 ? (totalActual / totalBudget).clamp(0.0, 1.0) : 0,
                    minHeight: 6,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation(totalActual > totalBudget ? AppTheme.error : AppTheme.success),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Segment Chips ──
                const Text('¿Quién paga qué?',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF6B7280))),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _SegmentChip(
                      label: '✨ Todos',
                      subtitle: _currencyFormat.format(totalEstimated),
                      isActive: _activeSegment == null,
                      color: Colors.grey.shade800,
                      bgColor: _activeSegment == null ? Colors.grey.shade800 : Colors.white,
                      textColor: _activeSegment == null ? Colors.white : Colors.grey.shade800,
                      onTap: () => setState(() => _activeSegment = null),
                    ),
                    ...segmentSummaries.entries.map((entry) {
                      final seg = entry.value['segment'] as BudgetSegment;
                      final est = entry.value['estimated'] as double;
                      final pct = entry.value['percentage'] as double;
                      final isActive = _activeSegment == seg.id;
                      return _SegmentChip(
                        label: '${seg.emoji} ${seg.label}',
                        subtitle: '${_currencyFormat.format(est)} (${pct.round()}%)',
                        isActive: isActive,
                        color: seg.textColor,
                        bgColor: isActive ? seg.color : Colors.white,
                        textColor: isActive ? seg.textColor : Colors.grey.shade700,
                        onTap: () => setState(() => _activeSegment = isActive ? null : seg.id),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Active Segment Detail ──
                if (activeSeg != null) ...[
                  _SegmentDetailCard(
                    segment: activeSeg['segment'] as BudgetSegment,
                    estimated: activeSeg['estimated'] as double,
                    actual: activeSeg['actual'] as double,
                    count: activeSeg['count'] as int,
                    currencyFormat: _currencyFormat,
                  ),
                  const SizedBox(height: 20),
                ],

                // ── Contribution bars (when showing all) ──
                if (_activeSegment == null && segmentSummaries.length > 1) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Contribución por segmento',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.grey.shade600)),
                        const SizedBox(height: 12),
                        ...segmentSummaries.entries.map((entry) {
                          final seg = entry.value['segment'] as BudgetSegment;
                          final pct = entry.value['percentage'] as double;
                          final est = entry.value['estimated'] as double;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                SizedBox(width: 28, child: Text(seg.emoji, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16))),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 2,
                                  child: Text(seg.label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 3,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: (pct / 100).clamp(0.0, 1.0),
                                      minHeight: 8,
                                      backgroundColor: Colors.grey.shade100,
                                      valueColor: AlwaysStoppedAnimation(seg.color),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 80,
                                  child: Text(_currencyFormat.format(est),
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // ── Budget items by category ──
                ...categories.entries.map((entry) {
                  final catTotal = entry.value.fold<double>(
                      0, (s, i) => s + ((i['estimated_cost'] as num?)?.toDouble() ?? 0));
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        title: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                        subtitle: Text(_currencyFormat.format(catTotal),
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                        children: entry.value.map((item) {
                          final isPaid = item['is_paid'] == true;
                          final actual = (item['actual_cost'] as num?)?.toDouble() ?? 0;
                          final estimated = (item['estimated_cost'] as num?)?.toDouble() ?? 0;
                          final seg = _getSegment((item['segment'] ?? 'couple') as String);
                          return ListTile(
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(item['name'] ?? '', style: const TextStyle(fontSize: 14)),
                                ),
                                if (_activeSegment == null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: seg.color,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '${seg.emoji} ${seg.label}',
                                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: seg.textColor),
                                    ),
                                  ),
                              ],
                            ),
                            subtitle: Text(
                              'Estimado: ${_currencyFormat.format(estimated)}',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                            ),
                            trailing: isPaid
                                ? Chip(
                                    label: const Text('Pagado'),
                                    backgroundColor: AppTheme.success.withOpacity(0.1),
                                    labelStyle: TextStyle(color: AppTheme.success, fontSize: 12),
                                  )
                                : Text(_currencyFormat.format(actual),
                                    style: const TextStyle(fontWeight: FontWeight.w600)),
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

// ── Segment Chip Widget ──────────────────────────────────────
class _SegmentChip extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool isActive;
  final Color color;
  final Color bgColor;
  final Color textColor;
  final VoidCallback onTap;

  const _SegmentChip({
    required this.label,
    required this.subtitle,
    required this.isActive,
    required this.color,
    required this.bgColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isActive ? color : Colors.grey.shade200),
          boxShadow: isActive
              ? [BoxShadow(color: color.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 2))]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textColor)),
            const SizedBox(height: 2),
            Text(subtitle, style: TextStyle(fontSize: 10, color: textColor.withOpacity(0.7))),
          ],
        ),
      ),
    );
  }
}

// ── Segment Detail Card ──────────────────────────────────────
class _SegmentDetailCard extends StatelessWidget {
  final BudgetSegment segment;
  final double estimated;
  final double actual;
  final int count;
  final NumberFormat currencyFormat;

  const _SegmentDetailCard({
    required this.segment,
    required this.estimated,
    required this.actual,
    required this.count,
    required this.currencyFormat,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: segment.color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(segment.emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(segment.label,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: segment.textColor)),
                  Text('$count gasto${count > 1 ? 's' : ''}',
                      style: TextStyle(fontSize: 12, color: segment.textColor.withOpacity(0.6))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _MiniStat(label: 'Estimado', value: currencyFormat.format(estimated), color: segment.textColor),
              ),
              Container(width: 1, height: 30, color: segment.textColor.withOpacity(0.15)),
              Expanded(
                child: _MiniStat(label: 'Gastado', value: currencyFormat.format(actual), color: segment.textColor),
              ),
              Container(width: 1, height: 30, color: segment.textColor.withOpacity(0.15)),
              Expanded(
                child: _MiniStat(
                  label: 'Restante',
                  value: currencyFormat.format(estimated - actual),
                  color: actual > estimated ? const Color(0xFFEF4444) : segment.textColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MiniStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 10, color: color.withOpacity(0.6))),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
      ],
    );
  }
}

class _SummaryCell extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryCell({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 16)),
      ],
    );
  }
}
