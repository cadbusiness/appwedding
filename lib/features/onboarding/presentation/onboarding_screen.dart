import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/app_constants.dart';
import '../../../core/theme/app_theme.dart';

/// Immersive onboarding → signup in one smooth flow.
/// No separate register screen needed.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;
  static const _totalPages = 5;

  // ── Collected data ────────────────────────────────────────────
  final _partner1 = TextEditingController();
  final _partner2 = TextEditingController();
  final _emailController = TextEditingController();
  DateTime? _date;
  String? _style;
  int _guestCount = 100;

  bool _loading = false;
  String? _generatedPin;

  @override
  void dispose() {
    _controller.dispose();
    _partner1.dispose();
    _partner2.dispose();
    _emailController.dispose();
    super.dispose();
  }

  String _generatePin() {
    final rng = Random.secure();
    return List.generate(6, (_) => rng.nextInt(10)).join();
  }

  void _next() {
    if (_currentPage < _totalPages - 1) {
      if (_currentPage == 2) {
        _signUp();
        return;
      }
      _controller.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      _updateWeddingData();
    }
  }

  Future<void> _signUp() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) return;

    setState(() => _loading = true);
    _generatedPin = _generatePin();

    final title = (_partner1.text.trim().isNotEmpty &&
            _partner2.text.trim().isNotEmpty)
        ? 'Boda de ${_partner1.text.trim()} & ${_partner2.text.trim()}'
        : 'Mi boda';

    try {
      final res = await Supabase.instance.client.auth.signUp(
        email: email,
        password: _generatedPin!,
        data: {
          'full_name': '${_partner1.text.trim()} & ${_partner2.text.trim()}',
          'signup_mode': 'self_planner',
          'referred_by_planner_id': AppConstants.plannerId,
          'wedding_title': title,
        },
      );

      if (res.user != null && mounted) {
        _showPinDialog();
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: AppTheme.error),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.error),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showPinDialog() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_rounded, color: Colors.green.shade600, size: 32),
              ),
              const SizedBox(height: 16),
              const Text('¡Cuenta creada!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const Text('Tu código de acceso es:', style: TextStyle(fontSize: 15, color: Colors.black54)),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: _generatedPin!));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Código copiado ✓')),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.primary.withOpacity(0.15)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _generatedPin!,
                        style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800, letterSpacing: 10),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.copy_rounded, size: 18, color: Colors.grey.shade400),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Guárdalo para iniciar sesión más tarde 🔐',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity, height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    _controller.nextPage(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: const Text('Continuar', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateWeddingData() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        if (mounted) context.go('/');
        return;
      }

      final weddingClient = await Supabase.instance.client
          .from('wedding_clients')
          .select('wedding_id')
          .eq('user_id', user.id)
          .maybeSingle();

      if (weddingClient != null) {
        final updates = <String, dynamic>{'onboarding_completed': true};
        if (_date != null) {
          updates['wedding_date'] = _date!.toIso8601String().split('T').first;
        }
        if (_style != null) updates['style'] = _style;
        if (_guestCount != 100) updates['estimated_guests'] = _guestCount;

        await Supabase.instance.client
            .from('weddings')
            .update(updates)
            .eq('id', weddingClient['wedding_id']);
      }
    } catch (_) {}

    if (mounted) context.go('/');
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
                    onChanged: () => setState(() {}),
                  ),
                  _EmailPage(
                    emailController: _emailController,
                    onChanged: () => setState(() {}),
                  ),
                  _DatePage(
                    date: _date,
                    onPickDate: _pickDate,
                    guestCount: _guestCount,
                    onGuestCountChanged: (v) => setState(() => _guestCount = v),
                  ),
                  _StylePage(
                    selected: _style,
                    onSelected: (v) => setState(() => _style = v),
                  ),
                ],
              ),
            ),
            if (_currentPage > 0)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: (_canProceed && !_loading) ? _next : null,
                    child: _loading
                        ? const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(
                            _currentPage == 2
                                ? '¡Crear mi cuenta!'
                                : _currentPage < _totalPages - 1
                                    ? 'Siguiente'
                                    : '¡Empezar! 🎉',
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
        return _partner1.text.trim().isNotEmpty && _partner2.text.trim().isNotEmpty;
      case 2:
        final email = _emailController.text.trim();
        return email.isNotEmpty && email.contains('@');
      case 3:
        return true;
      case 4:
        return true;
      default:
        return true;
    }
  }
}

