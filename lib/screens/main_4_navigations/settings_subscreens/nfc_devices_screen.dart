import 'package:card_app/widgets/ui/empty_state.dart';
import 'package:flutter/material.dart';

class NfcDevicesScreen extends StatelessWidget {
  const NfcDevicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NFC devices')),
      body: const EmptyState(
        icon: Icons.nfc_rounded,
        title: 'Coming soon',
        message: 'Pairing physical NFC cards and tags to tap-to-share your profile is on the roadmap.',
      ),
    );
  }
}