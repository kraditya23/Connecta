import 'package:card_app/providers/settings_provider.dart';
import 'package:card_app/widgets/snackbars.dart';
import 'package:card_app/widgets/ui/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MessageSnippetsScreen extends ConsumerWidget {
  const MessageSnippetsScreen({super.key});

  Future<void> _openEditor(BuildContext context, WidgetRef ref, {int? index, String initial = ''}) async {
    final controller = TextEditingController(text: initial);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(index == null ? 'New snippet' : 'Edit snippet'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'e.g. "Great meeting you - let\'s keep in touch!"'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Save')),
        ],
      ),
    );

    if (result == null || result.isEmpty) return;
    try {
      if (index == null) {
        await ref.read(settingsProvider.notifier).addSnippet(result);
      } else {
        await ref.read(settingsProvider.notifier).updateSnippet(index, result);
      }
    } catch (_) {
      if (context.mounted) context.showErrorSnackBar(message: 'Could not save snippet.');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider).value;
    final snippets = settings?.messageSnippets ?? const [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Message snippets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _openEditor(context, ref),
          ),
        ],
      ),
      body: snippets.isEmpty
          ? EmptyState(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'No snippets yet',
              message: 'Save quick follow-up messages to reuse after meeting new connections.',
              action: OutlinedButton.icon(
                onPressed: () => _openEditor(context, ref),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add a snippet'),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: snippets.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final snippet = snippets[index];
                return Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Theme.of(context).colorScheme.outline),
                  ),
                  child: ListTile(
                    title: Text(snippet),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _openEditor(context, ref, index: index, initial: snippet);
                        } else if (value == 'delete') {
                          ref.read(settingsProvider.notifier).removeSnippet(index);
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}