// ============================================================
//  core/theme.dart — Global dark theme
// ============================================================
import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary   = Color(0xFFFF6B6B);
  static const Color secondary = Color(0xFF4ECDC4);
  static const Color darkBg    = Color(0xFF0A0A0A);
  static const Color surface   = Color(0xFF16213E);

  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBg,
    colorScheme: const ColorScheme.dark(
      primary: primary,
      secondary: secondary,
      surface: surface,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
    ),
    textTheme: const TextTheme(
      bodyLarge:  TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
      labelSmall: TextStyle(color: Colors.white60, fontSize: 10),
    ),
  );

  static const LinearGradient brandGradient = LinearGradient(
    colors: [primary, Color(0xFFFF8E53)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
