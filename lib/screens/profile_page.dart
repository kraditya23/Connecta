import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:card_app/models/user_data.dart';
import 'package:card_app/providers/user_provider.dart';
import 'package:card_app/providers/connections_provider.dart';
import 'package:card_app/utilities/app_colors.dart';
import 'package:card_app/widgets/user_card.dart';
import 'package:card_app/widgets/ui/empty_state.dart';
import 'package:card_app/widgets/connection_menu_bottom_sheet.dart';
import 'package:card_app/widgets/snackbars.dart';

/// Shows another person's business card. Used both right after scanning a QR
/// code (not yet connected → "Exchange contacts") and when opening an existing
/// connection from the Connections list ([fromConnections] → manage menu).
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
  UserData? _profileData;
  bool _isLoading = true;
  bool _hasError = false;
  bool _isConnected = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _isConnected = widget.fromConnections;
    _loadProfile();
    if (!widget.fromConnections) _checkIfConnected();
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
        setState(() { _hasError = true; _isLoading = false; });
        return;
      }
      setState(() {
        _profileData = UserData.fromMap(data);
        _isLoading = false;
      });
    } catch (_) {
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
    if (mounted && response != null) setState(() => _isConnected = true);
  }

  Future<void> _exchangeContacts() async {
    setState(() => _isProcessing = true);
    try {
      await Supabase.instance.client.rpc(
        'exchange_contacts',
        params: {'target_username': widget.profileUsername},
      );
      if (!mounted) return;
      // Refresh the connections list so the new connection shows up when the
      // user returns to the Connections tab.
      ref.invalidate(connectionsProvider);
      setState(() => _isConnected = true);
      context.showSuccessSnackBar(message: 'Contacts exchanged!');
    } catch (e) {
      if (mounted) context.showErrorSnackBar(message: 'Error: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _openManageMenu() async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (context) => ConnectionMenuBottomSheet(
        connectionUsername: widget.profileUsername,
        userData: _profileData!,
      ),
    );
    // The sheet returns true when the connection was deleted -> leave the page.
    if (result == true && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final currentUsername = ref.watch(userProvider).asData?.value?.username;
    final isSelf = currentUsername != null && currentUsername == widget.profileUsername;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.profileUsername)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_hasError || _profileData == null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.profileUsername)),
        body: const EmptyState(
          icon: Icons.person_off_outlined,
          title: 'Profile not found',
          message: 'We couldn\'t load this profile. It may have been removed.',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.profileUsername),
        actions: [
          if (_isConnected && !isSelf)
            IconButton(
              icon: const Icon(Icons.more_vert_rounded),
              tooltip: 'Manage connection',
              onPressed: _openManageMenu,
            ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: UserCard(data: _profileData!),
      ),
      bottomNavigationBar: (!_isConnected && !isSelf)
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.person_add_alt_1_rounded, size: 20),
                  label: Text(_isProcessing ? 'Exchanging…' : 'Exchange contacts'),
                  onPressed: _isProcessing ? null : _exchangeContacts,
                ),
              ),
            )
          : null,
    );
  }
}
