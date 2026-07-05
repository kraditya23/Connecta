import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Thrown when an operation requires re-authentication (e.g. the session is
/// too old for a sensitive action). The UI should prompt for the current
/// password and call [AccountActions.reauthenticate] before retrying.
class ReauthRequiredException implements Exception {}

final accountActionsProvider = Provider<AccountActions>((ref) => AccountActions());

class AccountActions {
  SupabaseClient get _client => Supabase.instance.client;

  User get _requireUser {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Not signed in.');
    return user;
  }

  /// Re-authenticate by signing in again with the current password, which
  /// refreshes the session token before a sensitive operation.
  Future<void> reauthenticate(String currentPassword) async {
    final user = _requireUser;
    final email = user.email;
    if (email == null) throw Exception('This account has no password to verify against.');
    await _client.auth.signInWithPassword(email: email, password: currentPassword);
  }

  Future<void> updateDisplayName(String displayName) async {
    _requireUser;
    await _client.auth.updateUser(
      UserAttributes(data: {'display_name': displayName.trim()}),
    );
  }

  Future<void> updateEmail(String newEmail) async {
    _requireUser;
    await _client.auth.updateUser(UserAttributes(email: newEmail.trim()));
  }

  Future<void> updatePassword(String newPassword) async {
    _requireUser;
    await _client.auth.updateUser(UserAttributes(password: newPassword));
  }

  /// Deletes the account via the Supabase Edge Function, which uses the
  /// service-role key to remove the auth.users row and cascade-delete the
  /// profile, connections, and storage files. Signs out locally afterwards.
  Future<void> deleteAccount() async {
    _requireUser;
    await _client.functions.invoke('delete-account');
    try {
      await _client.auth.signOut();
    } catch (_) {
      // Session already invalidated by the deletion — sign-out failure is
      // expected and harmless here.
    }
  }
}
