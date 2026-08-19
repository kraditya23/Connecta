import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:card_app/screens/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:card_app/utilities/app_colors.dart';
import 'package:card_app/utilities/supabase_config.dart';
import 'package:card_app/screens/authenticate/auth_gate.dart';
import 'package:card_app/providers/deeplink_user_provider.dart';
import 'package:card_app/providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  assert(
    supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty,
    'Missing Supabase credentials. '
    'Run with: flutter run --dart-define-from-file=.env.json',
  );
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSub;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  @override
  void dispose() {
    _linkSub?.cancel();
    super.dispose();
  }

  Future<void> _initDeepLinks() async {
    // Cold start: the app was launched by tapping a connecta:// link.
    try {
      final initial = await _appLinks.getInitialLink();
      if (initial != null) _handleProfileLink(initial);
    } catch (e) {
      debugPrint('Failed to read initial deep link: $e');
    }

    // Warm: a connecta:// link tapped while the app is already running.
    // Coexists with supabase_flutter's own auth-redirect listener; each
    // ignores URIs meant for the other.
    _linkSub = _appLinks.uriLinkStream.listen(
      _handleProfileLink,
      onError: (Object e) => debugPrint('Deep link stream error: $e'),
    );
  }

  /// Handles `connecta://profile/<username>` links by resolving the username
  /// to a uid and feeding the existing deepLinkUserProvider mechanism, which
  /// drives AuthState.redirectingToProfile and AuthGate navigation.
  Future<void> _handleProfileLink(Uri uri) async {
    if (uri.scheme != 'connecta' || uri.host != 'profile') return;
    if (uri.pathSegments.isEmpty) return;
    final username = uri.pathSegments.last.trim();
    if (username.isEmpty) return;

    try {
      final data = await Supabase.instance.client
          .from('profiles')
          .select('id')
          .eq('username', username)
          .maybeSingle();
      if (data != null && data['id'] != null) {
        ref
            .read(deepLinkUserProvider.notifier)
            .setUser(data['id'] as String, username);
      }
    } catch (e) {
      debugPrint('Failed to resolve profile link for "$username": $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider).value;

    return MaterialApp(
      title: 'Connecta',
      debugShowCheckedModeBanner: false,
      theme: appThemeData,
      darkTheme: appDarkThemeData,
      themeMode: settings?.themeMode ?? ThemeMode.system,
      home: const AuthGate(),
      onGenerateRoute: (settings) {
        final name = settings.name;
        if (name?.startsWith('/profile/') ?? false) {
          final parts = name!.replaceFirst('/profile/', '').split('/');
          if (parts.length == 2) {
            final uid = parts[0];
            final username = parts[1];
            return MaterialPageRoute(
              builder: (context) =>
                  ProfilePage(uid: uid, profileUsername: username),
            );
          }
        }
        return MaterialPageRoute(builder: (context) => const AuthGate());
      },
    );
  }
}
