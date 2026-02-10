import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/auth_providers.dart';
import '../../../wedding/data/wedding_providers.dart';

class CreateWeddingScreen extends ConsumerStatefulWidget {
  const CreateWeddingScreen({super.key});
  @override
  ConsumerState<CreateWeddingScreen> createState() => _CreateWeddingScreenState();
}

class _CreateWeddingScreenState extends ConsumerState<CreateWeddingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _partner1 = TextEditingController();
  final _partner2 = TextEditingController();
  final _venue = TextEditingController();
  DateTime? _date;
  int _guestEstimate = 100;
  bool _loading = false;

  @override
  void dispose() { _partner1.dispose(); _partner2.dispose(); _venue.dispose(); super.dispose(); }

  Future<void> _pickDate() async {
    final d = await showDatePicker(context: context, initialDate: DateTime.now().add(const Duration(days: 180)), firstDate: DateTime.now(), lastDate: DateTime(2032));
    if (d != null) setState(() => _date = d);
  }

  Future<void> _create() async {
    if (!_formKey.currentState!.validate()) return;
    if (_date == null) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Choisissez une date'))); return; }
    setState(() => _loading = true);
    try {
      final user = ref.read(currentUserProvider);
      if (user == null) return;
      final wedding = await Supabase.instance.client.from('weddings').insert({
        'partner1_name': _partner1.text.trim(),
        'partner2_name': _partner2.text.trim(),
        'date': _date!.toIso8601String().split('T').first,
        'venue': _venue.text.trim().isEmpty ? null : _venue.text.trim(),
        'estimated_guests': _guestEstimate,
        'status': 'planning',
        'wedding_mode': 'self',
        'created_by': user.id,
      }).select().single();
      await Supabase.instance.client.from('wedding_clients').insert({'wedding_id': wedding['id'], 'client_user_id': user.id});
      ref.invalidate(weddingProvider);
      if (mounted) context.go('/');
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e'), backgroundColor: AppTheme.error));
    } finally { if (mounted) setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Créer mon mariage'), backgroundColor: Colors.white, surfaceTintColor: Colors.transparent),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Text('Qui se marie ? 💍', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 24),
          TextFormField(controller: _partner1, decoration: const InputDecoration(labelText: 'Prénom partenaire 1', prefixIcon: Icon(Icons.person_outline_rounded, size: 20)), validator: (v) => v == null || v.isEmpty ? 'Requis' : null),
          const SizedBox(height: 16),
          TextFormField(controller: _partner2, decoration: const InputDecoration(labelText: 'Prénom partenaire 2', prefixIcon: Icon(Icons.person_outline_rounded, size: 20)), validator: (v) => v == null || v.isEmpty ? 'Requis' : null),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
              child: Row(children: [
                Icon(Icons.calendar_month_rounded, color: AppTheme.primary, size: 22),
                const SizedBox(width: 12),
                Text(_date != null ? DateFormat('d MMMM yyyy', 'fr_FR').format(_date!) : 'Choisir la date', style: TextStyle(fontSize: 15, color: _date != null ? Colors.black87 : Colors.grey)),
              ]),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(controller: _venue, decoration: const InputDecoration(labelText: 'Lieu (optionnel)', prefixIcon: Icon(Icons.location_on_outlined, size: 20))),
          const SizedBox(height: 24),
          Text('Nombre d\'invités estimé', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
          const SizedBox(height: 8),
          Row(children: [
            Text('$_guestEstimate', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.primary)),
            const SizedBox(width: 4),
            const Text('invités'),
          ]),
          Slider(value: _guestEstimate.toDouble(), min: 10, max: 500, divisions: 49, activeColor: AppTheme.primary, label: '$_guestEstimate', onChanged: (v) => setState(() => _guestEstimate = v.round())),
          const SizedBox(height: 32),
          SizedBox(height: 52, child: ElevatedButton(onPressed: _loading ? null : _create, child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Créer mon mariage 🎉'))),
        ])),
      ),
    );
  }
}
