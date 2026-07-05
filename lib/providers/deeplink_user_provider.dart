import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef DeepLinkUser = ({String uid, String username});

class DeepLinkUserNotifier extends StateNotifier<DeepLinkUser?> {
  DeepLinkUserNotifier() : super(null);

  void setUser(String uid, String username) => state = (uid: uid, username: username);

  void clear() => state = null;
}

final deepLinkUserProvider = StateNotifierProvider<DeepLinkUserNotifier, DeepLinkUser?>(
  (ref) => DeepLinkUserNotifier(),
);