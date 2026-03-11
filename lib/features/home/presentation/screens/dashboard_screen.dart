import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../wedding/data/wedding_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weddingAsync = ref.watch(weddingProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0), // Fond légèrement crème/gris très doux
      body: weddingAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (wedding) {
          if (wedding == null) {
            return _NoWeddingView();
          }
          return _WeddingDashboard(wedding: wedding);
        },
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
    // Removed unused formattedDate and venue for this version

    final tools = <_ToolItem>[
      _ToolItem(label: 'Checklist', icon: Icons.playlist_add_check_circle_outlined, path: '/checklist', color: const Color(0xFF7B8FA1)),
      _ToolItem(label: 'Presupuesto', icon: Icons.account_balance_wallet_outlined, path: '/budget', color: const Color(0xFFD4A373)),
      _ToolItem(label: 'Invitados', icon: Icons.people_outline_rounded, path: '/guests', color: const Color(0xFF90A17D)),
      _ToolItem(label: 'Agenda', icon: Icons.calendar_today_rounded, path: '/timeline', color: const Color(0xFFA5A58D)),
      _ToolItem(label: 'Mesas', icon: Icons.table_restaurant_outlined, path: '/seating', color: const Color(0xFFB7B7A4)),
      _ToolItem(label: 'Perfil', icon: Icons.person_outline_rounded, path: '/profile', color: const Color(0xFF6B705C)),
    ];

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 280.0,
          floating: false,
          pinned: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                // Image de fond élégante
                CachedNetworkImage(
                  imageUrl: "https://images.unsplash.com/photo-1519225421980-715cb0202128?q=80&w=1000&auto=format&fit=crop",
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: Colors.grey[200]),
                  errorWidget: (context, url, error) => Container(color: Colors.grey[200]),
                ),
                // Overlay gradient pour la lisibilité
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.1),
                        Colors.black.withOpacity(0.5),
                      ],
                    ),
                  ),
                ),
                // Contenu du Header
                Positioned(
                  bottom: 40,
                  left: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Boda de',
                        style: GoogleFonts.montserrat(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        wedding['title'] ?? 'Nuestra Boda',
                        style: GoogleFonts.playfairDisplay(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (daysLeft != null && daysLeft > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.white.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$daysLeft',
                                style: GoogleFonts.cormorantGaramond(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                daysLeft == 1 ? 'DÍA RESTANTE' : 'DÍAS RESTANTES',
                                style: GoogleFonts.montserrat(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        
        SliverToBoxAdapter(
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF5F5F0), // Doit matcher le Scaffold backgroundColor
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Herramientas',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 20),
                GridView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: tools.length,
                  itemBuilder: (context, index) {
                    return _ToolCard(tool: tools[index]);
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ToolItem {
  final String label;
  final IconData icon;
  final String path;
  final Color color;

  const _ToolItem({
    required this.label, 
    required this.icon, 
    required this.path,
    required this.color,
  });
}

class _ToolCard extends StatelessWidget {
  final _ToolItem tool;

  const _ToolCard({required this.tool});

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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: tool.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                tool.icon,
                size: 28,
                color: tool.color,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              tool.label,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF2C3E50),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
