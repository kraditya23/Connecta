import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:card_app/widgets/user_card.dart';
import 'package:card_app/models/user_data.dart';
import 'package:card_app/widgets/connection_menu_bottom_sheet.dart';

class ConnectionProfilePage extends ConsumerStatefulWidget {
  final String uid;
  final String profileUsername;
  final bool fromConnections;
  const ConnectionProfilePage({
    required this.uid,
    required this.profileUsername,
    this.fromConnections = false,
    super.key,
  });

  @override
  ConsumerState<ConnectionProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ConnectionProfilePage> {
  UserData? _profileData;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
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
    } catch (e) {
      if (mounted) setState(() { _hasError = true; _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
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
      appBar: AppBar(
        title: Text(widget.profileUsername),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () async {
              final result = await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Theme.of(context).cardColor,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                builder: (context) => ConnectionMenuBottomSheet(
                  connectionUsername: widget.profileUsername,
                  userData: _profileData!,
                ),
              );
              if (result == true) {
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: UserCard(data: _profileData!),
      ),
    );
  }
}
