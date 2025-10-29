import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

final ColorScheme _lightScheme = ColorScheme(
  brightness: Brightness.light,
  primary: AppColors.primary,
  onPrimary: Colors.white,
  secondary: AppColors.secondary,
  onSecondary: Colors.black,
  error: AppColors.error,
  onError: Colors.white,
  surface: AppColors.background,
  onSurface: AppColors.textPrimary,
);

final ThemeData appThemeLight = ThemeData(
  useMaterial3: true,
  colorScheme: _lightScheme,
  scaffoldBackgroundColor: _lightScheme.surface,
  textTheme: AppTypography.textTheme,

  appBarTheme: AppBarTheme(
    backgroundColor: _lightScheme.surface,
    foregroundColor: _lightScheme.onSurface,
    elevation: 0,
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: _lightScheme.primary,
      foregroundColor: _lightScheme.onPrimary,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: _lightScheme.surface,
    hintStyle: const TextStyle(color: AppColors.textSecondary),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: _lightScheme.primary, width: 2),
    ),
  ),

  chipTheme: const ChipThemeData(
    side: BorderSide.none,
    labelStyle: TextStyle(color: AppColors.textPrimary),
  ),
);
