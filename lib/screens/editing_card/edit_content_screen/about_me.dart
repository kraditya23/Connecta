import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:card_app/providers/user_provider.dart';
import 'package:card_app/widgets/snackbars.dart';

class EditAboutPage extends ConsumerStatefulWidget {
  const EditAboutPage({super.key});

  @override
  ConsumerState<EditAboutPage> createState() => _EditAboutPageState();
}

class _EditAboutPageState extends ConsumerState<EditAboutPage> {
  late TextEditingController _controller;
  bool _isLoading = false;
  bool _hasChanges = false;

  static const int _maxCharacters = 2000;

  @override
  void initState() {
    super.initState();
    final aboutText = ref.read(userProvider).value?.aboutMe ?? '';
    _controller = TextEditingController(text: aboutText);

    _controller.addListener(() {
      final originalText = ref.read(userProvider).value?.aboutMe ?? '';
      final hasChanges = _controller.text.trim() != originalText.trim();
      if (hasChanges != _hasChanges) setState(() => _hasChanges = hasChanges);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveAboutMe() async {
    if (!_hasChanges) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(userProvider.notifier).updateAboutMe(_controller.text.trim());
      if (mounted) {
        context.showSuccessSnackBar(message: 'About section updated!');
        setState(() => _hasChanges = false);
      }
    } catch (e) {
      if (mounted) context.showErrorSnackBar(message: 'Failed to save: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<bool> _confirmDiscard() async {
    if (!_hasChanges) return true;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Unsaved changes'),
        content: const Text('Discard your changes?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProvider);
    final theme = Theme.of(context);
    final characterCount = _controller.text.length;
    final isOverLimit = characterCount > _maxCharacters;

    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _confirmDiscard() && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit About'),
          actions: [
            if (_hasChanges)
              TextButton.icon(
                onPressed: _isLoading ? null : _saveAboutMe,
                icon: _isLoading
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.save_outlined, size: 18),
                label: Text(_isLoading ? 'Saving...' : 'Save'),
              ),
          ],
        ),
        body: userAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: 56, color: theme.colorScheme.error),
                  const SizedBox(height: 16),
                  Text('Something went wrong', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => ref.read(userProvider.notifier).refreshUser(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try again'),
                  ),
                ],
              ),
            ),
          ),
          data: (userData) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Share a brief description so others can get to know you. This appears on your card.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _controller,
                    maxLines: 8,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: InputDecoration(
                      hintText: "I'm passionate about...",
                      errorText: isOverLimit ? 'Character limit exceeded' : null,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text('$characterCount / $_maxCharacters', style: theme.textTheme.bodySmall),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (_hasChanges && !isOverLimit && !_isLoading) ? _saveAboutMe : null,
                      child: Text(_hasChanges ? 'Save changes' : 'No changes'),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}