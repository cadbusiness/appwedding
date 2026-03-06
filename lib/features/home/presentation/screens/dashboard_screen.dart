import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../wedding/data/wedding_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weddingAsync = ref.watch(weddingProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: weddingAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
                  const SizedBox(height: 16),
                  Text('Error: $e', textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(weddingProvider),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          ),
          data: (wedding) {
            if (wedding == null) {
              return _NoWeddingView();
            }
            return _WeddingDashboard(wedding: wedding);
          },
        ),
      ),
    );
  }
}

class _NoWeddingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: EmptyState(
        icon: Icons.favorite_border_rounded,
        title: '¡Bienvenido!',
        subtitle: 'Crea tu boda para comenzar a organizarla',
        actionLabel: 'Crear mi boda',
        onAction: () => context.push('/wedding/create'),
      ),
    );
  }
}

class _WeddingDashboard extends StatelessWidget {
  final Map<String, dynamic> wedding;

  const _WeddingDashboard({required this.wedding});

  @override
  Widget build(BuildContext context) {
    final weddingDate = wedding['wedding_date'] != null
        ? DateTime.tryParse(wedding['wedding_date'].toString())
        : null;
    final daysLeft = weddingDate?.difference(DateTime.now()).inDays;
    final dateFormatted = weddingDate != null
        ? DateFormat('d MMMM yyyy', 'es_MX').format(weddingDate)
        : null;
    final venue = wedding['venue'] as String?;

    final tools = <_ToolItem>[
      _ToolItem(label: 'Checklist', icon: Icons.checklist_rounded, path: '/checklist'),
      _ToolItem(label: 'Presupuesto', icon: Icons.account_balance_wallet_outlined, path: '/budget'),
      _ToolItem(label: 'Invitados', icon: Icons.people_outline_rounded, path: '/guests'),
      _ToolItem(label: 'Agenda del día', icon: Icons.calendar_today_rounded, path: '/timeline'),
      _ToolItem(label: 'Asignación de mesas', icon: Icons.table_restaurant_outlined, path: '/seating'),
      _ToolItem(label: 'Mi perfil', icon: Icons.person_outline_rounded, path: '/profile'),
    ];

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 24),

          // ─── Title ───
          Text(
            wedding['title'] ?? 'Mi boda',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: AppTheme.primary,
            ),
            textAlign: TextAlign.center,
          ),

          // ─── Countdown ───
          if (daysLeft != null && daysLeft > 0) ...[
            const SizedBox(height: 20),
            Text(
              '$daysLeft',
              style: const TextStyle(
                fontSize: 52,
                fontWeight: FontWeight.w700,
                color: AppTheme.primary,
                height: 1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              daysLeft == 1 ? 'día restante' : 'días restantes',
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.muted,
              ),
            ),
          ],
          if (daysLeft != null && daysLeft <= 0)
            const Padding(
              padding: EdgeInsets.only(top: 20),
              child: Text(
                '¡Felicidades! 💍',
                style: TextStyle(fontSize: 18, color: AppTheme.muted),
              ),
            ),

          // ─── Date & Venue ───
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (dateFormatted != null) ...[
                const Icon(Icons.calendar_today_rounded, size: 14, color: AppTheme.muted),
                const SizedBox(width: 4),
                Text(
                  dateFormatted,
                  style: const TextStyle(fontSize: 13, color: AppTheme.muted),
                ),
              ],
              if (dateFormatted != null && venue != null)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text('·', style: TextStyle(color: AppTheme.muted)),
                ),
              if (venue != null) ...[
                const Icon(Icons.location_on_outlined, size: 14, color: AppTheme.muted),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    venue,
                    style: const TextStyle(fontSize: 13, color: AppTheme.muted),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),

          // ─── Tools list ───
          const SizedBox(height: 36),
          ...tools.map((tool) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _ToolRow(tool: tool),
          )),
        ],
      ),
    );
  }
}

class _ToolItem {
  final String label;
  final IconData icon;
  final String path;

  const _ToolItem({required this.label, required this.icon, required this.path});
}

class _ToolRow extends StatelessWidget {
  final _ToolItem tool;

  const _ToolRow({required this.tool});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (tool.path == '/seating' || tool.path == '/profile') {
          context.push(tool.path);
        } else {
          context.go(tool.path);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Icon(tool.icon, size: 20, color: AppTheme.muted),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                tool.label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.primary,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: Colors.grey.shade300,
            ),
          ],
        ),
      ),
    );
  }
}
