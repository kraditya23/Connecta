import '../models/user_data.dart';

/// ------------------------------------------------------------------------
/// Minimal-payload vCard generator for QR:
///
///    Only includes:
///      • Full Name       (FN + N)
///      • All phoneNumbers
///      • All emails
///      • Job Title
///      • Organisation
///
///    This keeps the QR-string short enough that most scanners (and most
///    phone cameras) can read it reliably - piling on every profile field
///    here would make the QR code dense enough to fail in poor lighting.
/// ------------------------------------------------------------------------
String generateMinimalVCardFromUserData(UserData data) {
  final buffer = StringBuffer();

  buffer.writeln('BEGIN:VCARD');
  buffer.writeln('VERSION:3.0');

  // 1. Name (N and FN)
  final name = data.name?.trim();
  final displayName = (name != null && name.isNotEmpty) ? name : data.username;

  final parts = displayName.split(' ');
  if (parts.length >= 2) {
    final mutableParts = [...parts];
    final family = mutableParts.removeLast();
    final given = mutableParts.join(' ');
    buffer.writeln('N:${_escapeValue(family)};${_escapeValue(given)}');
  } else {
    buffer.writeln('N:${_escapeValue(displayName)};${_escapeValue(displayName)}');
  }
  buffer.writeln('FN:${_escapeValue(displayName)}');

  // 2. Organisation & Job Title
  if (data.organisation != null && data.organisation!.trim().isNotEmpty) {
    buffer.writeln('ORG:${_escapeValue(data.organisation!.trim())}');
  }
  if (data.jobTitle != null && data.jobTitle!.trim().isNotEmpty) {
    buffer.writeln('TITLE:${_escapeValue(data.jobTitle!.trim())}');
  }

  // 3. Phone numbers (all of them, each as TYPE=CELL)
  for (final phone in data.phoneNumbers ?? <String>[]) {
    final p = phone.trim();
    if (p.isNotEmpty) {
      buffer.writeln('TEL;TYPE=CELL:${_escapeValue(p)}');
    }
  }

  // 4. Emails (all of them)
  for (final email in data.emails ?? <String>[]) {
    final e = email.trim();
    if (e.isNotEmpty) {
      buffer.writeln('EMAIL:${_escapeValue(e)}');
    }
  }

  buffer.writeln('END:VCARD');
  return buffer.toString();
}

/// Escapes special characters in vCard values per RFC 2426.
String _escapeValue(String value) {
  return value
      .replaceAll(r'\', r'\\')
      .replaceAll('\n', r'\n')
      .replaceAll(';', r'\;')
      .replaceAll(',', r'\,');
}