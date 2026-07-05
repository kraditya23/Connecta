import 'package:card_app/providers/auth_session_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:card_app/models/user_data.dart';

final userProvider = StateNotifierProvider<UserNotifier, AsyncValue<UserData?>>((ref) {
  final notifier = UserNotifier();
  ref.listen(authSessionProvider, (previous, next) {
    notifier.loadUser();
  });
  return notifier;
});

class UserNotifier extends StateNotifier<AsyncValue<UserData?>> {
  UserNotifier() : super(const AsyncValue.loading()) {
    loadUser();
  }

  SupabaseClient get _client => Supabase.instance.client;

  Future<void> loadUser() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      state = const AsyncValue.data(null);
      return;
    }

    try {
      final data = await _client
          .from('profiles')
          .select('*')
          .eq('id', user.id)
          .maybeSingle();

      if (data == null) {
        state = const AsyncValue.data(null);
        return;
      }

      state = AsyncValue.data(UserData.fromMap(data));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> saveUser(String username) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Not signed in.');

    try {
      await _client.from('profiles').insert({
        'id': user.id,
        'username': username,
      });
      state = AsyncValue.data(UserData(uid: user.id, username: username));
    } on PostgrestException catch (e) {
      if (e.code == '23505') throw Exception('Username already taken!');
      rethrow;
    }
  }

  Future<void> updateContactInfo({
    required String name,
    required String profilePicUrl,
    required String coverPicUrl,
    required String jobTitle,
    required String organisation,
    required String location,
    required String address,
    required List<String> phoneNumbers,
    required List<String> emails,
  }) async {
    final currentUser = state.value;
    if (currentUser == null) throw Exception('No profile loaded.');

    await _client.from('profiles').update({
      'name': name,
      'profile_pic_url': profilePicUrl,
      'cover_pic_url': coverPicUrl,
      'job_title': jobTitle,
      'organisation': organisation,
      'location': location,
      'address': address,
      'phone_numbers': phoneNumbers,
      'emails': emails,
    }).eq('id', currentUser.uid);

    state = AsyncValue.data(currentUser.copyWith(
      name: name,
      profilePicUrl: profilePicUrl,
      coverPicUrl: coverPicUrl,
      jobTitle: jobTitle,
      organisation: organisation,
      location: location,
      address: address,
      phoneNumbers: phoneNumbers,
      emails: emails,
    ));
  }

  Future<void> updateLinksSection({
    required List<String> linksText,
    required List<String> linkUrl,
    String? linkSectionHeader,
  }) async {
    final currentUser = state.value;
    if (currentUser == null) throw Exception('No profile loaded.');

    final header = linkSectionHeader ?? currentUser.linkSectionHeader;
    await _client.from('profiles').update({
      'link_section_header': header,
      'links_text': linksText,
      'link_url': linkUrl,
    }).eq('id', currentUser.uid);

    state = AsyncValue.data(currentUser.copyWith(
      linkSectionHeader: header,
      linksText: linksText,
      linkUrl: linkUrl,
    ));
  }

  Future<void> updateAboutMe(String aboutMeText) async {
    final currentUser = state.value;
    if (currentUser == null) throw Exception('No profile loaded.');

    await _client.from('profiles').update({
      'about_me': aboutMeText,
    }).eq('id', currentUser.uid);

    state = AsyncValue.data(currentUser.copyWith(aboutMe: aboutMeText));
  }

  Future<void> updateSocialIcons({
    required List<String> socialNames,
    required List<String> socialUrls,
    required List<String> socialIcons,
  }) async {
    final currentUser = state.value;
    if (currentUser == null) throw Exception('No profile loaded.');

    await _client.from('profiles').update({
      'social_names': socialNames,
      'social_url': socialUrls,
      'social_icons': socialIcons,
    }).eq('id', currentUser.uid);

    state = AsyncValue.data(currentUser.copyWith(
      socialNames: socialNames,
      socialUrl: socialUrls,
      socialIcons: socialIcons,
    ));
  }

  Future<void> updateSchedulingLink(String newLink) async {
    final currentUser = state.value;
    if (currentUser == null) throw Exception('No profile loaded.');

    await _client.from('profiles').update({
      'scheduling': newLink,
    }).eq('id', currentUser.uid);

    state = AsyncValue.data(currentUser.copyWith(scheduling: newLink));
  }

  Future<void> refreshUser() => loadUser();

  void clearUser() => state = const AsyncValue.data(null);
}
