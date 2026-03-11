import 'package:flutter/cupertino.dart';
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
      backgroundColor: AppTheme.background, // Use global theme background
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
    
    // Style Mapping for dynamic background (local assets)
    final styleImages = {
      'clasico': 'assets/images/dashboard_bg_clasico.jpg',
      'boho': 'assets/images/dashboard_bg_boho.jpg',
      'moderno': 'assets/images/dashboard_bg_moderno.jpg',
      'rustico': 'assets/images/dashboard_bg_rustico.jpg',
      'playa': 'assets/images/dashboard_bg_playa.jpg',
      'romantico': 'assets/images/dashboard_bg_romantico.jpg',
    };

    final weddingStyle = wedding['style'] as String?;
    final bgImage = styleImages[weddingStyle] ?? 'assets/images/dashboard_bg_default.jpg'; 

    final tools = <_ToolItem>[
      _ToolItem(label: 'Checklist', icon: CupertinoIcons.check_mark_circled, path: '/checklist', color: const Color(0xFFD4A574)), // Gold
      _ToolItem(label: 'Presupuesto', icon: CupertinoIcons.money_dollar_circle, path: '/budget', color: const Color(0xFFE5A9A9)), // Soft Pink
      _ToolItem(label: 'Invitados', icon: CupertinoIcons.person_2, path: '/guests', color: const Color(0xFFA7C4BC)), // Sage
      _ToolItem(label: 'Agenda', icon: CupertinoIcons.calendar, path: '/timeline', color: const Color(0xFFDFD3C3)), // Cream/Beige
      _ToolItem(label: 'Mesas', icon: CupertinoIcons.square_grid_2x2, path: '/seating', color: const Color(0xFF9FA0C3)), // Lavender
      _ToolItem(label: 'Perfil', icon: CupertinoIcons.person_crop_circle, path: '/profile', color: const Color(0xFF8D8D8D)), // Grey
    ];

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 260.0,
          floating: false,
          pinned: true,
          backgroundColor: const Color(0xFFD4A574), // Gold fallback
          elevation: 0,
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  bgImage,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: const Color(0xFFD4A574).withOpacity(0.3), // Fallback color if image not found
                    child: const Center(child: Icon(CupertinoIcons.heart_fill, color: Colors.white)),
                  ),
                ),
                
                // Light overlay for text readability
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.0),
                        Colors.black.withOpacity(0.15),
                      ],
                    ),
                  ),
                ),

                // Content
                Positioned(
                  bottom: 20, // Adjusted for smaller header
                  left: 24,
                  right: 24,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Boda de',
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontSize: 12, // Smaller
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.2,
                                shadows: [const Shadow(offset: Offset(0, 1), blurRadius: 2, color: Colors.black26)],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              wedding['title'] ?? 'Nuestra Boda',
                              style: GoogleFonts.playfairDisplay(
                                color: Colors.white,
                                fontSize: 28, // Smaller title
                                fontWeight: FontWeight.w700,
                                shadows: [const Shadow(offset: Offset(0, 1), blurRadius: 4, color: Colors.black26)],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      if (daysLeft != null && daysLeft > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withOpacity(0.4), width: 1),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$daysLeft',
                                style: GoogleFonts.cormorantGaramond(
                                  color: Colors.white,
                                  fontSize: 22, // Smaller
                                  fontWeight: FontWeight.bold,
                                  height: 1.0,
                                ),
                              ),
                              Text(
                                daysLeft == 1 ? 'día' : 'días',
                                style: GoogleFonts.montserrat(
                                  color: Colors.white,
                                  fontSize: 10, 
                                  fontWeight: FontWeight.w600,
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
              color: AppTheme.background, 
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 40), // Reduced pairing
            child: GridView.builder( // Directly the grid, removed "Herramientas" title to be more minimalist
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12, // Reduced spacing
                mainAxisSpacing: 12, // Reduced spacing
                childAspectRatio: 1.4, // More rectangular (smaller height)
              ),
              itemCount: tools.length,
              itemBuilder: (context, index) {
                return _ToolCard(tool: tools[index]);
              },
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
          borderRadius: BorderRadius.circular(16), // Less rounded, more modern/minimal
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05), // Extremely subtle shadow
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              tool.icon,
              size: 26, // Smaller icon
              color: tool.color,
            ),
            const SizedBox(height: 10), // Reduced spacing
            Text(
              tool.label,
              style: GoogleFonts.montserrat(
                fontSize: 13, // Smaller text
                fontWeight: FontWeight.w500, // Regular weight
                color: const Color(0xFF4A4A4A), // Softer than black
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
