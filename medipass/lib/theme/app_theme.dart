// lib/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // --- Palette de Couleurs "Medipass Orange" ---
  static const Color primaryColor = Color(0xFFE57C1E);
  static const Color secondaryLight = Color(0xFFF57C00);
  static const Color secondaryDark = Color(0xFFFFAB40);

  // --- Thème Clair ---
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: const Color(0xFFF8F8F8),
    cardColor: Colors.white,
    hintColor: Colors.grey.shade600,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      onPrimary: Colors.white,
      secondary: secondaryLight,
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFFFFF3E0),
      onSecondaryContainer: const Color(0xFF5f3403),
      background: const Color(0xFFF8F8F8),
      onBackground: Colors.black87,
      surface: Colors.white,
      onSurface: Colors.black87,
      error: const Color(0xFFD32F2F),
      onError: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 2.0,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade100,
      hintStyle: TextStyle(color: Colors.grey.shade500),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
    ),
    dividerTheme: DividerThemeData(
      color: Colors.grey.shade300,
      thickness: 0.8,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    iconTheme: const IconThemeData(
      color: primaryColor,
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: Colors.grey.shade800, fontSize: 16),
      bodyMedium: TextStyle(color: Colors.grey.shade700, fontSize: 14),
      titleMedium: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
      labelLarge: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      bodySmall: TextStyle(color: Colors.grey.shade600, fontSize: 12),
    ),
  );

  // --- Thème Sombre ---
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: const Color(0xFF121212),
    cardColor: const Color(0xFF1E1E1E),
    hintColor: Colors.grey.shade500,
    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      onPrimary: Colors.black87,
      secondary: secondaryDark,
      onSecondary: Colors.black87,
      secondaryContainer: const Color(0xFF332312),
      onSecondaryContainer: Colors.orange.shade100,
      background: const Color(0xFF121212),
      onBackground: Colors.white70,
      surface: const Color(0xFF1E1E1E),
      onSurface: Colors.white70,
      error: const Color(0xFFCF6679),
      onError: Colors.black,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade800,
      hintStyle: TextStyle(color: Colors.grey.shade500),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: secondaryDark, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
    ),
    dividerTheme: DividerThemeData(
      color: Colors.grey.shade700,
      thickness: 0.8,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.black87,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: secondaryDark,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    iconTheme: const IconThemeData(
      color: secondaryDark,
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: Colors.grey.shade300, fontSize: 16),
      bodyMedium: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      titleMedium: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
      labelLarge: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
      bodySmall: TextStyle(color: Colors.grey.shade500, fontSize: 12),
    ),
  );
}

