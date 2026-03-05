import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/providers/auth_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../wedding/data/wedding_providers.dart';

const _defaultBudgetSeed = [
  {'name': 'Renta del salón', 'category': 'Lugar', 'estimated_cost': 5000, 'sort_order': 0},
  {'name': 'Hospedaje', 'category': 'Lugar', 'estimated_cost': 1500, 'sort_order': 1},
  {'name': 'Comida y bebidas', 'category': 'Banquete', 'estimated_cost': 8000, 'sort_order': 2},
  {'name': 'Pastel', 'category': 'Banquete', 'estimated_cost': 500, 'sort_order': 3},
  {'name': 'Vestido / Traje', 'category': 'Vestuario', 'estimated_cost': 2000, 'sort_order': 4},
  {'name': 'Anillos', 'category': 'Vestuario', 'estimated_cost': 1000, 'sort_order': 5},
  {'name': 'Flores y decoración', 'category': 'Decoración', 'estimated_cost': 2000, 'sort_order': 6},
  {'name': 'DJ / Grupo musical', 'category': 'Música', 'estimated_cost': 1500, 'sort_order': 7},
  {'name': 'Fotógrafo', 'category': 'Foto', 'estimated_cost': 1800, 'sort_order': 8},
  {'name': 'Videógrafo', 'category': 'Foto', 'estimated_cost': 1200, 'sort_order': 9},
  {'name': 'Invitaciones', 'category': 'Varios', 'estimated_cost': 300, 'sort_order': 10},
  {'name': 'Recuerdos para invitados', 'category': 'Varios', 'estimated_cost': 400, 'sort_order': 11},
];

class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({super.key});

  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> {
  final _currencyFormat = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
  bool _seeded = false;

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

          final totalEstimated = items.fold<double>(
              0, (s, i) => s + ((i['estimated_cost'] as num?)?.toDouble() ?? 0));
          final totalActual = items.fold<double>(
              0, (s, i) => s + ((i['actual_cost'] as num?)?.toDouble() ?? 0));
          final totalBudget = totalEstimated;
          final remaining = totalBudget - totalActual;

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
                // Summary Card
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
                      const Text(
                        'Presupuesto total',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _currencyFormat.format(totalBudget),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _SummaryCell(
                              label: 'Gastado',
                              value: _currencyFormat.format(totalActual),
                              color: Colors.white,
                            ),
                          ),
                          Container(width: 1, height: 30, color: Colors.white30),
                          Expanded(
                            child: _SummaryCell(
                              label: 'Restante',
                              value: _currencyFormat.format(remaining),
                              color: remaining >= 0
                                  ? Colors.white
                                  : const Color(0xFFFCA5A5),
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
                    value: totalBudget > 0
                        ? (totalActual / totalBudget).clamp(0.0, 1.0)
                        : 0,
                    minHeight: 6,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation(
                      totalActual > totalBudget
                          ? AppTheme.error
                          : AppTheme.success,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Budget items by category
                ...categories.entries.map((entry) {
                  final catTotal = entry.value.fold<double>(
                      0,
                      (s, i) =>
                          s +
                          ((i['estimated_cost'] as num?)?.toDouble() ?? 0));
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Theme(
                      data: Theme.of(context)
                          .copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        title: Text(
                          entry.key,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        subtitle: Text(
                          _currencyFormat.format(catTotal),
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 13,
                          ),
                        ),
                        children: entry.value.map((item) {
                          final isPaid = item['is_paid'] == true;
                          final actual =
                              (item['actual_cost'] as num?)?.toDouble() ?? 0;
                          final estimated =
                              (item['estimated_cost'] as num?)?.toDouble() ?? 0;
                          return ListTile(
                            title: Text(
                              item['name'] ?? '',
                              style: const TextStyle(fontSize: 14),
                            ),
                            subtitle: Text(
                              'Estimado : ${_currencyFormat.format(estimated)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            trailing: isPaid
                                ? Chip(
                                    label: const Text('Pagado'),
                                    backgroundColor:
                                        AppTheme.success.withOpacity(0.1),
                                    labelStyle: TextStyle(
                                      color: AppTheme.success,
                                      fontSize: 12,
                                    ),
                                  )
                                : Text(
                                    _currencyFormat.format(actual),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
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
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 12),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
