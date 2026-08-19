import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:card_app/providers/user_provider.dart';
import 'package:card_app/utilities/url_utils.dart';
import 'package:card_app/widgets/snackbars.dart';

class LinksPage extends ConsumerStatefulWidget {
  const LinksPage({super.key});

  @override
  ConsumerState<LinksPage> createState() => _LinksPageState();
}

class _LinksPageState extends ConsumerState<LinksPage> {
  List<TextEditingController> _linkTextControllers = [];
  List<TextEditingController> _linkUrlControllers = [];
  final TextEditingController _sectionHeaderController = TextEditingController();

  bool _isLoading = false;
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final user = ref.read(userProvider).asData?.value;
    final linksText = user?.linksText ?? [];
    final linkUrl = user?.linkUrl ?? [];
    final header = user?.linkSectionHeader ?? '';

    _sectionHeaderController.text = header;
    _sectionHeaderController.addListener(_onTextChanged);

    final itemCount = linksText.isNotEmpty ? linksText.length : 1;

    _linkTextControllers = List.generate(itemCount, (index) {
      final controller = TextEditingController(text: linksText.length > index ? linksText[index] : '');
      controller.addListener(_onTextChanged);
      return controller;
    });

    _linkUrlControllers = List.generate(itemCount, (index) {
      final controller = TextEditingController(text: linkUrl.length > index ? linkUrl[index] : '');
      controller.addListener(_onTextChanged);
      return controller;
    });
  }

  void _onTextChanged() {
    if (!_hasUnsavedChanges) setState(() => _hasUnsavedChanges = true);
  }

  @override
  void dispose() {
    _sectionHeaderController.removeListener(_onTextChanged);
    _sectionHeaderController.dispose();
    for (var c in _linkTextControllers) {
      c.removeListener(_onTextChanged);
      c.dispose();
    }
    for (var c in _linkUrlControllers) {
      c.removeListener(_onTextChanged);
      c.dispose();
    }
    super.dispose();
  }

  void _addNewLinkField() {
    final newTextController = TextEditingController()..addListener(_onTextChanged);
    final newUrlController = TextEditingController()..addListener(_onTextChanged);
    setState(() {
      _linkTextControllers.insert(0, newTextController);
      _linkUrlControllers.insert(0, newUrlController);
      _hasUnsavedChanges = true;
    });
  }

  void _removeLinkField(int index) {
    if (_linkTextControllers.length <= 1) return;
    final removedText = _linkTextControllers.removeAt(index);
    final removedUrl = _linkUrlControllers.removeAt(index);
    removedText.removeListener(_onTextChanged);
    removedUrl.removeListener(_onTextChanged);
    removedText.dispose();
    removedUrl.dispose();
    setState(() => _hasUnsavedChanges = true);
  }

  Future<void> _submit() async {
    if (_isLoading) return;

    final linksText = _linkTextControllers.map((c) => c.text.trim()).toList();
    final linkUrl = _linkUrlControllers.map((c) => c.text.trim()).toList();
    final header = _sectionHeaderController.text.trim();

    if (linksText.any((t) => t.isEmpty) || linkUrl.any((u) => u.isEmpty)) {
      context.showErrorSnackBar(message: 'Please fill all fields');
      return;
    }

    // Normalize + validate every URL the same way socials and scheduling do,
    // so a link like "myportfolio" is rejected rather than saved unopenable.
    final normalizedUrls = <String>[];
    for (var i = 0; i < linkUrl.length; i++) {
      final normalized = normalizeUrl(linkUrl[i]);
      if (normalized == null) {
        context.showErrorSnackBar(
          message: 'Link ${i + 1}: enter a valid URL (e.g. https://example.com)',
        );
        return;
      }
      normalizedUrls.add(normalized);
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(userProvider.notifier).updateLinksSection(
            linksText: linksText,
            linkUrl: normalizedUrls,
            linkSectionHeader: header,
          );
      setState(() => _hasUnsavedChanges = false);
      if (mounted) context.showSuccessSnackBar(message: 'Links updated successfully!');
    } catch (e) {
      if (mounted) context.showErrorSnackBar(message: 'Failed to update links: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildLinkCard(int index) {
    final theme = Theme.of(context);
    return Container(
      key: ValueKey(_linkTextControllers[index]),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.link, color: theme.colorScheme.primary, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text('Link ${index + 1}', style: theme.textTheme.titleSmall)),
                if (_linkTextControllers.length > 1)
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: theme.colorScheme.error, size: 20),
                    onPressed: () => _removeLinkField(index),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _linkTextControllers[index],
              decoration: const InputDecoration(labelText: 'Display text', hintText: 'e.g., Visit my portfolio'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _linkUrlControllers[index],
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(labelText: 'URL', hintText: 'https://example.com'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldLeave = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Unsaved changes'),
                content: const Text('Are you sure you want to leave?'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                  TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Leave')),
                ],
              ),
            ) ??
            false;
        if (shouldLeave && context.mounted) Navigator.pop(context);
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Edit links')),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _sectionHeaderController,
                  decoration: const InputDecoration(
                    labelText: 'Section title',
                    hintText: 'e.g., Useful Links, Resources',
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _linkTextControllers.length,
                  itemBuilder: (context, index) => _buildLinkCard(index),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _addNewLinkField,
                        icon: const Icon(Icons.add),
                        label: const Text('Add link'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _isLoading ? null : _submit,
                        icon: _isLoading
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.save_outlined),
                        label: Text(_isLoading ? 'Saving...' : 'Save'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}