/// Normalizes a user-entered URL for storage and later launching.
///
/// Behaviour (shared by links, socials and the scheduling link so every form
/// validates URLs the same way):
///   • Returns the input unchanged if it already starts with http:// or https://.
///   • Auto-prepends `https://` when the input looks like a bare domain
///     (e.g. "linkedin.com/in/aditya" or "calendly.com/me") so pasting without
///     a scheme still works.
///   • Returns null if the result isn't a plausible web URL — i.e. it has no
///     host containing a dot — so callers can reject bare usernames or junk
///     rather than silently saving a link that won't open.
String? normalizeUrl(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return null;

  final candidate = (trimmed.startsWith('http://') || trimmed.startsWith('https://'))
      ? trimmed
      : 'https://$trimmed';

  final uri = Uri.tryParse(candidate);
  if (uri != null && uri.hasScheme && uri.hasAuthority && uri.host.contains('.')) {
    return candidate;
  }
  return null;
}
