import 'package:card_app/providers/auth_session_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Returns true if a profiles row exists for the current user.
///
/// Watches [authSessionProvider] so it re-runs whenever the signed-in user
/// changes, preventing stale results across sign-out/sign-in cycles.
final userExistsProvider = FutureProvider<bool>((ref) async {
  final session = ref.watch(authSessionProvider).value;
  if (session == null) return false;

  final response = await Supabase.instance.client
      .from('profiles')
      .select('id')
      .eq('id', session.user.id)
      .maybeSingle();

  return response != null;
});