// ═══════════════════════════════════════════════════════════════
// PAGE 0 – Welcome
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
            width: 140, height: 140,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primary.withOpacity(0.08),
                  const Color(0xFFD4A574).withOpacity(0.12),
                ],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Image.asset('assets/images/logo.png', width: 80, height: 80, fit: BoxFit.contain),
            ),
          ),
          const SizedBox(height: 40),
          Text('¡Organiza la boda\nde tus sueños!', textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800, height: 1.2)),
          const SizedBox(height: 16),
          Text('Checklist, presupuesto, invitados, agenda…\nTodo en un solo lugar.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade500, height: 1.5)),
          const SizedBox(height: 48),
          SizedBox(width: double.infinity, height: 52,
            child: ElevatedButton(onPressed: onStart, child: const Text('Empezar a planear 💍', style: TextStyle(fontSize: 16)))),
          const SizedBox(height: 16),
          TextButton(onPressed: () => context.go('/login'),
            child: Text('Ya tengo una cuenta', style: TextStyle(color: Colors.grey.shade500))),
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
  final VoidCallback onChanged;
  const _NamesPage({required this.partner1, required this.partner2, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 80, height: 80,
            decoration: BoxDecoration(color: AppTheme.accent.withOpacity(0.12), shape: BoxShape.circle),
            child: Icon(Icons.favorite_rounded, size: 36, color: AppTheme.accent))),
          const SizedBox(height: 24),
          Text('¿Quiénes se casan?', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('Cuéntanos los nombres de los novios', style: TextStyle(color: Colors.grey.shade500, fontSize: 15)),
          const SizedBox(height: 32),
          TextFormField(controller: partner1, textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(labelText: 'Nombre del novio/a', hintText: 'ej: María',
              prefixIcon: Icon(Icons.person_outline_rounded, size: 20, color: AppTheme.accent)),
            onChanged: (_) { onChanged(); (context as Element).markNeedsBuild(); }),
          const SizedBox(height: 16),
          TextFormField(controller: partner2, textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(labelText: 'Nombre del novio/a', hintText: 'ej: Pedro',
              prefixIcon: Icon(Icons.person_outline_rounded, size: 20, color: AppTheme.accent)),
            onChanged: (_) { onChanged(); (context as Element).markNeedsBuild(); }),
          const SizedBox(height: 32),
          if (partner1.text.trim().isNotEmpty && partner2.text.trim().isNotEmpty)
            Center(child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.06), borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primary.withOpacity(0.15))),
              child: Text('${partner1.text.trim()} & ${partner2.text.trim()} 💍',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.primary)))),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// PAGE 2 – Email (signup happens here)
// ═══════════════════════════════════════════════════════════════
class _EmailPage extends StatelessWidget {
  final TextEditingController emailController;
  final VoidCallback onChanged;
  const _EmailPage({required this.emailController, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 80, height: 80,
            decoration: BoxDecoration(color: AppTheme.accent.withOpacity(0.12), shape: BoxShape.circle),
            child: Icon(Icons.mail_outline_rounded, size: 36, color: AppTheme.accent))),
          const SizedBox(height: 24),
          Text('¿Cuál es tu correo?', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('Lo usaremos para crear tu cuenta', style: TextStyle(color: Colors.grey.shade500, fontSize: 15)),
          const SizedBox(height: 32),
          TextFormField(controller: emailController, keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            decoration: InputDecoration(labelText: 'Correo electrónico', hintText: 'tu@email.com',
              prefixIcon: Icon(Icons.mail_outline_rounded, size: 20, color: AppTheme.accent)),
            onChanged: (_) => onChanged()),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              Icon(Icons.lock_outline_rounded, size: 20, color: Colors.grey.shade400),
              const SizedBox(width: 12),
              Expanded(child: Text('Te enviaremos un código de acceso.\nSin contraseña complicada 😉',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13, height: 1.4))),
            ]),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// PAGE 3 – Date + Guest count (optional)
