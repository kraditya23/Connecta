import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:card_app/utilities/app_colors.dart';
import 'package:card_app/utilities/supabase_config.dart';
import 'package:card_app/screens/authenticate/auth_gate.dart';
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

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider).value;

    return MaterialApp(
      title: 'Connecta',
      debugShowCheckedModeBanner: false,
      theme: appThemeData,
      darkTheme: appDarkThemeData,
      themeMode: settings?.themeMode ?? ThemeMode.system,
      home: const AuthGate(),
    );
  }
}
