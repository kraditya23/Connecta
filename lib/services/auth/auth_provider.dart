import 'package:card_app/services/auth/auth_user.dart';

abstract class AuthProvider {
  Future<void> initialize();
  AuthUser? get currentUser;
  Future<AuthUser> logIn({required String email, required String password});
  Future<AuthUser> createUser({required String email, required String password});
  Future<void> logOut();
  Future<void> sendEmailVerification();
  Future<void> resendVerificationEmail(String email);
  Future<AuthUser> signInWithGoogle();
  Future<void> sendPasswordResetEmail({required String email});
}
