import 'package:card_app/screens/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
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
  @override
  void initState() {
    super.initState();
    _initBranchAndListener();
  }

  Future<void> _initBranchAndListener() async {
    try {
      await FlutterBranchSdk.init();
      FlutterBranchSdk.listSession().listen((data) {
        if (data.containsKey('uid') && data.containsKey('username')) {
          final uid = data['uid'] as String;
          final username = data['username'] as String;
          ref.read(deepLinkUserProvider.notifier).setUser(uid, username);
        }
      });
    } catch (e) {
      debugPrint('Branch SDK failed to initialize: $e');
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
              builder: (context) => ProfilePage(uid: uid, profileUsername: username),
            );
          }
        }
        return MaterialPageRoute(builder: (context) => const AuthGate());
      },
    );
  }
}
