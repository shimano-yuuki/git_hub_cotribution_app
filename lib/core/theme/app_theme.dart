import 'package:flutter/material.dart';

class AppTheme {
  // GitHub風のエンジニア向けカラーパレット
  static const Color _githubBlue = Color(0xFF0366D6);
  static const Color _githubDarkBg = Color(0xFF0D1117);
  static const Color _githubDarkSurface = Color(0xFF161B22);
  static const Color _githubDarkBorder = Color(0xFF30363D);
  static const Color _terminalGreen = Color(0xFF00FF88);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: false,
      colorScheme: ColorScheme.light(
        primary: _githubBlue,
        secondary: _githubBlue,
        surface: Colors.white,
        background: const Color(0xFFF6F8FA),
        error: const Color(0xFFD73A49),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: const Color(0xFF24292E),
        onBackground: const Color(0xFF24292E),
        onError: Colors.white,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFF6F8FA),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color(0xFF000000),
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedItemColor: _githubBlue,
        unselectedItemColor: Color(0xFF6A737D),
        backgroundColor: Colors.white,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Color(0xFFE1E4E8), width: 1),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: false,
      colorScheme: ColorScheme.dark(
        primary: _githubBlue,
        secondary: _terminalGreen,
        surface: _githubDarkSurface,
        background: _githubDarkBg,
        error: const Color(0xFFF85149),
        onPrimary: Colors.white,
        onSecondary: _githubDarkBg,
        onSurface: const Color(0xFFC9D1D9),
        onBackground: const Color(0xFFC9D1D9),
        onError: Colors.white,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: _githubDarkBg,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color(0xFF000000),
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedItemColor: _githubBlue,
        unselectedItemColor: const Color(0xFF8B949E),
        backgroundColor: _githubDarkSurface,
      ),
      cardTheme: CardThemeData(
        color: _githubDarkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: _githubDarkBorder, width: 1),
        ),
      ),
      dividerColor: _githubDarkBorder,
    );
  }
}
