import 'package:flutter/material.dart';

class AIAdminTheme {
  static ThemeData theme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0B0F14),
    primaryColor: const Color(0xFF19F6E8),

    cardColor: const Color(0xFF121A22),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0B0F14),
      elevation: 0,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),

    textTheme: const TextTheme(
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      bodyMedium: TextStyle(color: Colors.white70),
    ),

    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFF1C2A36),
      labelStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
  );
}
