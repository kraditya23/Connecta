import 'package:card_app/providers/auth_session_provider.dart';
import 'package:card_app/providers/user_exists_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AuthState {
  loading,
  notLoggedIn,
  needsOnboarding,
  complete,
  error,
}

/// Derives the overall auth/onboarding state purely from its dependencies.
/// Recomputes automatically whenever any watched dependency changes.
final authStateProvider = Provider<AuthState>((ref) {
  final sessionAsync = ref.watch(authSessionProvider);

  if (sessionAsync.isLoading) return AuthState.loading;
  if (sessionAsync.hasError) return AuthState.error;

  final session = sessionAsync.value;
  if (session == null) return AuthState.notLoggedIn;

  final existsAsync = ref.watch(userExistsProvider);
  if (existsAsync.isLoading) return AuthState.loading;
  if (existsAsync.hasError) return AuthState.error;

  final exists = existsAsync.value ?? false;
  if (!exists) return AuthState.needsOnboarding;

  return AuthState.complete;
});
