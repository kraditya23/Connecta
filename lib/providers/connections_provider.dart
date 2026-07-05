import 'package:card_app/providers/auth_session_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:card_app/models/connection_model.dart';

final connectionsProvider = FutureProvider<List<Connection>>((ref) async {
  final session = ref.watch(authSessionProvider).value;
  if (session == null) return [];

  final data = await Supabase.instance.client
      .from('connections')
      .select(
        'since, profiles!connection_id(id, username, name, profile_pic_url, job_title, organisation)',
      )
      .eq('owner_id', session.user.id)
      .order('since', ascending: false);

  return (data as List).map((row) => Connection.fromMap(row)).toList();
});

/// Convenience provider for screens that only need a count.
final connectionsCountProvider = Provider<int>((ref) {
  return ref.watch(connectionsProvider).value?.length ?? 0;
});
