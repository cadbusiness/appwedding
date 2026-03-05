import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';

/// Immersive onboarding that makes you feel like you're already
/// creating your wedding. Data is stored temporarily and carried
/// over to the registration / create-wedding flow.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;
  static const _totalPages = 4;

  // ── Collected data ────────────────────────────────────────────
  final _partner1 = TextEditingController();
  final _partner2 = TextEditingController();
  DateTime? _date;
  String? _style;
  int _guestCount = 100;

  @override
  void dispose() {
    _controller.dispose();
    _partner1.dispose();
    _partner2.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < _totalPages - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      final title = (_partner1.text.trim().isNotEmpty &&
              _partner2.text.trim().isNotEmpty)
          ? 'Boda de ${_partner1.text.trim()} & ${_partner2.text.trim()}'
          : null;

      context.go('/register', extra: {
        'wedding_title': title,
        'wedding_date': _date?.toIso8601String(),
        'wedding_style': _style,
        'guest_count': _guestCount,
      });
    }
  }

  Future<void> _pickDate() async {
    HapticFeedback.lightImpact();
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 180)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2032),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppTheme.primary,
            onSurface: Colors.black87,
          ),
        ),
        child: child!,
      ),
    );
    if (d != null) setState(() => _date = d);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar – progress + login link
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: List.generate(_totalPages, (i) {
                        return Expanded(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 350),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            height: 4,
                            decoration: BoxDecoration(
                              color: i <= _currentPage
                                  ? AppTheme.primary
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: Text(
                      'Iniciar sesión',
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Pages
            Expanded(
              child: PageView(
                controller: _controller,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _WelcomePage(onStart: _next),
                  _NamesPage(
                    partner1: _partner1,
                    partner2: _partner2,
                  ),
                  _DatePage(
                    date: _date,
                    onPickDate: _pickDate,
                    guestCount: _guestCount,
                    onGuestCountChanged: (v) =>
                        setState(() => _guestCount = v),
                  ),
                  _StylePage(
                    selected: _style,
                    onSelected: (v) => setState(() => _style = v),
                  ),
                ],
              ),
            ),

            // Bottom button (hidden on welcome page – it has its own)
            if (_currentPage > 0)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _canProceed ? _next : null,
                    child: Text(
                      _currentPage < _totalPages - 1
                          ? 'Siguiente'
                          : '¡Crear mi boda! 🎉',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  bool get _canProceed {
    switch (_currentPage) {
      case 1:
        return _partner1.text.trim().isNotEmpty &&
            _partner2.text.trim().isNotEmpty;
      case 2:
        return _date != null;
      case 3:
        return _style != null;
      default:
        return true;
    }
  }
}

// ═══════════════════════════════════════════════════════════════
// PAGE 0 – Welcome / Hero
// ═══════════════════════════════════════════════════════════════
class _WelcomePage extends StatelessWidget {
  final VoidCallback onStart;
  const _WelcomePage({required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primary.withOpacity(0.08),
                  const Color(0xFFD4A574).withOpacity(0.12),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('💒', style: TextStyle(fontSize: 64)),
            ),
          ),
          const SizedBox(height: 40),
          Text(
            '¡Organiza la boda\nde tus sueños!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            'Checklist, presupuesto, invitados, agenda…\nTodo en un solo lugar.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey.shade500,
                  height: 1.5,
                ),
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onStart,
              child: const Text(
                'Empezar a planear 💍',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => context.go('/login'),
            child: Text(
              'Ya tengo una cuenta',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// PAGE 1 – Names
// ═══════════════════════════════════════════════════════════════
class _NamesPage extends StatelessWidget {
  final TextEditingController partner1;
  final TextEditingController partner2;
  const _NamesPage({required this.partner1, required this.partner2});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text('💑', style: TextStyle(fontSize: 56)),
          ),
          const SizedBox(height: 24),
          Text(
            '¿Quiénes se casan?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Cuéntanos los nombres de los novios',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
          ),
          const SizedBox(height: 32),
          TextFormField(
            controller: partner1,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: 'Nombre del novio/a',
              hintText: 'ej: María',
              prefixIcon: Icon(Icons.favorite_outline_rounded,
                  size: 20, color: AppTheme.primary),
            ),
            onChanged: (_) => (context as Element).markNeedsBuild(),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: partner2,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: 'Nombre del novio/a',
              hintText: 'ej: Pedro',
              prefixIcon: Icon(Icons.favorite_outline_rounded,
                  size: 20, color: AppTheme.primary),
            ),
            onChanged: (_) => (context as Element).markNeedsBuild(),
          ),
          const SizedBox(height: 32),
          if (partner1.text.trim().isNotEmpty &&
              partner2.text.trim().isNotEmpty)
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.primary.withOpacity(0.15),
                  ),
                ),
                child: Text(
                  '${partner1.text.trim()} & ${partner2.text.trim()} 💍',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// PAGE 2 – Date + Guest count
// ═══════════════════════════════════════════════════════════════
class _DatePage extends StatelessWidget {
  final DateTime? date;
  final VoidCallback onPickDate;
  final int guestCount;
  final ValueChanged<int> onGuestCountChanged;

  const _DatePage({
    required this.date,
    required this.onPickDate,
    required this.guestCount,
    required this.onGuestCountChanged,
  });

  @override
  Widget build(BuildContext context) {
    final daysUntil =
        date != null ? date!.difference(DateTime.now()).inDays : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text('📅', style: TextStyle(fontSize: 56)),
          ),
          const SizedBox(height: 24),
          Text(
            '¿Cuándo es el gran día?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Selecciona la fecha de tu boda',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: onPickDate,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: date != null
                    ? AppTheme.primary.withOpacity(0.06)
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: date != null
                      ? AppTheme.primary.withOpacity(0.2)
                      : Colors.grey.shade200,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_month_rounded,
                      color: AppTheme.primary, size: 28),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          date != null
                              ? DateFormat('d MMMM yyyy', 'es_MX')
                                  .format(date!)
                              : 'Toca para elegir la fecha',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color:
                                date != null ? Colors.black87 : Colors.grey,
                          ),
                        ),
                        if (daysUntil != null && daysUntil > 0) ...[
                          const SizedBox(height: 4),
                          Text(
                            '¡Faltan $daysUntil días! 🎉',
                            style: TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
          Text(
            '¿Cuántos invitados esperas?',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('👥', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Text(
                '$guestCount invitados',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
          Slider(
            value: guestCount.toDouble(),
            min: 10,
            max: 500,
            divisions: 49,
            activeColor: AppTheme.primary,
            label: '$guestCount',
            onChanged: (v) => onGuestCountChanged(v.round()),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('10', style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
              Text('500', style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// PAGE 3 – Style / Theme
// ═══════════════════════════════════════════════════════════════
class _StylePage extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onSelected;
  const _StylePage({required this.selected, required this.onSelected});

  static const _styles = [
    _WeddingStyle(id: 'clasico', emoji: '🏛️', label: 'Clásico', desc: 'Elegante y atemporal'),
    _WeddingStyle(id: 'boho', emoji: '🌿', label: 'Boho', desc: 'Natural y relajado'),
    _WeddingStyle(id: 'moderno', emoji: '✨', label: 'Moderno', desc: 'Minimalista y chic'),
    _WeddingStyle(id: 'rustico', emoji: '🌾', label: 'Rústico', desc: 'Campo y calidez'),
    _WeddingStyle(id: 'playa', emoji: '🏖️', label: 'Playa', desc: 'Arena, sol y mar'),
    _WeddingStyle(id: 'romantico', emoji: '🌹', label: 'Romántico', desc: 'Flores y velas'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text('🎨', style: TextStyle(fontSize: 56)),
          ),
          const SizedBox(height: 24),
          Text(
            '¿Qué estilo te inspira?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Elige el estilo que más te represente',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
          ),
          const SizedBox(height: 28),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: _styles.map((style) {
              final isSelected = selected == style.id;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onSelected(style.id);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primary.withOpacity(0.08)
                        : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.primary
                          : Colors.grey.shade200,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(style.emoji,
                          style: const TextStyle(fontSize: 32)),
                      const SizedBox(height: 8),
                      Text(
                        style.label,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: isSelected
                              ? AppTheme.primary
                              : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        style.desc,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _WeddingStyle {
  final String id;
  final String emoji;
  final String label;
  final String desc;
  const _WeddingStyle({
    required this.id,
    required this.emoji,
    required this.label,
    required this.desc,
  });
}
