import 'package:card_app/providers/account_provider.dart';
import 'package:card_app/widgets/snackbars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AccountDetailsScreen extends ConsumerStatefulWidget {
  const AccountDetailsScreen({super.key});

  @override
  ConsumerState<AccountDetailsScreen> createState() => _AccountDetailsScreenState();
}

class _AccountDetailsScreenState extends ConsumerState<AccountDetailsScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  bool _isSavingName = false;
  bool _isSavingEmail = false;

  @override
  void initState() {
    super.initState();
    final user = Supabase.instance.client.auth.currentUser;
    _nameController = TextEditingController(
      text: user?.userMetadata?['display_name'] as String? ?? '',
    );
    _emailController = TextEditingController(text: user?.email ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveName() async {
    setState(() => _isSavingName = true);
    try {
      await ref.read(accountActionsProvider).updateDisplayName(_nameController.text.trim());
      if (mounted) context.showSuccessSnackBar(message: 'Name updated.');
    } catch (e) {
      if (mounted) context.showErrorSnackBar(message: 'Could not update name.');
    } finally {
      if (mounted) setState(() => _isSavingName = false);
    }
  }

  Future<void> _saveEmail() async {
    final newEmail = _emailController.text.trim();
    final current = Supabase.instance.client.auth.currentUser?.email;
    if (newEmail.isEmpty || newEmail == current) return;

    setState(() => _isSavingEmail = true);
    try {
      await ref.read(accountActionsProvider).updateEmail(newEmail);
      if (mounted) {
        context.showSuccessSnackBar(
          message: 'Check $newEmail to confirm the change.',
          duration: const Duration(seconds: 4),
        );
      }
    } on ReauthRequiredException {
      if (mounted) await _promptReauthAndRetry(() => _saveEmail());
    } catch (e) {
      if (mounted) context.showErrorSnackBar(message: 'Could not update email.');
    } finally {
      if (mounted) setState(() => _isSavingEmail = false);
    }
  }

  Future<void> _promptReauthAndRetry(Future<void> Function() retry) async {
    final passwordController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Confirm your password'),
        content: TextField(
          controller: passwordController,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Current password'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Confirm')),
        ],
      ),
    );

    if (confirmed != true) return;
    try {
      await ref.read(accountActionsProvider).reauthenticate(passwordController.text);
      await retry();
    } catch (e) {
      if (mounted) context.showErrorSnackBar(message: 'Re-authentication failed.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account details')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'This is your sign-in identity, separate from the public name shown on your card '
            '(edit that from "Your card" instead).',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Display name', prefixIcon: Icon(Icons.person_outline)),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _isSavingName ? null : _saveName,
              child: Text(_isSavingName ? 'Saving...' : 'Save name'),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.mail_outline)),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _isSavingEmail ? null : _saveEmail,
              child: Text(_isSavingEmail ? 'Saving...' : 'Save email'),
            ),
          ),
        ],
      ),
    );
  }
}
