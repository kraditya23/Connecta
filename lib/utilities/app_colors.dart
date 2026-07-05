import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ---------------------------------------------------------------------------
/// DESIGN TOKENS
///
/// Connecta's visual identity: confident indigo, warm amber accent, calm
/// neutral surfaces. Headings use Space Grotesk (a bit technical / modern,
/// fitting a "digital card" product) and body text uses Inter for maximum
/// readability. Both are loaded via google_fonts and fail over to the
/// platform default automatically if offline.
/// ---------------------------------------------------------------------------

// Brand
const Color primaryColor = Color(0xFF6366F1); // Indigo - kept from original
const Color primaryColorDark = Color(0xFF4F46E5);
const Color primaryContainerLight = Color(0xFFEEF0FF);
const Color secondaryColor = Color(0xFFFFD166); // warm amber accent
const Color accentColor = Color(0xFF66D9EF); // cool cyan, used sparingly

// Semantic
const Color successColor = Color(0xFF22C55E);
const Color warningColor = Color(0xFFF59E0B);
const Color errorColor = Color(0xFFEF4444);

// Light surfaces
const Color backgroundColor = Color(0xFFFAFAFB);
const Color cardBackgroundColor = Color(0xFFFFFFFF);
const Color cardBorderColor = Color(0xFFE7E8EC);

// Dark surfaces
const Color backgroundColorDark = Color(0xFF0F1115);
const Color cardBackgroundColorDark = Color(0xFF181B22);
const Color cardBorderColorDark = Color(0xFF2A2D36);

// Text (light mode)
const Color textColor = Color(0xFF111827);
const Color textColorLight = Color(0xFF4B5563);
const Color textColorLighter = Color(0xFF9CA3AF);

// QR
const Color qrColor = Color(0xFF000000);
const Color qrBackgroundColor = Color(0xFFFFFFFF);

// Buttons
const Color buttonColor = primaryColor;
const Color buttonTextColor = Color(0xFFFFFFFF);

/// Centralised radii so the whole app feels consistent.
class AppRadius {
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 20;
  static const double xl = 28;
}

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

TextTheme _buildTextTheme(TextTheme base, Color displayColor, Color bodyColor) {
  final headingFont = GoogleFonts.spaceGroteskTextTheme(base);
  final bodyFont = GoogleFonts.interTextTheme(base);

  return bodyFont.copyWith(
    displayLarge: headingFont.displayLarge?.copyWith(color: displayColor, fontWeight: FontWeight.w700),
    displayMedium: headingFont.displayMedium?.copyWith(color: displayColor, fontWeight: FontWeight.w700),
    displaySmall: headingFont.displaySmall?.copyWith(color: displayColor, fontWeight: FontWeight.w600),
    headlineLarge: headingFont.headlineLarge?.copyWith(color: displayColor, fontWeight: FontWeight.w700),
    headlineMedium: headingFont.headlineMedium?.copyWith(color: displayColor, fontWeight: FontWeight.w700),
    headlineSmall: headingFont.headlineSmall?.copyWith(color: displayColor, fontWeight: FontWeight.w600),
    titleLarge: headingFont.titleLarge?.copyWith(color: displayColor, fontWeight: FontWeight.w600),
    titleMedium: bodyFont.titleMedium?.copyWith(color: displayColor, fontWeight: FontWeight.w600),
    titleSmall: bodyFont.titleSmall?.copyWith(color: displayColor, fontWeight: FontWeight.w600),
    bodyLarge: bodyFont.bodyLarge?.copyWith(color: bodyColor),
    bodyMedium: bodyFont.bodyMedium?.copyWith(color: bodyColor),
    bodySmall: bodyFont.bodySmall?.copyWith(color: bodyColor),
    labelLarge: bodyFont.labelLarge?.copyWith(color: bodyColor, fontWeight: FontWeight.w600),
    labelMedium: bodyFont.labelMedium?.copyWith(color: bodyColor, fontWeight: FontWeight.w600),
    labelSmall: bodyFont.labelSmall?.copyWith(color: bodyColor),
  );
}