// ═══════════════════════════════════════════════════════════════
class _DatePage extends StatelessWidget {
  final DateTime? date;
  final VoidCallback onPickDate;
  final int guestCount;
  final ValueChanged<int> onGuestCountChanged;

  const _DatePage({required this.date, required this.onPickDate, required this.guestCount, required this.onGuestCountChanged});

  @override
  Widget build(BuildContext context) {
    final daysUntil = date != null ? date!.difference(DateTime.now()).inDays : null;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 80, height: 80,
            decoration: BoxDecoration(color: AppTheme.accent.withOpacity(0.12), shape: BoxShape.circle),
            child: Icon(Icons.calendar_month_rounded, size: 36, color: AppTheme.accent))),
          const SizedBox(height: 24),
          Text('¿Cuándo es el gran día?', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('Si ya lo sabes, genial. Sino, puedes agregarlo después.',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 15)),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: onPickDate,
            child: Container(
              width: double.infinity, padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: date != null ? AppTheme.primary.withOpacity(0.06) : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: date != null ? AppTheme.primary.withOpacity(0.2) : Colors.grey.shade200)),
              child: Row(children: [
                Icon(Icons.calendar_month_rounded, color: AppTheme.primary, size: 28),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(date != null ? DateFormat('d MMMM yyyy', 'es_MX').format(date!) : 'Toca para elegir la fecha',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: date != null ? Colors.black87 : Colors.grey)),
                  if (daysUntil != null && daysUntil > 0) ...[
                    const SizedBox(height: 4),
                    Text('¡Faltan $daysUntil días! 🎉', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600, fontSize: 13)),
                  ],
                ])),
              ]),
            ),
          ),
          const SizedBox(height: 40),
          Text('¿Cuántos invitados esperas?', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(children: [
            Icon(Icons.groups_rounded, size: 28, color: AppTheme.accent),
            const SizedBox(width: 12),
            Text('$guestCount invitados', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.primary)),
          ]),
          Slider(value: guestCount.toDouble(), min: 10, max: 500, divisions: 49,
            activeColor: AppTheme.primary, label: '$guestCount',
            onChanged: (v) => onGuestCountChanged(v.round())),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('10', style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
            Text('500', style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
          ]),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// PAGE 4 – Style (optional)
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
          Center(child: Container(width: 80, height: 80,
            decoration: BoxDecoration(color: AppTheme.accent.withOpacity(0.12), shape: BoxShape.circle),
            child: Icon(Icons.palette_rounded, size: 36, color: AppTheme.accent))),
          const SizedBox(height: 24),
          Text('¿Qué estilo te inspira?', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('Elige el estilo que más te represente', style: TextStyle(color: Colors.grey.shade500, fontSize: 15)),
          const SizedBox(height: 28),
          GridView.count(crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.3,
            children: _styles.map((style) {
              final isSelected = selected == style.id;
              return GestureDetector(
                onTap: () { HapticFeedback.lightImpact(); onSelected(style.id); },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primary.withOpacity(0.08) : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isSelected ? AppTheme.primary : Colors.grey.shade200, width: isSelected ? 2 : 1)),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(style.emoji, style: const TextStyle(fontSize: 32)),
                    const SizedBox(height: 8),
                    Text(style.label, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15,
                      color: isSelected ? AppTheme.primary : Colors.black87)),
                    const SizedBox(height: 2),
                    Text(style.desc, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                  ]),
                ),
              );
            }).toList()),
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
  const _WeddingStyle({required this.id, required this.emoji, required this.label, required this.desc});
}
