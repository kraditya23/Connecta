import 'package:card_app/screens/authenticate/Reset_Email_Page.dart';
import 'package:card_app/screens/authenticate/sign_up_page.dart';
import 'package:card_app/services/auth/auth_exceptions.dart';
import 'package:card_app/services/auth/auth_service.dart';
import 'package:card_app/utilities/app_colors.dart';
import 'package:card_app/utilities/constants.dart';
import 'package:card_app/widgets/snackbars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInWithEmail() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    try {
      await AuthService.supabase().logIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // No navigation needed — AuthGate rebuilds reactively once the session
      // is established.
    } on EmailNotConfirmedException {
      if (!mounted) return;
      final email = _emailController.text.trim();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Email not verified'),
          content: const Text('Please verify your email before logging in.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
            TextButton(
              onPressed: () async {
                try {
                  await AuthService.supabase().resendVerificationEmail(email);
                  if (context.mounted) {
                    Navigator.pop(context);
                    context.showSuccessSnackBar(message: 'Verification email sent!');
                  }
                } catch (_) {
                  if (context.mounted) {
                    context.showErrorSnackBar(message: 'Could not resend verification email.');
                  }
                }
              },
              child: const Text('Resend Email'),
            ),
          ],
        ),
      );
    } on UserNotFoundAuthException {
      if (mounted) context.showErrorSnackBar(message: 'No account found with that email.');
    } on WrongPasswordAuthException {
      if (mounted) context.showErrorSnackBar(message: 'Incorrect password.');
    } on InvalidEmailAuthException {
      if (mounted) context.showErrorSnackBar(message: 'That email address looks invalid.');
    } on GenericAuthException {
      if (mounted) context.showErrorSnackBar(message: 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    try {
      await AuthService.supabase().signInWithGoogle();
    } on UserNotFoundAuthException {
      // User closed the Google picker — not an error worth surfacing.
    } catch (e) {
      if (mounted) context.showErrorSnackBar(message: 'Google sign-in failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),
                Container(
                  width: 56,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Icon(Icons.badge_rounded, color: primaryColor, size: 28),
                ),
                const SizedBox(height: 24),
                Text('Welcome back', style: theme.textTheme.headlineMedium),
                const SizedBox(height: 6),
                Text('Sign in to your $appName account', style: theme.textTheme.bodyMedium),
                const SizedBox(height: 36),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.mail_outline)),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (value) =>
                      (value == null || value.trim().isEmpty) ? 'Please enter your email' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter your password';
                    if (value.length < 6) return 'Password must be at least 6 characters';
                    return null;
                  },
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
                    ),
                    child: const Text('Forgot password?'),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _isSubmitting
                      ? null
                      : () {
                          if (_formKey.currentState!.validate()) _signInWithEmail();
                        },
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.login_rounded, size: 20),
                  label: Text(_isSubmitting ? 'Signing in...' : 'Sign in'),
                ),
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  onPressed: _isSubmitting ? null : _signInWithGoogle,
                  icon: const Icon(Icons.g_mobiledata_rounded, size: 26),
                  label: const Text('Continue with Google'),
                ),
                const SizedBox(height: 24),
                Center(
                  child: TextButton(
                    onPressed: () =>
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpPage())),
                    child: const Text("Don't have an account? Sign up"),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
