import 'package:card_app/models/user_data.dart';
import 'package:card_app/providers/connections_provider.dart';
import 'package:card_app/services/native_contacts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:ui';

class ConnectionMenuBottomSheet extends ConsumerStatefulWidget {
  final String connectionUsername;
  final UserData userData;

  const ConnectionMenuBottomSheet({
    super.key,
    required this.connectionUsername,
    required this.userData,
  });

  @override
  ConsumerState<ConnectionMenuBottomSheet> createState() =>
      _ConnectionMenuBottomSheetState();
}

class _ConnectionMenuBottomSheetState extends ConsumerState<ConnectionMenuBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.5,
        minChildSize: 0.45,
        maxChildSize: 0.5,
        builder: (context, scrollController) {
          return ListView(
            controller: scrollController,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: Text(
                    'Manage Connection',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.download),
                title: const Text('Save Contact to phone'),
                onTap: () async {
                  Navigator.pop(context);
                  final contactMap = buildContactMap(widget.userData);
                  final success = await NativeContacts.addOrUpdateContact(contactMap);
                  if (!success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Could not open native "Add Contact" UI')),
                    );
                  }
                },
              ),
              // TODO: "Add Notes" hidden until implemented — re-enable here
              // once the notes feature exists.
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete Connection', style: TextStyle(color: Colors.red)),
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete connection'),
                      content: const Text('Are you sure you want to delete this connection?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Delete', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => PopScope(
                        canPop: false,
                        onPopInvokedWithResult: (didPop, details) {},
                        child: Stack(
                          children: [
                            BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                              child: Container(color: Colors.black.withAlpha((0.2 * 255).toInt())),
                            ),
                            const Center(child: CircularProgressIndicator()),
                          ],
                        ),
                      ),
                    );
                    try {
                      await Supabase.instance.client.rpc(
                        'delete_connection',
                        params: {'target_username': widget.connectionUsername},
                      );
                      // Refresh the connections list so the deleted connection
                      // disappears when the user returns to the Connections tab.
                      ref.invalidate(connectionsProvider);
                      Navigator.pop(context); // Remove loading overlay
                      Navigator.pop(context, true); // Close bottom sheet
                    } catch (e) {
                      Navigator.pop(context); // Remove loading overlay
                      Navigator.pop(context, false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to delete connection')),
                      );
                    }
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

Map<String, dynamic> buildContactMap(UserData data) {
  final List<Map<String, String>> websites = [];

  if (data.linkUrl != null) {
    for (int i = 0; i < data.linkUrl!.length; i++) {
      final rawUrl = data.linkUrl![i].trim();
      if (rawUrl.isEmpty) continue;
      websites.add({'url': rawUrl, 'label': data.linksText![i].trim()});
    }
  }

  if (data.socialUrl != null) {
    for (int i = 0; i < data.socialUrl!.length; i++) {
      final rawUrl = data.socialUrl![i].trim();
      if (rawUrl.isEmpty) continue;
      websites.add({'url': rawUrl, 'label': data.socialNames![i].trim()});
    }
  }

  if (data.scheduling != null && data.scheduling!.trim().isNotEmpty) {
    websites.add({'url': data.scheduling!.trim(), 'label': 'Scheduling'});
  }

  return {
    'fullName': data.name?.trim() ?? data.username,
    'phones': data.phoneNumbers ?? <String>[],
    'emails': data.emails ?? <String>[],
    'organisation': data.organisation ?? '',
    'jobTitle': data.jobTitle ?? '',
    'websites': websites,
    'location': data.location ?? '',
    'aboutMe': data.aboutMe ?? '',
  };
}
