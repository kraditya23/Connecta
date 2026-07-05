import 'package:flutter/material.dart';

/// Account-level settings, stored at users/{uid}.settings (separate from the
/// public profile document so it's never exposed when someone views a card).
class AppSettings {
  final ThemeMode themeMode;
  final bool connectionAlertsEnabled;
  final bool productUpdatesEnabled;
  final List<String> messageSnippets;

  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.connectionAlertsEnabled = true,
    this.productUpdatesEnabled = true,
    this.messageSnippets = const [],
  });

  AppSettings copyWith({
    ThemeMode? themeMode,
    bool? connectionAlertsEnabled,
    bool? productUpdatesEnabled,
    List<String>? messageSnippets,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      connectionAlertsEnabled: connectionAlertsEnabled ?? this.connectionAlertsEnabled,
      productUpdatesEnabled: productUpdatesEnabled ?? this.productUpdatesEnabled,
      messageSnippets: messageSnippets ?? this.messageSnippets,
    );
  }

  factory AppSettings.fromMap(Map<String, dynamic>? data) {
    if (data == null) return const AppSettings();
    return AppSettings(
      themeMode: _themeModeFromString(data['themeMode'] as String?),
      connectionAlertsEnabled: data['connectionAlertsEnabled'] as bool? ?? true,
      productUpdatesEnabled: data['productUpdatesEnabled'] as bool? ?? true,
      messageSnippets: List<String>.from(data['messageSnippets'] as List? ?? const []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'themeMode': themeMode.name,
      'connectionAlertsEnabled': connectionAlertsEnabled,
      'productUpdatesEnabled': productUpdatesEnabled,
      'messageSnippets': messageSnippets,
    };
  }

  static ThemeMode _themeModeFromString(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}