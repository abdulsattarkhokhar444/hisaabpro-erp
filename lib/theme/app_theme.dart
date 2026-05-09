import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // SDD 2.1 Color Palette
  static const Color mintTeal = Color(0xFFD1F2EB); // Background
  static const Color teal600 = Color(0xFF0D9488); // Primary
  static const Color teal900 = Color(0xFF134E4A); // Text
  static const Color teal300 = Color(0xFF5EEAD4); // Accent
  static const Color lightGrey = Color(0xFFE5E7EB); // Board

  static ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: mintTeal,
    primaryColor: teal600,
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: teal600),
    // SDD 2.2 Typography
    textTheme: GoogleFonts.poppinsTextTheme().copyWith(
      displayLarge: GoogleFonts.poppins(
        fontSize: 24, 
        fontWeight: FontWeight.bold, 
        color: teal900
      ), // H1
      titleLarge: GoogleFonts.poppins(
        fontSize: 18, 
        fontWeight: FontWeight.w600, 
        color: teal900
      ), // H2
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14, 
        fontWeight: FontWeight.normal, 
        color: teal900
      ), // Body
    ),
  );

  // SDD 2.3 Glassmorphism Card - 28px radius + blur 16px
  static BoxDecoration glassCard = BoxDecoration(
    color: Colors.white.withValues(alpha: 0.5),
    borderRadius: BorderRadius.circular(28),
    border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
    boxShadow: [
      BoxShadow(
        color: teal600.withValues(alpha: 0.15),
        blurRadius: 32,
        offset: const Offset(0, 8), // Ab ye error nahi
      ),
    ],
  );
}
