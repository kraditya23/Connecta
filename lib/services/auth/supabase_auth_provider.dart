import 'package:card_app/services/auth/auth_provider.dart';
import 'package:card_app/services/auth/auth_user.dart';
import 'package:card_app/services/auth/auth_exceptions.dart';
import 'package:card_app/utilities/supabase_config.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;

class SupabaseAuthProvider implements AuthProvider {
  SupabaseClient get _client => Supabase.instance.client;

  @override
  Future<void> initialize() async {}

  @override
  AuthUser? get currentUser {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return AuthUser(isEmailVerified: user.emailConfirmedAt != null);
  }

  @override
  Future<AuthUser> createUser({required String email, required String password}) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: supabaseRedirectUrl,
      );
      final user = response.user;
      if (user == null) throw UserNotFoundAuthException();
      return AuthUser(isEmailVerified: user.emailConfirmedAt != null);
    } on AuthException catch (e) {
      final msg = e.message.toLowerCase();
      if (msg.contains('already registered') || msg.contains('already been registered')) {
        throw EmailAlreadyInUseException();
      }
      if (msg.contains('password')) throw WeakPasswordAuthException();
      if (msg.contains('invalid') && msg.contains('email')) throw InvalidEmailAuthException();
      throw GenericAuthException();
    } catch (e) {
      if (e is UserNotFoundAuthException || e is WeakPasswordAuthException ||
          e is EmailAlreadyInUseException || e is InvalidEmailAuthException) rethrow;
      throw GenericAuthException();
    }
  }

  @override
  Future<AuthUser> logIn({required String email, required String password}) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user == null) throw UserNotFoundAuthException();

      // Sign out immediately and block access if email is not verified.
      if (user.emailConfirmedAt == null) {
        await _client.auth.signOut();
        throw EmailNotConfirmedException();
      }

      return AuthUser(isEmailVerified: true);
    } on EmailNotConfirmedException {
      rethrow;
    } on AuthException catch (e) {
      final msg = e.message.toLowerCase();
      if (msg.contains('invalid login') || msg.contains('invalid_credentials') ||
          msg.contains('wrong password') || msg.contains('incorrect')) {
        throw WrongPasswordAuthException();
      }
      if (msg.contains('user not found') || msg.contains('no user')) {
        throw UserNotFoundAuthException();
      }
      if (msg.contains('email not confirmed')) {
        throw EmailNotConfirmedException();
      }
      throw GenericAuthException();
    } catch (e) {
      if (e is EmailNotConfirmedException || e is UserNotFoundAuthException ||
          e is WrongPasswordAuthException) rethrow;
      throw GenericAuthException();
    }
  }

  @override
  Future<void> logOut() async {
    await _client.auth.signOut();
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = _client.auth.currentUser;
    if (user?.email == null) throw UserNotLoggedInAuthException();
    await _client.auth.resend(
      type: OtpType.signup,
      email: user!.email!,
      emailRedirectTo: supabaseRedirectUrl,
    );
  }

  @override
  Future<void> resendVerificationEmail(String email) async {
    await _client.auth.resend(
      type: OtpType.signup,
      email: email,
      emailRedirectTo: supabaseRedirectUrl,
    );
  }

  @override
  Future<AuthUser> signInWithGoogle() async {
    try {
      final googleSignIn = GoogleSignIn(
        serverClientId: const String.fromEnvironment('GOOGLE_WEB_CLIENT_ID'),
      );
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) throw UserNotFoundAuthException();

      final googleAuth = await googleUser.authentication;
      if (googleAuth.idToken == null) throw GenericAuthException();

      await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken,
      );

      final user = _client.auth.currentUser;
      if (user == null) throw UserNotFoundAuthException();
      return AuthUser(isEmailVerified: user.emailConfirmedAt != null);
    } on UserNotFoundAuthException {
      rethrow;
    } catch (e) {
      if (e is GenericAuthException) rethrow;
      throw GenericAuthException();
    }
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    await _client.auth.resetPasswordForEmail(email, redirectTo: supabaseRedirectUrl);
  }
}
