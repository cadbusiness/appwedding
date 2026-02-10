import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/auth_providers.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../wedding/data/wedding_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weddingAsync = ref.watch(weddingProvider);
    final profile = ref.watch(userProfileProvider);
    final guestStats = ref.watch(guestStatsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
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
                  Text('Erreur: $e', textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(weddingProvider),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            ),
          ),
          data: (wedding) {
            if (wedding == null) {
              return _NoWeddingView();
            }
            return _WeddingDashboard(
              wedding: wedding,
              profileName: profile.value?['full_name'] ?? 'Couple',
              guestStats: guestStats,
            );
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
        title: 'Bienvenue !',
        subtitle: "Créez votre mariage pour commencer l'organisation",
        actionLabel: 'Créer mon mariage',
        onAction: () => context.push('/wedding/create'),
      ),
    );
  }
}

class _WeddingDashboard extends StatelessWidget {
  final Map<String, dynamic> wedding;
  final String profileName;
  final Map<String, int> guestStats;

  const _WeddingDashboard({
    required this.wedding,
    required this.profileName,
    required this.guestStats,
  });

  @override
  Widget build(BuildContext context) {
    // DB column is "wedding_date" not "date"
    final weddingDate = wedding['wedding_date'] != null
        ? DateTime.tryParse(wedding['wedding_date'].toString())
        : null;
    final daysLeft = weddingDate != null
        ? weddingDate.difference(DateTime.now()).inDays
        : null;
    final dateFormatted = weddingDate != null
        ? DateFormat('d MMMM yyyy', 'fr_FR').format(weddingDate)
        : 'Date non définie';

    return RefreshIndicator(
      onRefresh: () async {},
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bonjour $profileName 💍',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        wedding['title'] ?? 'Mon mariage',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => context.push('/profile'),
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: AppTheme.primary.withOpacity(0.1),
                    child: Icon(
                      Icons.person_rounded,
                      color: AppTheme.primary,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Countdown Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primary, AppTheme.primary.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(Icons.favorite_rounded, color: Colors.white, size: 32),
                  const SizedBox(height: 12),
                  if (daysLeft != null) ...[
                    Text(
                      '${daysLeft > 0 ? daysLeft : 0}',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      daysLeft > 0 ? 'jours restants' : 'Le jour J est arrivé ! 🎉',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    dateFormatted,
                    style: const TextStyle(fontSize: 14, color: Colors.white60),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Quick Stats
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.people_rounded,
                    label: 'Invités',
                    value: '${guestStats['total']}',
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.check_circle_rounded,
                    label: 'Confirmés',
                    value: '${guestStats['confirmed']}',
                    color: AppTheme.success,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.schedule_rounded,
                    label: 'En attente',
                    value: '${guestStats['pending']}',
                    color: AppTheme.warning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Quick Actions
            Text('Outils', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.4,
              children: [
                _QuickAction(
                  icon: Icons.checklist_rounded,
                  label: 'Check-list',
                  subtitle: 'Tâches à faire',
                  color: const Color(0xFF6366F1),
                  onTap: () => context.go('/checklist'),
                ),
                _QuickAction(
                  icon: Icons.account_balance_wallet_rounded,
                  label: 'Budget',
                  subtitle: 'Suivi dépenses',
                  color: const Color(0xFF10B981),
                  onTap: () => context.go('/budget'),
                ),
                _QuickAction(
                  icon: Icons.people_rounded,
                  label: 'Invités',
                  subtitle: 'Liste & RSVP',
                  color: const Color(0xFFF59E0B),
                  onTap: () => context.go('/guests'),
                ),
                _QuickAction(
                  icon: Icons.table_restaurant_rounded,
                  label: 'Plan de table',
                  subtitle: 'Placement',
                  color: const Color(0xFFEC4899),
                  onTap: () => context.push('/seating'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Venue info
            if (wedding['venue'] != null) ...[
              AppCard(
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.location_on_rounded, color: AppTheme.primary, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Lieu de réception', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          Text(
                            wedding['venue'],
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({required this.icon, required this.label, required this.subtitle, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 10),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            Text(subtitle, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
