// lib/utils/app_theme.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color primary = Color(0xFF00C896);
  static const Color primaryDark = Color(0xFF00A87E);
  static const Color secondary = Color(0xFF1A1D2E);
  static const Color accent = Color(0xFFFF6B6B);

  static const Color incomeColor = Color(0xFF00C896);
  static const Color expenseColor = Color(0xFFFF6B6B);

  static const Color bgLight = Color(0xFFF5F7FA);
  static const Color bgDark = Color(0xFF0F1120);

  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF1A1D2E);

  static const Color textLight = Color(0xFF1A1D2E);
  static const Color textDark = Color(0xFFF0F2FF);

  // LIGHT THEME
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: bgLight,
    primaryColor: primary,

    colorScheme: const ColorScheme.light(
      primary: primary,
      secondary: secondary,
      surface: cardLight,
      error: accent,
    ),

    textTheme: GoogleFonts.poppinsTextTheme().copyWith(
      displayLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: textLight,
      ),

      displayMedium: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textLight,
      ),

      bodyLarge: GoogleFonts.poppins(
        fontSize: 16,
        color: textLight,
      ),

      bodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        color: textLight,
      ),

      bodySmall: GoogleFonts.poppins(
        fontSize: 12,
        color: textLight.withOpacity(0.6),
      ),
    ),

    // FIXED
    cardTheme: CardThemeData(
      color: cardLight,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade100,

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Colors.grey.shade200,
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: primary,
          width: 2,
        ),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: accent,
        ),
      ),

      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),

        padding: const EdgeInsets.symmetric(vertical: 16),

        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: bgLight,
      elevation: 0,
      centerTitle: false,

      iconTheme: const IconThemeData(
        color: textLight,
      ),

      titleTextStyle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: textLight,
      ),
    ),
  );

  // DARK THEME
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bgDark,
    primaryColor: primary,

    colorScheme: const ColorScheme.dark(
      primary: primary,
      secondary: Color(0xFF2A2D3E),
      surface: cardDark,
      error: accent,
    ),

    textTheme:
    GoogleFonts.poppinsTextTheme(
      ThemeData.dark().textTheme,
    ).copyWith(
      displayLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: textDark,
      ),

      displayMedium: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textDark,
      ),

      bodyLarge: GoogleFonts.poppins(
        fontSize: 16,
        color: textDark,
      ),

      bodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        color: textDark,
      ),

      bodySmall: GoogleFonts.poppins(
        fontSize: 12,
        color: textDark.withOpacity(0.6),
      ),
    ),

    // FIXED
    cardTheme: CardThemeData(
      color: cardDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2A2D3E),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFF3A3D4E),
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: primary,
          width: 2,
        ),
      ),

      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),

        padding: const EdgeInsets.symmetric(vertical: 16),

        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: bgDark,
      elevation: 0,
      centerTitle: false,

      iconTheme: const IconThemeData(
        color: textDark,
      ),

      titleTextStyle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: textDark,
      ),
    ),
  );
}

class AppConstants {
  static const String appName = 'FinanceMe';

  static const List<String> currencies = [
    'MAD',
    'EUR',
    'USD',
    'GBP',
  ];
}