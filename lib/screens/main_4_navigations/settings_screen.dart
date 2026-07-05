import 'package:card_app/providers/settings_provider.dart';
import 'package:card_app/screens/main_4_navigations/settings_subscreens/account_details_screen.dart';
import 'package:card_app/screens/main_4_navigations/settings_subscreens/analytics_screen.dart';
import 'package:card_app/screens/main_4_navigations/settings_subscreens/change_password_screen.dart';
import 'package:card_app/screens/main_4_navigations/settings_subscreens/contact_support_screen.dart';
import 'package:card_app/screens/main_4_navigations/settings_subscreens/delete_account_screen.dart';
import 'package:card_app/screens/main_4_navigations/settings_subscreens/faq_screen.dart';
import 'package:card_app/screens/main_4_navigations/settings_subscreens/message_snippets_screen.dart';
import 'package:card_app/screens/main_4_navigations/settings_subscreens/nfc_devices_screen.dart';
import 'package:card_app/screens/main_4_navigations/settings_subscreens/notification_settings_screen.dart';
import 'package:card_app/screens/main_4_navigations/settings_subscreens/terms_privacy_screen.dart';
import 'package:card_app/utilities/constants.dart';
import 'package:card_app/widgets/ui/confirm_dialog.dart';
import 'package:card_app/widgets/ui/section_header.dart';
import 'package:card_app/widgets/ui/settings_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../providers/user_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Sign out?',
      message: "You'll need to sign back in to view or edit your card.",
      confirmLabel: 'Sign out',
      destructive: true,
    );
    if (!confirmed) return;

    await Supabase.instance.client.auth.signOut();
    ref.read(userProvider.notifier).clearUser();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = Supabase.instance.client.auth.currentUser;
    final displayName = user?.userMetadata?['display_name'] as String? ?? '';
    final email = user?.email ?? '';
    final settingsAsync = ref.watch(settingsProvider);
    final settings = settingsAsync.value;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          // Profile header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).colorScheme.outline),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Text(
                    displayName.isNotEmpty
                        ? displayName[0].toUpperCase()
                        : email.isNotEmpty
                            ? email[0].toUpperCase()
                            : '?',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName.isNotEmpty ? displayName : 'Add your name',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(email, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right_rounded),
                  onPressed: () =>
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AccountDetailsScreen())),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const SectionHeader('Account'),
          SettingsGroup(children: [
            SettingsTile(
              icon: Icons.badge_outlined,
              title: 'Account details',
              subtitle: 'Name and email',
              onTap: () =>
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AccountDetailsScreen())),
            ),
            SettingsTile(
              icon: Icons.lock_outline_rounded,
              title: 'Change password',
              onTap: () =>
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordScreen())),
            ),
          ]),

          const SizedBox(height: 24),
          const SectionHeader('Preferences'),
          SettingsGroup(children: [
            SettingsTile(
              icon: Icons.dark_mode_outlined,
              title: 'Appearance',
              subtitle: switch (settings?.themeMode) {
                ThemeMode.light => 'Light',
                ThemeMode.dark => 'Dark',
                _ => 'System',
              },
              trailing: PopupMenuButton<ThemeMode>(
                icon: const Icon(Icons.chevron_right_rounded),
                onSelected: (mode) => ref.read(settingsProvider.notifier).setThemeMode(mode),
                itemBuilder: (context) => const [
                  PopupMenuItem(value: ThemeMode.system, child: Text('System')),
                  PopupMenuItem(value: ThemeMode.light, child: Text('Light')),
                  PopupMenuItem(value: ThemeMode.dark, child: Text('Dark')),
                ],
              ),
            ),
            SettingsTile(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              subtitle: 'Connection alerts & updates',
              onTap: () =>
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationSettingsScreen())),
            ),
          ]),

          const SizedBox(height: 24),
          const SectionHeader('Your card'),
          SettingsGroup(children: [
            SettingsTile(
              icon: Icons.bar_chart_rounded,
              title: 'Analytics',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalyticsScreen())),
            ),
            SettingsTile(
              icon: Icons.nfc_rounded,
              title: 'NFC devices',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NfcDevicesScreen())),
            ),
            SettingsTile(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'Message snippets',
              onTap: () =>
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const MessageSnippetsScreen())),
            ),
          ]),

          const SizedBox(height: 24),
          const SectionHeader('Support'),
          SettingsGroup(children: [
            SettingsTile(
              icon: Icons.help_outline_rounded,
              title: 'FAQ',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FaqScreen())),
            ),
            SettingsTile(
              icon: Icons.mail_outline_rounded,
              title: 'Contact us',
              onTap: () =>
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactSupportScreen())),
            ),
            SettingsTile(
              icon: Icons.description_outlined,
              title: 'Terms & Privacy',
              onTap: () =>
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsPrivacyScreen())),
            ),
          ]),

          const SizedBox(height: 24),
          const SectionHeader('Danger zone'),
          SettingsGroup(children: [
            SettingsTile(
              icon: Icons.logout_rounded,
              title: 'Sign out',
              showChevron: false,
              onTap: () => _signOut(context, ref),
            ),
            SettingsTile(
              icon: Icons.delete_outline_rounded,
              title: 'Delete account',
              destructive: true,
              onTap: () =>
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const DeleteAccountScreen())),
            ),
          ]),

          const SizedBox(height: 32),
          Center(
            child: Text(
              '$appName  •  v$appVersion ($appBuildNumber)',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
