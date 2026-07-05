// Credentials are supplied at build/run time via --dart-define-from-file=.env.json
// so they never appear in source control.
//
// To set up locally:
//   cp .env.json.example .env.json
//   # fill in your values, then:
//   flutter run --dart-define-from-file=.env.json
//
// Both values are safe to store in .env.json — they are the Supabase anon/public
// key, intentionally client-visible and protected solely by Row Level Security.
const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

// Deep-link URL the OS opens after Supabase finishes email verification /
// password-reset. Must match the scheme registered in AndroidManifest.xml and
// ios/Runner/Info.plist, and must be whitelisted in the Supabase dashboard
// Authentication → URL Configuration → Redirect URLs.
const String supabaseRedirectUrl = 'connecta://login-callback';
