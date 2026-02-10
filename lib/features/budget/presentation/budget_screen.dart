import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';

class _BudgetItem {
  final String category;
  final String label;
  final double estimated;
  double actual;
  bool paid;

  _BudgetItem({
    required this.category,
    required this.label,
    required this.estimated,
    this.actual = 0,
    this.paid = false,
  });
}

class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({super.key});

  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> {
  double _totalBudget = 25000;
  final _currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: '€');

  final List<_BudgetItem> _items = [
    _BudgetItem(category: 'Lieu', label: 'Location salle', estimated: 5000),
    _BudgetItem(category: 'Lieu', label: 'Hébergement', estimated: 1500),
    _BudgetItem(category: 'Traiteur', label: 'Repas & boissons', estimated: 8000),
    _BudgetItem(category: 'Traiteur', label: 'Gâteau', estimated: 500),
    _BudgetItem(category: 'Tenues', label: 'Robe / Costume', estimated: 2000),
    _BudgetItem(category: 'Tenues', label: 'Alliances', estimated: 1000),
    _BudgetItem(category: 'Déco', label: 'Fleurs & déco', estimated: 2000),
    _BudgetItem(category: 'Musique', label: 'DJ / Orchestre', estimated: 1500),
    _BudgetItem(category: 'Photo', label: 'Photographe', estimated: 1800),
    _BudgetItem(category: 'Photo', label: 'Vidéaste', estimated: 1200),
    _BudgetItem(category: 'Divers', label: 'Faire-part', estimated: 300),
    _BudgetItem(category: 'Divers', label: 'Cadeaux invités', estimated: 400),
  ];

  @override
  Widget build(BuildContext context) {
    final totalEstimated = _items.fold<double>(0, (s, i) => s + i.estimated);
    final totalActual = _items.fold<double>(0, (s, i) => s + i.actual);
    final remaining = _totalBudget - totalActual;

    // Group by category
    final categories = <String, List<_BudgetItem>>{};
    for (final item in _items) {
      categories.putIfAbsent(item.category, () => []).add(item);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Budget'),
        centerTitle: false,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
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
                    'Budget total',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _currencyFormat.format(_totalBudget),
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
                          label: 'Dépensé',
                          value: _currencyFormat.format(totalActual),
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 30,
                        color: Colors.white30,
                      ),
                      Expanded(
                        child: _SummaryCell(
                          label: 'Restant',
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
            // Progress
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: totalActual / _totalBudget,
                minHeight: 6,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation(
                  totalActual > _totalBudget ? AppTheme.error : AppTheme.success,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Budget items by category
            ...categories.entries.map((entry) {
              final catTotal =
                  entry.value.fold<double>(0, (s, i) => s + i.estimated);
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
                      return ListTile(
                        title: Text(
                          item.label,
                          style: const TextStyle(fontSize: 14),
                        ),
                        subtitle: Text(
                          'Estimé: ${_currencyFormat.format(item.estimated)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        trailing: item.paid
                            ? Chip(
                                label: const Text('Payé'),
                                backgroundColor: AppTheme.success.withOpacity(0.1),
                                labelStyle: TextStyle(
                                  color: AppTheme.success,
                                  fontSize: 12,
                                ),
                              )
                            : Text(
                                _currencyFormat.format(item.actual),
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
