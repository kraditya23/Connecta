import 'package:flutter/material.dart';
import 'package:card_app/utilities/app_colors.dart';

extension CustomSnackBarExtension on BuildContext {
  void showErrorSnackBar({
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(message: message, icon: Icons.error_rounded, color: errorColor, duration: duration);
  }

  void showSuccessSnackBar({
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(message: message, icon: Icons.check_circle_rounded, color: successColor, duration: duration);
  }

  void showNeutralSnackBar({
    required String message,
    required IconData icon,
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(message: message, icon: icon, color: primaryColor, duration: duration);
  }

  void _show({
    required String message,
    required IconData icon,
    required Color color,
    required Duration duration,
  }) {
    if (!mounted) return;
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(message, style: const TextStyle(color: Colors.white))),
        ],
      ),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      margin: const EdgeInsets.all(16),
      duration: duration,
    );

    ScaffoldMessenger.of(this).hideCurrentSnackBar();
    ScaffoldMessenger.of(this).showSnackBar(snackBar);
  }
}