import 'package:card_app/services/auth/auth_provider.dart';
import 'package:card_app/services/auth/auth_user.dart';
import 'package:card_app/services/auth/supabase_auth_provider.dart';

class AuthService implements AuthProvider {
  final AuthProvider provider;
  const AuthService(this.provider);
  factory AuthService.supabase() => AuthService(SupabaseAuthProvider());

  @override
  AuthUser? get currentUser => provider.currentUser;

  @override
  Future<AuthUser> createUser({required String email, required String password}) =>
      provider.createUser(email: email, password: password);

  @override
  Future<AuthUser> logIn({required String email, required String password}) =>
      provider.logIn(email: email, password: password);

  @override
  Future<void> logOut() => provider.logOut();

  @override
  Future<void> sendEmailVerification() => provider.sendEmailVerification();

  @override
  Future<void> resendVerificationEmail(String email) =>
      provider.resendVerificationEmail(email);

  @override
  Future<void> initialize() => provider.initialize();

  @override
  Future<AuthUser> signInWithGoogle() => provider.signInWithGoogle();

  @override
  Future<void> sendPasswordResetEmail({required String email}) =>
      provider.sendPasswordResetEmail(email: email);
}
