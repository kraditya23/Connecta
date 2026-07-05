import 'dart:async';

import 'package:card_app/providers/user_exists_provider.dart';
import 'package:card_app/providers/user_provider.dart';
import 'package:card_app/utilities/app_colors.dart';
import 'package:card_app/widgets/snackbars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Lowercase letters, numbers and underscores only, 3-20 chars.
final _usernamePattern = RegExp(r'^[a-z0-9_]{3,20}$');

class UserInfoScreen extends ConsumerStatefulWidget {
  const UserInfoScreen({super.key});

  @override
  ConsumerState<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends ConsumerState<UserInfoScreen> {
  final _usernameController = TextEditingController();
  bool _isSaving = false;

  Timer? _debounce;
  String? _formatError;
  bool _checkingAvailability = false;
  bool? _isAvailable;

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_onChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _usernameController.removeListener(_onChanged);
    _usernameController.dispose();
    super.dispose();
  }

  void _onChanged() {
    final raw = _usernameController.text.trim().toLowerCase();
    setState(() {
      _isAvailable = null;
      _formatError = raw.isEmpty
          ? null
          : !_usernamePattern.hasMatch(raw)
              ? '3-20 lowercase letters, numbers, or underscores'
              : null;
    });

    _debounce?.cancel();
    if (raw.isEmpty || _formatError != null) return;

    _debounce = Timer(const Duration(milliseconds: 500), () => _checkAvailability(raw));
  }

  Future<void> _checkAvailability(String username) async {
    setState(() => _checkingAvailability = true);
    try {
      final data = await Supabase.instance.client
          .from('profiles')
          .select('id')
          .eq('username', username)
          .maybeSingle();
      if (!mounted) return;
      setState(() {
        _isAvailable = data == null;
        _checkingAvailability = false;
      });
    } catch (_) {
      if (mounted) setState(() => _checkingAvailability = false);
    }
  }

  Future<void> _saveInfo() async {
    final username = _usernameController.text.trim().toLowerCase();
    if (username.isEmpty || _formatError != null) return;

    setState(() => _isSaving = true);
    try {
      await ref.read(userProvider.notifier).saveUser(username);
      ref.invalidate(userExistsProvider);
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar(
          message: e.toString().contains('Username already taken')
              ? 'That username was just taken - try another.'
              : 'Something went wrong. Please try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canSubmit = _usernameController.text.trim().isNotEmpty &&
        _formatError == null &&
        !_checkingAvailability &&
        _isAvailable != false;

    return Scaffold(
      appBar: AppBar(title: const Text('Choose a username')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'This becomes your card\'s link - connecta.app/yourname',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _usernameController,
              autocorrect: false,
              decoration: InputDecoration(
                labelText: 'Username',
                prefixIcon: const Icon(Icons.alternate_email_rounded),
                errorText: _formatError,
                suffixIcon: _checkingAvailability
                    ? const Padding(
                        padding: EdgeInsets.all(14),
                        child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                      )
                    : _isAvailable == true
                        ? const Icon(Icons.check_circle_rounded, color: successColor)
                        : _isAvailable == false
                            ? const Icon(Icons.cancel_rounded, color: errorColor)
                            : null,
              ),
            ),
            if (_isAvailable == false && _formatError == null)
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 4),
                child: Text('That username is already taken.', style: TextStyle(color: theme.colorScheme.error)),
              ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: (canSubmit && !_isSaving) ? _saveInfo : null,
              child: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
