/// Builds a self-contained profile link using the app's custom URI scheme.
///
/// The link only resolves on a device that already has Connecta installed
/// (the `connecta://` scheme is registered in AndroidManifest.xml and
/// Info.plist). This is intentional: the app has no web fallback or store
/// listing, so there is nothing to defer to for app-less recipients.
String buildProfileLink(String username) => 'connecta://profile/$username';
