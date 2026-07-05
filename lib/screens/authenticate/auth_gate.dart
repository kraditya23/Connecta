import 'package:card_app/widgets/ui/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:card_app/providers/auth_state_provider.dart';
import 'package:card_app/providers/deeplink_user_provider.dart';
import 'login_page.dart';
import '../onboarding/welcome_screen.dart';
import '../app_entry.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final deepLinkUser = ref.watch(deepLinkUserProvider);

    switch (authState) {
      case AuthState.loading:
        return const FullScreenLoader();

      case AuthState.notLoggedIn:
        return const LoginPage();

      case AuthState.error:
        return Scaffold(
          body: ErrorState(
            message: 'We couldn\'t verify your account. Check your connection and try again.',
            onRetry: () => ref.invalidate(authStateProvider),
          ),
        );

      case AuthState.needsOnboarding:
        return const WelcomeScreen();

      case AuthState.redirectingToProfile:
        // We have a user + profile + a pending deep link -> redirect once,
        // then clear the deep link so we don't loop.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (deepLinkUser == null) return;
          final targetRoute = '/profile/${deepLinkUser.uid}/${deepLinkUser.username}';
          if (ModalRoute.of(context)?.settings.name != targetRoute) {
            Navigator.of(context).pushReplacementNamed(targetRoute).then((_) {
              ref.read(deepLinkUserProvider.notifier).clear();
            });
          } else {
            ref.read(deepLinkUserProvider.notifier).clear();
          }
        });
        return const FullScreenLoader();

      case AuthState.complete:
        return const AppEntry();
    }
  }
}