import 'package:card_app/providers/settings_provider.dart';
import 'package:card_app/widgets/snackbars.dart';
import 'package:card_app/widgets/ui/settings_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    final settings = settingsAsync.value;

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: settings == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SettingsGroup(children: [
                  SettingsTile(
                    icon: Icons.person_add_alt_rounded,
                    title: 'Connection alerts',
                    subtitle: 'When someone exchanges contacts with you',
                    showChevron: false,
                    trailing: Switch(
                      value: settings.connectionAlertsEnabled,
                      onChanged: (value) async {
                        try {
                          await ref.read(settingsProvider.notifier).setConnectionAlerts(value);
                        } catch (_) {
                          if (context.mounted) {
                            context.showErrorSnackBar(message: 'Could not save that preference.');
                          }
                        }
                      },
                    ),
                  ),
                  SettingsTile(
                    icon: Icons.campaign_outlined,
                    title: 'Product updates',
                    subtitle: 'News about new Connecta features',
                    showChevron: false,
                    trailing: Switch(
                      value: settings.productUpdatesEnabled,
                      onChanged: (value) async {
                        try {
                          await ref.read(settingsProvider.notifier).setProductUpdates(value);
                        } catch (_) {
                          if (context.mounted) {
                            context.showErrorSnackBar(message: 'Could not save that preference.');
                          }
                        }
                      },
                    ),
                  ),
                ]),
              ],
            ),
    );
  }
}