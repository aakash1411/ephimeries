import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Phase 5 design system. Dark is the primary experience; light is a
/// "parchment" alternate for daylight readability.
class AppTheme {
  AppTheme._();

  // ---------------------------------------------------------------------------
  // Colour tokens — exact values from the Phase 5 spec.
  // ---------------------------------------------------------------------------

  // Dark (default)
  static const Color _darkBackground = Color(0xFF0D0F1A);
  static const Color _darkSurface = Color(0xFF161925);
  static const Color _darkPrimary = Color(0xFFC8A96E); // antique gold
  static const Color _darkSecondary = Color(0xFF6E8EC8); // sky blue
  static const Color _darkError = Color(0xFFE05C5C);

  // Light (alternate)
  static const Color _lightBackground = Color(0xFFF5F3EE);
  static const Color _lightSurface = Color(0xFFFFFFFF);
  static const Color _lightPrimary = Color(0xFF7B5E2A); // earthy gold
  static const Color _lightSecondary = Color(0xFF3A5F8A); // deep blue
  static const Color _lightError = Color(0xFFB4332B);

  // ---------------------------------------------------------------------------
  // Factories
  // ---------------------------------------------------------------------------

  static ThemeData dark() => _build(
        Brightness.dark,
        ColorScheme.fromSeed(
          seedColor: _darkPrimary,
          brightness: Brightness.dark,
          primary: _darkPrimary,
          secondary: _darkSecondary,
          surface: _darkSurface,
          error: _darkError,
        ),
        scaffoldBackground: _darkBackground,
      );

  static ThemeData light() => _build(
        Brightness.light,
        ColorScheme.fromSeed(
          seedColor: _lightPrimary,
          brightness: Brightness.light,
          primary: _lightPrimary,
          secondary: _lightSecondary,
          surface: _lightSurface,
          error: _lightError,
        ),
        scaffoldBackground: _lightBackground,
      );

  static ThemeData _build(
    Brightness brightness,
    ColorScheme scheme, {
    required Color scaffoldBackground,
  }) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffoldBackground,
    );

    // Inter for body, Cinzel for display/headline, Roboto Mono for numbers.
    final inter = GoogleFonts.interTextTheme(base.textTheme);
    final cinzel = GoogleFonts.cinzelTextTheme(base.textTheme);

    final textTheme = inter.copyWith(
      displayLarge: cinzel.displayLarge?.copyWith(
        color: scheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
      displayMedium: cinzel.displayMedium?.copyWith(
        color: scheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
      displaySmall: cinzel.displaySmall?.copyWith(
        color: scheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
      headlineLarge: cinzel.headlineLarge?.copyWith(
        color: scheme.onSurface,
        letterSpacing: 0.5,
      ),
      headlineMedium: cinzel.headlineMedium?.copyWith(
        color: scheme.onSurface,
        letterSpacing: 0.5,
      ),
      headlineSmall: cinzel.headlineSmall?.copyWith(
        color: scheme.onSurface,
        letterSpacing: 0.4,
      ),
      titleLarge: cinzel.titleLarge?.copyWith(
        color: scheme.onSurface,
        fontWeight: FontWeight.w500,
      ),
    );

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBackground,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: cinzel.titleLarge?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w500,
          fontSize: 20,
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: scheme.onSurface.withValues(alpha: 0.08),
            width: 0.5,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          textStyle: inter.labelLarge?.copyWith(fontWeight: FontWeight.w600),
          padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: scheme.onSurface.withValues(alpha: 0.15),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.onSurface.withValues(alpha: 0.08),
        space: 1,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
    );
  }

  /// Monospaced style for degree / numeric cells.
  static TextStyle monoText(BuildContext context, {double? fontSize}) {
    return GoogleFonts.robotoMono(
      fontSize:
          fontSize ?? Theme.of(context).textTheme.bodyMedium?.fontSize,
      color: Theme.of(context).colorScheme.onSurface,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }
}
