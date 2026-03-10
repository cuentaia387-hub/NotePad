import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color pureBlack = Color(0xFF000000);
  static const Color neonAccent = Color(0xFF00FFCC); // Cyan/Neon glow
  static const Color glassWhite = Color(0x1AFFFFFF); // Very transparent white
  static const Color glassBorder = Color(0x33FFFFFF);
  
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: pureBlack,
      primaryColor: neonAccent,
      colorScheme: const ColorScheme.dark(
        primary: neonAccent,
        background: pureBlack,
        surface: pureBlack,
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      iconTheme: const IconThemeData(color: Colors.white70),
    );
  }

  // A carefully selected palette for the notes
  static const List<Color> noteColors = [
    Color(0xFF2C2C2C), // Dark Gray
    Color(0xFF8B0000), // Dark Red
    Color(0xFF4B0082), // Indigo
    Color(0xFF004d40), // Dark Teal
    Color(0xFF3e2723), // Dark Brown
    Color(0xFF01579b), // Dark Blue
    Color(0xFF1a237e), // Deep Purple
    Color(0xFFb71c1c), // Crimson
  ];
}
