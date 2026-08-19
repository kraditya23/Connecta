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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account details')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'This is your account profile name, used inside the app. It does not appear '
            'on your public card — to change the name shown on your card, edit your '
            'contact info from the Your Card tab. Your sign-in email is shown for '
            'reference and cannot be changed from within the app.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Profile name', prefixIcon: Icon(Icons.person_outline)),
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
            enabled: false,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.mail_outline)),
          ),
        ],
      ),
    );
  }
}
