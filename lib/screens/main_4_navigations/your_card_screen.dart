import 'package:card_app/widgets/share_card_bottom_sheet.dart';
import 'package:card_app/widgets/ui/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/user_provider.dart';
import 'package:card_app/utilities/app_colors.dart';
import 'package:card_app/utilities/constants.dart';
import 'package:card_app/screens/editing_card/navigator.dart';
import 'package:card_app/widgets/user_card.dart';

class YourCardScreen extends ConsumerWidget {
  const YourCardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(appName),
        actions: [
          if (userAsync.value != null)
            TextButton.icon(
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text('Edit'),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const EditScreenNavigator()));
              },
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: userAsync.when(
        error: (e, _) => ErrorState(
          message: e.toString(),
          onRetry: () => ref.read(userProvider.notifier).refreshUser(),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        data: (data) {
          if (data == null) {
            return const EmptyState(
              icon: Icons.badge_outlined,
              title: 'No card yet',
              message: 'Finish setting up your profile to see your card here.',
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 96),
            child: UserCard(data: data),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: userAsync.value == null
          ? null
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.ios_share_rounded, size: 20),
                  label: const Text('Share card'),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
                      ),
                      builder: (context) => ShareCardBottomSheet(userData: userAsync.value!),
                    );
                  },
                ),
              ),
            ),
    );
  }
}