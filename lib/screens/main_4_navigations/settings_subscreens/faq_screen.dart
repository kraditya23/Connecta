import 'package:card_app/utilities/constants.dart';
import 'package:flutter/material.dart';

class _Faq {
  final String question;
  final String answer;
  const _Faq(this.question, this.answer);
}

const _faqs = [
  _Faq(
    'How do people view my card?',
    'Share your QR code or profile link from "Your card" → Share card. Anyone who scans it or '
        'opens the link sees your public profile instantly, no account required.',
  ),
  _Faq(
    'What happens when I "Exchange Contacts"?',
    'Both of you are added to each other\'s Connections list, so you can find their card again '
        'later without re-scanning.',
  ),
  _Faq(
    'Can I use $appName without the app installed?',
    'Yes - your profile link works in any browser. The app is only needed to edit your own card '
        'or manage connections.',
  ),
  _Faq(
    'Is my information public?',
    'Only what you add to your card is visible to anyone with your link or QR code. Account '
        'details like your sign-in email are never shown on your public card.',
  ),
  _Faq(
    'How do I remove a connection?',
    'Open their profile from your Connections list, tap the "⋮" menu, then Delete Connection.',
  ),
];

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FAQ')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _faqs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final faq = _faqs[index];
          return Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Theme.of(context).colorScheme.outline),
              ),
              clipBehavior: Clip.antiAlias,
              child: ExpansionTile(
                title: Text(faq.question, style: const TextStyle(fontWeight: FontWeight.w600)),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                expandedAlignment: Alignment.topLeft,
                children: [Text(faq.answer, style: Theme.of(context).textTheme.bodyMedium)],
              ),
            ),
          );
        },
      ),
    );
  }
}