import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Vibrant Neon Palette
  static const Color background = Color(0xFF0F172A); // Deep Navy/Black
  static const Color surface = Color(0xFF1E293B);    // Lighter Navy
  static const Color accentGreen = Color(0xFF10B981); // Neon Green (Profit)
  static const Color accentRed = Color(0xFFEF4444);   // Neon Red (Loss)
  static const Color primary = Color(0xFF6366F1);     // Indigo/Purple
  static const Color textWhite = Colors.white;
  static const Color textGrey = Colors.white54;

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme), // Modern Font
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: accentGreen,
        surface: surface,
        background: background,
      ),
    );
  }
}