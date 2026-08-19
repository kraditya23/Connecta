import 'package:card_app/providers/user_provider.dart';
import 'package:card_app/utilities/url_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:card_app/widgets/snackbars.dart';

class SchedulingPage extends ConsumerStatefulWidget {
  const SchedulingPage({super.key});

  @override
  ConsumerState<SchedulingPage> createState() => _SchedulingPageState();
}

class _SchedulingPageState extends ConsumerState<SchedulingPage> {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controller.text = ref.read(userProvider).value?.scheduling ?? '';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? _urlValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter your scheduling link.';
    if (normalizeUrl(value) == null) {
      return 'Please enter a valid URL (e.g., https://example.com).';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final schedulingLink = ref.watch(userProvider).value?.scheduling ?? '';
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Scheduling link')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Add your scheduling software link so people can book time with you directly from your card.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              if (schedulingLink.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.colorScheme.outline),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Current link', style: theme.textTheme.titleSmall),
                      const SizedBox(height: 8),
                      SelectableText(schedulingLink, style: theme.textTheme.bodyMedium),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final uri = Uri.parse(schedulingLink);
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri);
                                } else if (context.mounted) {
                                  context.showErrorSnackBar(message: 'Could not open link');
                                }
                              },
                              icon: const Icon(Icons.open_in_new, size: 18),
                              label: const Text('Open'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: schedulingLink));
                                context.showNeutralSnackBar(message: 'Copied to clipboard!', icon: Icons.copy);
                              },
                              icon: const Icon(Icons.copy, size: 18),
                              label: const Text('Copy'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: 'Scheduling link URL',
                  hintText: 'https://your-scheduling-software.com',
                ),
                keyboardType: TextInputType.url,
                autofillHints: const [AutofillHints.url],
                validator: _urlValidator,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _isSaving
                    ? null
                    : () async {
                        if (!(_formKey.currentState?.validate() ?? false)) return;
                        setState(() => _isSaving = true);
                        try {
                          // Store the normalized URL (scheme prepended if the
                          // user typed a bare domain) so the card can launch it.
                          final normalized = normalizeUrl(_controller.text) ?? _controller.text.trim();
                          await ref.read(userProvider.notifier).updateSchedulingLink(normalized);
                          if (mounted) context.showSuccessSnackBar(message: 'Scheduling link updated!');
                        } catch (e) {
                          if (mounted) context.showErrorSnackBar(message: 'Failed to update link: ${e.toString()}');
                        } finally {
                          if (mounted) setState(() => _isSaving = false);
                        }
                      },
                icon: _isSaving
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.save_outlined),
                label: Text(_isSaving ? 'Saving...' : 'Save link'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}