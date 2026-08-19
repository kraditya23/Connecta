import 'package:card_app/utilities/app_colors.dart';
import 'package:card_app/widgets/snackbars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:card_app/providers/user_provider.dart';
import 'package:card_app/providers/connections_provider.dart';
import 'package:card_app/widgets/user_card.dart';
import 'package:card_app/models/user_data.dart';

class ProfilePage extends ConsumerStatefulWidget {
  final String uid;
  final String profileUsername;
  final bool fromConnections;
  const ProfilePage({
    required this.uid,
    required this.profileUsername,
    this.fromConnections = false,
    super.key,
  });

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  bool _isProcessing = false;
  bool _isConnected = false;
  UserData? _profileData;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    if (widget.fromConnections) {
      _isConnected = true;
    } else {
      _checkIfConnected();
    }
  }

  Future<void> _loadProfile() async {
    try {
      final data = await Supabase.instance.client
          .from('profiles')
          .select('*')
          .eq('id', widget.uid)
          .maybeSingle();

      if (!mounted) return;
      if (data == null) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
        return;
      }
      setState(() {
        _profileData = UserData.fromMap(data);
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() { _hasError = true; _isLoading = false; });
    }
  }

  Future<void> _checkIfConnected() async {
    final currentUid = ref.read(userProvider).asData?.value?.uid;
    if (currentUid == null) return;

    final response = await Supabase.instance.client
        .from('connections')
        .select('owner_id')
        .eq('owner_id', currentUid)
        .eq('connection_id', widget.uid)
        .maybeSingle();

    if (mounted && response != null) {
      setState(() => _isConnected = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUsername = ref.watch(userProvider).asData?.value?.username;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_hasError || _profileData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: Text('No user found')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.profileUsername)),
      body: SingleChildScrollView(
        child: UserCard(data: _profileData!),
      ),
      bottomNavigationBar:
          currentUsername != null && currentUsername != widget.profileUsername
              ? SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 11.0, vertical: 8.0),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width - 8,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isProcessing ? Colors.grey : primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.person_add_alt),
                        label: Text(
                          _isConnected
                              ? 'Already Connected'
                              : (_isProcessing ? 'Processing...' : 'Exchange Contacts'),
                        ),
                        onPressed: _isProcessing
                            ? null
                            : () async {
                                if (_isConnected) {
                                  context.showNeutralSnackBar(
                                    message: 'Connection already established!',
                                    icon: Icons.check,
                                  );
                                  return;
                                }
                                setState(() => _isProcessing = true);
                                try {
                                  await Supabase.instance.client.rpc(
                                    'exchange_contacts',
                                    params: {'target_username': widget.profileUsername},
                                  );
                                  if (!mounted) return;
                                  // Refresh the connections list so the new
                                  // connection shows up when the user returns
                                  // to the Connections tab.
                                  ref.invalidate(connectionsProvider);
                                  setState(() => _isConnected = true);
                                  context.showSuccessSnackBar(message: 'Contacts Exchanged!');
                                } catch (e) {
                                  if (mounted) {
                                    context.showErrorSnackBar(message: 'Error: ${e.toString()}');
                                  }
                                } finally {
                                  if (mounted) setState(() => _isProcessing = false);
                                }
                              },
                      ),
                    ),
                  ),
                )
              : null,
    );
  }
}
