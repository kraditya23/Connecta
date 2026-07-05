import 'package:card_app/models/app_settings.dart';
import 'package:card_app/providers/auth_session_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final settingsProvider = StateNotifierProvider<SettingsNotifier, AsyncValue<AppSettings>>((ref) {
  final notifier = SettingsNotifier();
  ref.listen(authSessionProvider, (previous, next) => notifier.load());
  return notifier;
});

class SettingsNotifier extends StateNotifier<AsyncValue<AppSettings>> {
  SettingsNotifier() : super(const AsyncValue.data(AppSettings())) {
    load();
  }

  SupabaseClient get _client => Supabase.instance.client;
  String? get _uid => _client.auth.currentUser?.id;

  Future<void> load() async {
    final uid = _uid;
    if (uid == null) {
      state = const AsyncValue.data(AppSettings());
      return;
    }
    state = const AsyncValue.loading();
    try {
      final data = await _client
          .from('profiles')
          .select('settings')
          .eq('id', uid)
          .maybeSingle();
      final settingsMap = data?['settings'] as Map<String, dynamic>?;
      state = AsyncValue.data(AppSettings.fromMap(settingsMap));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> _persist(AppSettings updated) async {
    final uid = _uid;
    if (uid == null) return;
    final previous = state;
    state = AsyncValue.data(updated);
    try {
      await _client.from('profiles').update({
        'settings': updated.toMap(),
      }).eq('id', uid);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      state = previous;
      rethrow;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final current = state.value ?? const AppSettings();
    await _persist(current.copyWith(themeMode: mode));
  }

  Future<void> setConnectionAlerts(bool enabled) async {
    final current = state.value ?? const AppSettings();
    await _persist(current.copyWith(connectionAlertsEnabled: enabled));
  }

  Future<void> setProductUpdates(bool enabled) async {
    final current = state.value ?? const AppSettings();
    await _persist(current.copyWith(productUpdatesEnabled: enabled));
  }

  Future<void> addSnippet(String text) async {
    final current = state.value ?? const AppSettings();
    await _persist(current.copyWith(messageSnippets: [...current.messageSnippets, text]));
  }

  Future<void> updateSnippet(int index, String text) async {
    final current = state.value ?? const AppSettings();
    if (index < 0 || index >= current.messageSnippets.length) return;
    final updated = [...current.messageSnippets];
    updated[index] = text;
    await _persist(current.copyWith(messageSnippets: updated));
  }

  Future<void> removeSnippet(int index) async {
    final current = state.value ?? const AppSettings();
    if (index < 0 || index >= current.messageSnippets.length) return;
    final updated = [...current.messageSnippets]..removeAt(index);
    await _persist(current.copyWith(messageSnippets: updated));
  }
}
