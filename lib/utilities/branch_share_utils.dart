import 'package:flutter_branch_sdk/flutter_branch_sdk.dart' as branch_sdk;

Future<String> createBranchShareLink(String uid, String username, String name) async {
  final buo = branch_sdk.BranchUniversalObject(
    canonicalIdentifier: 'profile/$uid/$username',
    title: 'Check out my profile on Connecta!',
    contentDescription: "Scan to view $name's business card",
    contentMetadata: branch_sdk.BranchContentMetaData()
      ..addCustomMetadata('username', username)
      ..addCustomMetadata('uid', uid),
  );

  final lp = branch_sdk.BranchLinkProperties(
    channel: 'app',
    feature: 'share',
    alias: username,
  )..addControlParam(
      // BUG FIX: this was previously the raw string r'\$fallback_url', which
      // (because raw strings don't process escapes) sent the literal key
      // "\$fallback_url" - backslash included - to Branch instead of the
      // "$fallback_url" key it actually expects, silently breaking the
      // fallback URL for anyone without the app installed.
      '\$fallback_url',
      'https://business-cards-web.vercel.app/user/$username',
    );

  final response = await branch_sdk.FlutterBranchSdk.getShortUrl(buo: buo, linkProperties: lp);

  final branchLink = response.result;
  if (branchLink == null) {
    throw Exception(response.errorMessage ?? 'Branch returned no link.');
  }
  return branchLink;
}