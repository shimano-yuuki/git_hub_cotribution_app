import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: false,
      colorScheme: ColorScheme.light(
        primary: AppColors.grey(700),
        secondary: AppColors.githubGreen,
        surface: AppColors.githubLightBg,
        error: AppColors.githubErrorLight,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.githubDarkText,
        onError: AppColors.white,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.githubLightBg,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.darkGrey,
        foregroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedItemColor: AppColors.githubGreen,
        unselectedItemColor: AppColors.githubUnselectedLight,
        backgroundColor: AppColors.white,
      ),
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.githubLightBorder, width: 1),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: false,
      colorScheme: ColorScheme.dark(
        primary: AppColors.grey(600),
        secondary: AppColors.terminalGreen,
        surface: AppColors.githubDarkBg,
        error: AppColors.githubErrorDark,
        onPrimary: AppColors.white,
        onSecondary: AppColors.githubDarkBg,
        onSurface: AppColors.githubLightText,
        onError: AppColors.white,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: AppColors.githubDarkBg,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.darkGrey,
        foregroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedItemColor: AppColors.terminalGreen,
        unselectedItemColor: AppColors.githubUnselectedDark,
        backgroundColor: AppColors.githubDarkSurface,
      ),
      cardTheme: CardThemeData(
        color: AppColors.githubDarkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.githubDarkBorder, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.githubDarkBorder),
    );
  }
}
