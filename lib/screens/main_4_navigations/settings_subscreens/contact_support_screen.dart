import 'package:card_app/utilities/constants.dart';
import 'package:card_app/widgets/snackbars.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactSupportScreen extends StatefulWidget {
  const ContactSupportScreen({super.key});

  @override
  State<ContactSupportScreen> createState() => _ContactSupportScreenState();
}

class _ContactSupportScreenState extends State<ContactSupportScreen> {
  final _messageController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _openEmail() async {
    final uri = Uri(scheme: 'mailto', path: supportEmail, query: 'subject=Connecta support');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (mounted) {
      context.showErrorSnackBar(message: 'Could not open your email app.');
    }
  }

  Future<void> _sendInApp() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() => _isSending = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      await Supabase.instance.client.from('support_feedback').insert({
        'uid': user?.id,
        'email': user?.email,
        'message': message,
      });
      if (mounted) {
        context.showSuccessSnackBar(message: 'Thanks - we\'ll get back to you.');
        _messageController.clear();
      }
    } catch (e) {
      if (mounted) context.showErrorSnackBar(message: 'Could not send your message right now.');
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Contact us')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Send us a message', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          TextField(
            controller: _messageController,
            maxLines: 5,
            decoration: const InputDecoration(hintText: 'What can we help with?'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _isSending ? null : _sendInApp,
            child: Text(_isSending ? 'Sending...' : 'Send'),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text('or', style: theme.textTheme.bodySmall),
              ),
              const Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _openEmail,
            icon: const Icon(Icons.mail_outline_rounded),
            label: Text('Email $supportEmail'),
          ),
        ],
      ),
    );
  }
}
