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
  final _titleController = TextEditingController();
  final _venue = TextEditingController();
  DateTime? _date;
  double _budget = 15000;
  bool _loading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _venue.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 180)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2032),
    );
    if (d != null) setState(() => _date = d);
  }

  Future<void> _create() async {
    if (!_formKey.currentState!.validate()) return;
    if (_date == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choisissez une date')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final user = ref.read(currentUserProvider);
      if (user == null) return;

      final supabase = Supabase.instance.client;

      // Insert wedding with correct DB column names
      // weddings table: id, planner_id, title, wedding_date, venue, budget, status, mode
      final wedding = await supabase.from('weddings').insert({
        'title': _titleController.text.trim(),
        'wedding_date': _date!.toIso8601String().split('T').first,
        'venue': _venue.text.trim().isEmpty ? null : _venue.text.trim(),
        'budget': _budget,
        'status': 'planning',
        'mode': 'self',
      }).select().single();

      // Link user to wedding via wedding_clients
      // wedding_clients table: id, wedding_id, user_id, is_primary
      await supabase.from('wedding_clients').insert({
        'wedding_id': wedding['id'],
        'user_id': user.id,
        'is_primary': true,
      });

      ref.invalidate(weddingProvider);
      if (mounted) context.go('/');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: AppTheme.error),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Créer mon mariage'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Votre mariage 💍',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 24),

              // Wedding title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Titre du mariage',
                  hintText: 'ex: Mariage Marie & Pierre',
                  prefixIcon: Icon(Icons.favorite_outline_rounded, size: 20),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: 16),

              // Date picker
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_month_rounded, color: AppTheme.primary, size: 22),
                      const SizedBox(width: 12),
                      Text(
                        _date != null
                            ? DateFormat('d MMMM yyyy', 'fr_FR').format(_date!)
                            : 'Choisir la date',
                        style: TextStyle(
                          fontSize: 15,
                          color: _date != null ? Colors.black87 : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Venue
              TextFormField(
                controller: _venue,
                decoration: const InputDecoration(
                  labelText: 'Lieu (optionnel)',
                  prefixIcon: Icon(Icons.location_on_outlined, size: 20),
                ),
              ),
              const SizedBox(height: 24),

              // Budget slider
              Text(
                'Budget estimé',
                style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    '${NumberFormat('#,###', 'fr_FR').format(_budget)} €',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
              Slider(
                value: _budget,
                min: 1000,
                max: 100000,
                divisions: 99,
                activeColor: AppTheme.primary,
                label: '${NumberFormat('#,###', 'fr_FR').format(_budget)} €',
                onChanged: (v) => setState(() => _budget = v.roundToDouble()),
              ),
              const SizedBox(height: 32),

              // Create button
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _loading ? null : _create,
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Créer mon mariage 🎉'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
