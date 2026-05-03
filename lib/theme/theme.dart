import 'package:flutter/material.dart';
import 'tokens.dart';

class FlowCashTheme {
  static ThemeData darkTheme() {
    const primaryGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        FlowCashTokens.indigo,
        FlowCashTokens.teal,
      ],
    );

    final colorScheme = ColorScheme.dark(
      background: FlowCashTokens.bgDark,
      surface: FlowCashTokens.surface,
      primary: FlowCashTokens.indigo,
      secondary: FlowCashTokens.teal,
      tertiary: FlowCashTokens.amber,
      error: FlowCashTokens.coral,
      onBackground: FlowCashTokens.textDark,
      onSurface: FlowCashTokens.textDark,
      onPrimary: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: 'Inter',
      scaffoldBackgroundColor: FlowCashTokens.bgDark,
      appBarTheme: AppBarTheme(
        backgroundColor: FlowCashTokens.bgDark,
        foregroundColor: FlowCashTokens.textDark,
        elevation: 0,
        centerTitle: true,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1A1A2E),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: FlowCashTokens.borderDark,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: FlowCashTokens.borderDark,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: FlowCashTokens.teal,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: FlowCashTokens.coral,
          ),
        ),
        labelStyle: const TextStyle(
          color: FlowCashTokens.teal,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: TextStyle(
          color: FlowCashTokens.textDarkMuted.withOpacity(0.6),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: FlowCashTokens.indigo,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: FlowCashTokens.teal,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textTheme: const TextTheme(
        // Display/headline styles use Space Grotesk
        displayLarge: TextStyle(
          fontFamily: 'Space Grotesk',
          fontSize: 32,
          fontWeight: FontWeight.w700,
          letterSpacing: -1,
        ),
        displayMedium: TextStyle(
          fontFamily: 'Space Grotesk',
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.8,
        ),
        headlineLarge: TextStyle(
          fontFamily: 'Space Grotesk',
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.6,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'Space Grotesk',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
        ),
        // Body styles use Inter (inherited from fontFamily)
        bodyMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        labelSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static ThemeData lightTheme() {
    final colorScheme = ColorScheme.light(
      background: FlowCashTokens.bgLight,
      surface: FlowCashTokens.surfaceLight,
      primary: FlowCashTokens.indigo,
      secondary: FlowCashTokens.teal,
      tertiary: FlowCashTokens.amber,
      error: FlowCashTokens.coral,
      onBackground: FlowCashTokens.textLight,
      onSurface: FlowCashTokens.textLight,
      onPrimary: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: FlowCashTokens.bgLight,
      appBarTheme: AppBarTheme(
        backgroundColor: FlowCashTokens.bgLight,
        foregroundColor: FlowCashTokens.textLight,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}
