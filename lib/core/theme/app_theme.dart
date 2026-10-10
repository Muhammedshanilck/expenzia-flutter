import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      // The 2014 typography has no fixed line heights, so text uses the
      // font's natural line height like Figma ("line-height: normal").
      typography: Typography.material2014(),
      fontFamily: AppTextStyles.fontFamily,
      scaffoldBackgroundColor: AppColors.white,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: AppColors.white,
      ),
      datePickerTheme: const DatePickerThemeData(
        backgroundColor: AppColors.white,
        headerBackgroundColor: AppColors.primary,
        headerForegroundColor: AppColors.white,
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
