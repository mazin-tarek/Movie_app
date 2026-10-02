import 'package:flutter/material.dart';
import 'package:movieapp/core/theme/app_colors.dart';

class AppTheme {
    AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryButton,
        surface: AppColors.lightSurface,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.lightPrimaryText),
      ),
      useMaterial3: true,
    );
  }


   static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryButton,
        surface: AppColors.darkSurface,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.darkPrimaryText),
      ),
      useMaterial3: true,
    );
  }
  


}