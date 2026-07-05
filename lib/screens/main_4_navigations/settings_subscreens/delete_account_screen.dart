import 'package:card_app/providers/account_provider.dart';
import 'package:card_app/widgets/snackbars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeleteAccountScreen extends ConsumerStatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  ConsumerState<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends ConsumerState<DeleteAccountScreen> {
  bool _confirmed = false;
  bool _isDeleting = false;

  Future<void> _delete() async {
    setState(() => _isDeleting = true);
    try {
      await ref.read(accountActionsProvider).deleteAccount();
      // No navigation needed — once the auth session is cleared, the reactive
      // AuthGate at the root takes the user back to the login screen.
    } catch (e) {
      if (mounted) context.showErrorSnackBar(message: 'Could not delete your account. Try again.');
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Delete account')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error, size: 40),
            const SizedBox(height: 16),
            Text('This can\'t be undone', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 12),
            Text(
              'Deleting your account permanently removes your card, profile data, and username. '
              'Connections that other people made to you may keep a record of the relationship on '
              'their side, but your profile itself will be gone.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            CheckboxListTile(
              value: _confirmed,
              onChanged: (value) => setState(() => _confirmed = value ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              title: const Text('I understand this is permanent'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: (_confirmed && !_isDeleting) ? _delete : null,
              style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.error),
              child: Text(_isDeleting ? 'Deleting...' : 'Delete my account'),
            ),
          ],
        ),
      ),
    );
  }
}
