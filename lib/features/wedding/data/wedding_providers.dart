import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/providers/auth_providers.dart';

final weddingProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;

  final supabase = ref.watch(supabaseProvider);

  // Get wedding through wedding_clients junction
  final clientLinks = await supabase
      .from('wedding_clients')
      .select('wedding_id')
      .eq('client_user_id', user.id);

  if (clientLinks.isEmpty) {
    // Also check if user created wedding directly (self planner)
    final ownWeddings = await supabase
        .from('weddings')
        .select()
        .or('created_by.eq.${user.id}')
        .order('created_at', ascending: false)
        .limit(1);

    if (ownWeddings.isNotEmpty) return ownWeddings.first;
    return null;
  }

  final weddingId = clientLinks.first['wedding_id'];
  final wedding = await supabase
      .from('weddings')
      .select()
      .eq('id', weddingId)
      .single();

  return wedding;
});

final weddingGuestsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final wedding = await ref.watch(weddingProvider.future);
  if (wedding == null) return [];

  final supabase = ref.watch(supabaseProvider);
  final guests = await supabase
      .from('wedding_guests')
      .select()
      .eq('wedding_id', wedding['id'])
      .order('full_name');

  return List<Map<String, dynamic>>.from(guests);
});

final weddingTablesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final wedding = await ref.watch(weddingProvider.future);
  if (wedding == null) return [];

  final supabase = ref.watch(supabaseProvider);
  final tables = await supabase
      .from('wedding_tables')
      .select()
      .eq('wedding_id', wedding['id'])
      .order('name');

  return List<Map<String, dynamic>>.from(tables);
});

final subscriptionProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;

  final supabase = ref.watch(supabaseProvider);

  final subs = await supabase
      .from('subscriptions')
      .select()
      .eq('user_id', user.id)
      .eq('status', 'active')
      .order('created_at', ascending: false)
      .limit(1);

  if (subs.isEmpty) return null;
  return subs.first;
});

// Guest stats helper
final guestStatsProvider = Provider<Map<String, int>>((ref) {
  final guestsAsync = ref.watch(weddingGuestsProvider);
  return guestsAsync.when(
    data: (guests) {
      int total = guests.length;
      int confirmed = guests.where((g) => g['rsvp_status'] == 'confirmed').length;
      int declined = guests.where((g) => g['rsvp_status'] == 'declined').length;
      int pending = guests.where((g) => g['rsvp_status'] == 'pending' || g['rsvp_status'] == null).length;
      return {
        'total': total,
        'confirmed': confirmed,
        'declined': declined,
        'pending': pending,
      };
    },
    loading: () => {'total': 0, 'confirmed': 0, 'declined': 0, 'pending': 0},
    error: (_, __) => {'total': 0, 'confirmed': 0, 'declined': 0, 'pending': 0},
  );
});
