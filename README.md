<div align="center">

# Connecta

### Digital Business Cards, Reimagined

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![Supabase](https://img.shields.io/badge/Supabase-2.x-3ECF8E?logo=supabase)](https://supabase.com)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey?logo=flutter)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

</div>

---

## 📖 Description

**Connecta** is a mobile-first digital business card platform built with Flutter. Users claim a unique username, build a rich profile card with their contact details, links, and social handles, then share it instantly via QR code or deep link — no paper required.

The backend is powered by [Supabase](https://supabase.com) (Postgres + Auth + Storage + Edge Functions), with Row Level Security enforcing data ownership at the database layer. Credentials are never baked into the source tree.

---

## ✨ Features

- 🪪 **Digital Business Cards** — Build and customise a profile card with contact info, job title, organisation, bio, links, and social icons
- 🔑 **Unique Username System** — Claim a globally unique handle; your card lives at a shareable deep link tied to your username
- 🔗 **QR Code Sharing** — Generate a branded QR code for your card; scan others' codes in-app to add connections
- 🤝 **Connections** — Mutually exchange contact cards with other users and manage your network
- 🔒 **Secure Auth** — Email/password sign-up with verification flow, plus one-tap Google Sign-In
- ☁️ **Real-time Backed by Supabase** — Postgres with RLS, Supabase Storage for profile images, and Edge Functions for sensitive operations
- 🌙 **Dark Mode** — Full light/dark theme support driven by system preference or manual toggle
- *(Add your feature here)*
- *(Add your feature here)*

---

## 🛠 Tech Stack

| Layer | Technology |
|---|---|
| **UI Framework** | [Flutter](https://flutter.dev) 3.x / Dart 3.x |
| **State Management** | [Riverpod 2](https://riverpod.dev) (StateNotifierProvider, FutureProvider, StreamProvider) |
| **Backend / Database** | [Supabase](https://supabase.com) — Postgres, Row Level Security, Storage |
| **Authentication** | Supabase Auth (email + password, Google Sign-In via `google_sign_in`) |
| **Image Storage** | Supabase Storage (`profile-assets` bucket) |
| **Edge Functions** | Supabase Edge Functions (Deno) — account deletion |
| **Deep Links** | [Branch SDK](https://branch.io) (`flutter_branch_sdk`) |
| **QR Codes** | `mobile_scanner` (scan), `pretty_qr_code` (generate) |
| **Fonts** | Google Fonts |
| **Platforms** | Android, iOS |

---

## ✅ Prerequisites

Make sure the following are installed and configured before cloning:

- [Flutter SDK](https://docs.flutter.dev/get-started/install) `>= 3.8.1`
- [Dart SDK](https://dart.dev/get-dart) `>= 3.8.1` (bundled with Flutter)
- [Android Studio](https://developer.android.com/studio) or [Xcode](https://developer.apple.com/xcode/) for simulators and device deployment
- A [Supabase](https://supabase.com) account (free tier is sufficient)
- A [Google Cloud Console](https://console.cloud.google.com) project with OAuth 2.0 credentials (for Google Sign-In)
- A [Branch](https://branch.io) account (for deep links; free tier available)

Verify your Flutter environment is healthy before proceeding:

```bash
flutter doctor
```

---

## 🚀 Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/<your-username>/connecta.git
cd connecta/mobile-app
```

### 2. Install Flutter dependencies

```bash
flutter pub get
```

### 3. Set up your Supabase project

> ⚠️ **The real Supabase credentials are never committed to this repository.** You must connect your own Supabase project before the app will build successfully.

**a) Create a Supabase project**

Go to [supabase.com](https://supabase.com), create a new project, and note your **Project URL** and **anon public key** from *Project Settings → API*.

**b) Run the database migration**

In your Supabase dashboard, open the **SQL Editor** and run the full contents of:

```
supabase/migrations/0001_init.sql
```

This creates the `profiles` and `connections` tables, all RLS policies, the `profile-assets` storage bucket, and the `exchange_contacts` / `delete_connection` RPCs.

**c) Configure Google Sign-In** *(skip if you don't need Google auth)*

In the Supabase dashboard, go to *Authentication → Providers → Google* and enter your Google OAuth Client ID and Secret. Follow the [Supabase Google Auth guide](https://supabase.com/docs/guides/auth/social-login/auth-google) for the complete setup.

**d) Configure email redirect URLs**

In *Authentication → URL Configuration*:

| Field | Value |
|---|---|
| Site URL | `connecta://login-callback` |
| Redirect URLs | `connecta://login-callback` |

This ensures verification and password-reset emails open the app correctly on both Android and iOS.

**e) Deploy the Edge Function**

Install the [Supabase CLI](https://supabase.com/docs/guides/cli), then:

```bash
npx supabase login
npx supabase link --project-ref <your-project-ref>
npx supabase functions deploy delete-account
```

### 4. Create your local credentials file

```bash
cp .env.json.example .env.json
```

Open `.env.json` and fill in your values:

```json
{
  "SUPABASE_URL": "https://your-project-ref.supabase.co",
  "SUPABASE_ANON_KEY": "your-anon-public-key-here"
}
```

> `.env.json` is listed in `.gitignore` and will never be committed. The anon key is safe to use client-side — all security is enforced by Postgres Row Level Security, not by keeping this key secret.

### 5. Run the app

```bash
flutter run --dart-define-from-file=.env.json
```

> ⚠️ **Every run must include the `--dart-define-from-file=.env.json` flag.** Without it the app asserts on startup with a clear error message. Configure your IDE once so you never forget:

**VS Code** — add to `.vscode/launch.json`:

```json
{
  "configurations": [
    {
      "name": "Connecta (debug)",
      "request": "launch",
      "type": "dart",
      "args": ["--dart-define-from-file=.env.json"]
    }
  ]
}
```

**Android Studio** — *Run → Edit Configurations → Additional run args*:

```
--dart-define-from-file=.env.json
```

---

## 🏗 Architecture & Folder Structure

```
mobile-app/
├── lib/
│   ├── main.dart                   # Entry point; Supabase.initialize()
│   ├── models/                     # Pure data classes (UserData, Connection, AppSettings)
│   ├── providers/                  # Riverpod providers (auth, user, connections, settings)
│   ├── screens/
│   │   ├── authenticate/           # Login, sign-up, password reset
│   │   ├── editing_card/           # Card editing flow (contact, content, links, social)
│   │   ├── onboarding/             # Welcome screen + username claim
│   │   └── main_4_navigations/     # Bottom-nav screens + settings sub-screens
│   ├── services/
│   │   ├── auth/                   # AuthProvider interface + SupabaseAuthProvider impl
│   │   └── storage/                # SupabaseStorageService (profile/cover image uploads)
│   ├── utilities/                  # App colours, constants, helpers, supabase_config.dart
│   └── widgets/                    # Reusable UI components (cards, bottom sheets, snackbars)
│
├── supabase/
│   ├── migrations/
│   │   └── 0001_init.sql           # Full schema: tables, RLS, storage bucket, RPCs
│   └── functions/
│       └── delete-account/
│           └── index.ts            # Deno Edge Function — secure account deletion
│
├── android/                        # Android host project
├── ios/                            # iOS host project
├── assets/
│   ├── icons/                      # App logo, social icons, nav icons
│   └── user_profile/               # Default profile image placeholders
│
├── .env.json.example               # Credential template — copy to .env.json
└── pubspec.yaml
```

**Key architectural decisions:**

- **Riverpod 2 for all state** — Providers are declared globally and consumed via `ref.watch` / `ref.read`. No `BuildContext` threading required in service classes.
- **Interface-based auth** — `AuthProvider` is an abstract interface; `SupabaseAuthProvider` is the concrete implementation. Swapping backends requires changing a single factory in `auth_service.dart`.
- **Credentials via `dart-define`** — Supabase URL and anon key are injected at compile time via `--dart-define-from-file`. `String.fromEnvironment()` reads them; they are never present in source.
- **RLS as the primary security layer** — All data access rules are enforced in Postgres Row Level Security, not in app code. Privileged operations (account deletion) run through Edge Functions called with the user's JWT.

---

## 🤝 Contributing

Contributions are welcome. To get started:

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Commit your changes: `git commit -m 'Add some feature'`
4. Push to the branch: `git push origin feature/your-feature`
5. Open a Pull Request

Please ensure `flutter analyze` returns no errors before submitting.

---

## 📄 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

<div align="center">
  Built with Flutter &amp; Supabase
</div>
