import 'package:flutter/material.dart';
import 'user_onboarding.dart';
import 'package:card_app/utilities/app_colors.dart';
import 'package:card_app/utilities/constants.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 88,
                height: 88,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, primaryColorDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  boxShadow: [
                    BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 24, offset: const Offset(0, 12)),
                  ],
                ),
                child: const Icon(Icons.badge_rounded, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 32),
              Text(
                'Welcome to $appName',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Text(
                'Your digital business card. Share it instantly, keep it always up to date, and never run out of paper cards again.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge,
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const UserInfoScreen()),
                  );
                },
                child: const Text('Get started'),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}