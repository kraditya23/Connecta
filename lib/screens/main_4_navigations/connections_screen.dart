import 'package:card_app/screens/connection_profile_page.dart';
import 'package:card_app/utilities/constants.dart';
import 'package:card_app/widgets/ui/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:card_app/providers/connections_provider.dart';
import 'package:card_app/screens/qr_scanner_screen.dart';
import 'package:card_app/screens/profile_page.dart';

class ConnectionsScreen extends ConsumerStatefulWidget {
  const ConnectionsScreen({super.key});

  @override
  ConsumerState<ConnectionsScreen> createState() => _ConnectionsScreenState();
}

class _ConnectionsScreenState extends ConsumerState<ConnectionsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openScanner() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QrScannerScreen(
          onScanned: (uid, username) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => ProfilePage(uid: uid, profileUsername: username)),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final connectionsAsync = ref.watch(connectionsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Connections'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.tonalIcon(
              onPressed: _openScanner,
              icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
              label: const Text('Scan'),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: const InputDecoration(
                hintText: 'Search connections',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
          ),
          Expanded(
            child: connectionsAsync.when(
              data: (connections) {
                if (connections.isEmpty) {
                  return EmptyState(
                    icon: Icons.people_alt_outlined,
                    title: 'No connections yet',
                    message: 'Scan someone\'s $appName QR code to exchange contacts.',
                    action: OutlinedButton.icon(
                      onPressed: _openScanner,
                      icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
                      label: const Text('Scan a QR code'),
                    ),
                  );
                }

                final filtered = _searchQuery.isEmpty
                    ? connections
                    : connections
                        .where((c) => c.name.toLowerCase().contains(_searchQuery.toLowerCase()))
                        .toList();

                if (filtered.isEmpty) {
                  return EmptyState(
                    icon: Icons.search_off_rounded,
                    title: 'No matches',
                    message: 'No connections match "$_searchQuery".',
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final conn = filtered[index];
                    final hasRole = (conn.jobTitle?.isNotEmpty ?? false) || (conn.organisation?.isNotEmpty ?? false);
                    final roleLine = [conn.jobTitle, conn.organisation]
                        .where((e) => e != null && e.isNotEmpty)
                        .join(' • ');

                    return ListTile(
                      leading: CircleAvatar(
                        radius: 24,
                        backgroundColor: theme.colorScheme.primaryContainer,
                        backgroundImage: (conn.profilePicUrl?.isNotEmpty ?? false)
                            ? NetworkImage(conn.profilePicUrl!)
                            : null,
                        child: (conn.profilePicUrl?.isNotEmpty ?? false)
                            ? null
                            : Text(
                                conn.name.isNotEmpty ? conn.name[0].toUpperCase() : '?',
                                style: TextStyle(color: theme.colorScheme.onPrimaryContainer, fontWeight: FontWeight.w600),
                              ),
                      ),
                      title: Text(conn.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(
                        hasRole
                            ? roleLine
                            : conn.since != null
                                ? 'Connected ${conn.since!.toLocal().toString().split(' ')[0]}'
                                : 'Connected',
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ConnectionProfilePage(
                              uid: conn.uid,
                              profileUsername: conn.username,
                              fromConnections: true,
                            ),
                          ),
                        );
                      },
                    );
                  },
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1, indent: 72, endIndent: 16),
                );
              },
              error: (e, st) => ErrorState(
                message: e.toString(),
                onRetry: () => ref.invalidate(connectionsProvider),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      ),
    );
  }
}