final ColorScheme _lightScheme = ColorScheme.fromSeed(
  seedColor: primaryColor,
  brightness: Brightness.light,
).copyWith(
  primary: primaryColor,
  primaryContainer: primaryContainerLight,
  secondary: secondaryColor,
  surface: cardBackgroundColor,
  error: errorColor,
  outline: cardBorderColor,
);

final ColorScheme _darkScheme = ColorScheme.fromSeed(
  seedColor: primaryColor,
  brightness: Brightness.dark,
).copyWith(
  primary: const Color(0xFF818CF8),
  primaryContainer: const Color(0xFF312E81),
  secondary: secondaryColor,
  surface: cardBackgroundColorDark,
  error: const Color(0xFFF87171),
  outline: cardBorderColorDark,
);

ThemeData appThemeData = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: _lightScheme,
  scaffoldBackgroundColor: backgroundColor,
  cardColor: cardBackgroundColor,
  fontFamily: GoogleFonts.inter().fontFamily,
  textTheme: _buildTextTheme(ThemeData.light().textTheme, textColor, textColorLight),
  appBarTheme: AppBarTheme(
    backgroundColor: backgroundColor,
    foregroundColor: textColor,
    elevation: 0,
    surfaceTintColor: Colors.transparent,
    titleTextStyle: GoogleFonts.spaceGrotesk(
      color: textColor,
      fontSize: 19,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.2,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      minimumSize: const Size.fromHeight(52),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      elevation: 0,
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: primaryColor,
      minimumSize: const Size.fromHeight(52),
      side: const BorderSide(color: primaryColor, width: 1.4),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: primaryColor,
      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFFF3F4F6),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: const BorderSide(color: primaryColor, width: 1.6),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: const BorderSide(color: errorColor, width: 1.4),
    ),
    labelStyle: const TextStyle(color: textColorLight),
  ),
  cardTheme: CardThemeData(
    color: cardBackgroundColor,
    elevation: 0,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      side: const BorderSide(color: cardBorderColor),
    ),
  ),
  dividerTheme: const DividerThemeData(color: cardBorderColor, thickness: 1, space: 1),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected) ? primaryColor : null,
    ),
    trackColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected) ? primaryContainerLight : null,
    ),
  ),
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: cardBackgroundColor,
    indicatorColor: primaryContainerLight,
    elevation: 0,
    height: 64,
    labelTextStyle: WidgetStateProperty.resolveWith(
      (states) => TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.w600,
        color: states.contains(WidgetState.selected) ? primaryColor : textColorLighter,
      ),
    ),
    iconTheme: WidgetStateProperty.resolveWith(
      (states) => IconThemeData(
        color: states.contains(WidgetState.selected) ? primaryColor : textColorLighter,
      ),
    ),
  ),
  snackBarTheme: SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
  ),
);

ThemeData appDarkThemeData = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: _darkScheme,
  scaffoldBackgroundColor: backgroundColorDark,
  cardColor: cardBackgroundColorDark,
  fontFamily: GoogleFonts.inter().fontFamily,
  textTheme: _buildTextTheme(ThemeData.dark().textTheme, Colors.white, const Color(0xFFB6BAC6)),
  appBarTheme: AppBarTheme(
    backgroundColor: backgroundColorDark,
    foregroundColor: Colors.white,
    elevation: 0,
    surfaceTintColor: Colors.transparent,
    titleTextStyle: GoogleFonts.spaceGrotesk(
      color: Colors.white,
      fontSize: 19,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.2,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: _darkScheme.primary,
      foregroundColor: Colors.black,
      minimumSize: const Size.fromHeight(52),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      elevation: 0,
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: _darkScheme.primary,
      minimumSize: const Size.fromHeight(52),
      side: BorderSide(color: _darkScheme.primary, width: 1.4),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF20232C),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(color: _darkScheme.primary, width: 1.6),
    ),
  ),
  cardTheme: CardThemeData(
    color: cardBackgroundColorDark,
    elevation: 0,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      side: const BorderSide(color: cardBorderColorDark),
    ),
  ),
  dividerTheme: const DividerThemeData(color: cardBorderColorDark, thickness: 1, space: 1),
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: cardBackgroundColorDark,
    indicatorColor: const Color(0xFF312E81),
    elevation: 0,
    height: 64,
  ),
  snackBarTheme: SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
  ),
);