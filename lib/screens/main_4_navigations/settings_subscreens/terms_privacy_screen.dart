import 'package:card_app/utilities/constants.dart';
import 'package:flutter/material.dart';

class TermsPrivacyScreen extends StatelessWidget {
  const TermsPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Terms & Privacy')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer.withOpacity(0.4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Placeholder content. This is a generic starting template, not a finished legal '
              'document - have an actual lawyer review and tailor this before launch.',
              style: theme.textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 24),
          Text('Terms of Use', style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          Text(
            'By using $appName, you agree to provide accurate profile information and to use the '
            'app only for lawful, legitimate networking purposes. You\'re responsible for the '
            'content of your own card, including any photos, links, or contact details you upload. '
            'We may suspend accounts that violate these terms or misuse the service.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Text('Privacy Policy', style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          Text(
            'Your public card (name, photo, job title, links, and similar fields you choose to add) '
            'is visible to anyone with your card link or QR code. Your sign-in email and password '
            'are never shown publicly. Connections are stored so both parties can find each other\'s '
            'card again later. You can delete your account and associated profile data at any time '
            'from Settings → Delete account.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Text('Contact', style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          Text('Questions about these terms? Reach us at $supportEmail.', style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}