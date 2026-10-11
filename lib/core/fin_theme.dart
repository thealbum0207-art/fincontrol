import 'package:flutter/material.dart';

const finGreen = Color(0xFF23C59E);
const finInk = Color(0xFF12202A);

ThemeData finTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final scheme = ColorScheme.fromSeed(
    seedColor: finGreen,
    brightness: brightness,
    surface: dark ? const Color(0xFF111C22) : const Color(0xFFF7FAF9),
  );
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: dark ? const Color(0xFF1A292F) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: dark ? const Color(0xFF1B2A31) : Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: dark ? const Color(0xFF132329) : Colors.white,
      indicatorColor: finGreen.withValues(alpha: 0.20),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: finGreen,
      foregroundColor: finInk,
    ),
  );
}