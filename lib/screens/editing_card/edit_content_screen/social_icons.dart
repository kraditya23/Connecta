import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:card_app/providers/user_provider.dart';
import 'package:card_app/utilities/app_colors.dart';
import 'package:card_app/widgets/snackbars.dart';

const _socialNames = [
  'Whatsapp',
  'Instagram',
  'Telegram',
  'YouTube',
  'Facebook',
  'LinkedIn',
  'X',
  'Reddit',
  'Discord',
];

class EditSocialIconsScreen extends ConsumerStatefulWidget {
  const EditSocialIconsScreen({super.key});

  @override
  ConsumerState<EditSocialIconsScreen> createState() => _EditSocialIconsScreenState();
}

class _EditSocialIconsScreenState extends ConsumerState<EditSocialIconsScreen> {
  late List<TextEditingController> _controllers;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(userProvider).value;

    // Saved positionally against _socialNames (we always write the full,
    // fixed-order list on save - see _submit).
    final savedUrls = user?.socialUrl ?? const [];

    _controllers = List.generate(_socialNames.length, (i) {
      final name = _socialNames[i];
      var value = (i < savedUrls.length) ? savedUrls[i] : '';

      // For Instagram, show just the handle in the field rather than the
      // full URL - strip a previously-saved "https://instagram.com/" prefix
      // if present.
      if (name == 'Instagram' && value.startsWith('http')) {
        value = value.split('/').where((s) => s.isNotEmpty).last;
      }
      return TextEditingController(text: value);
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  String _iconAssetFor(String name) => 'assets/icons/social_icons/${name.toLowerCase()}.png';

  Future<void> _submit() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      final socialUrls = <String>[];
      for (var i = 0; i < _socialNames.length; i++) {
        final raw = _controllers[i].text.trim();
        if (raw.isEmpty) {
          socialUrls.add('');
          continue;
        }

        if (_socialNames[i] == 'Instagram') {
          // BUG FIX: the original screen prompted for an Instagram
          // *username* but then saved that bare username as-is, with no
          // domain - so the saved "link" couldn't actually be opened from
          // the public card. Reconstruct a real URL here, but don't
          // double-prefix if the user pasted a full link themselves.
          socialUrls.add(raw.startsWith('http') ? raw : 'https://instagram.com/$raw');
        } else {
          socialUrls.add(raw.startsWith('http') ? raw : 'https://$raw');
        }
      }

      // BUG FIX: socialIcons used to be saved as `socialNames` again (a
      // meaningless duplicate of the names list). It should be the
      // lowercase icon key that UserCard actually uses to resolve
      // `assets/icons/social_icons/<key>.png`.
      final socialIcons = _socialNames.map((n) => n.toLowerCase()).toList();

      await ref.read(userProvider.notifier).updateSocialIcons(
            socialNames: _socialNames,
            socialUrls: socialUrls,
            socialIcons: socialIcons,
          );

      if (mounted) context.showSuccessSnackBar(message: 'Social links saved!');
    } catch (e) {
      if (mounted) context.showErrorSnackBar(message: 'Failed to save: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit socials')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add links to your social profiles below.', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: _socialNames.length,
                separatorBuilder: (_, __) => const SizedBox(height: 4),
                itemBuilder: (context, index) {
                  final name = _socialNames[index];
                  final isInstagram = name == 'Instagram';
                  return ListenableBuilder(
                    listenable: _controllers[index],
                    builder: (context, _) {
                      final hasValue = _controllers[index].text.trim().isNotEmpty;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            AnimatedOpacity(
                              opacity: hasValue ? 1 : 0.25,
                              duration: const Duration(milliseconds: 150),
                              child: Image.asset(_iconAssetFor(name), width: 28, height: 28),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(name, style: theme.textTheme.titleSmall),
                                  const SizedBox(height: 4),
                                  TextField(
                                    controller: _controllers[index],
                                    decoration: InputDecoration(
                                      labelText: isInstagram ? 'Username' : 'URL',
                                      isDense: true,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            ElevatedButton.icon(
              onPressed: _isSaving ? null : _submit,
              icon: _isSaving
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.save_outlined),
              label: Text(_isSaving ? 'Saving...' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }
}