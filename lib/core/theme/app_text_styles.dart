import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Text styles from the Figma file. Figma letter spacing is given in px,
/// so the values below are copied directly.
class AppTextStyles {
  AppTextStyles._();

  static const String fontFamily = 'Inter';

  static const TextStyle splashTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 50,
    fontWeight: FontWeight.w700,
    letterSpacing: -2,
    color: AppColors.white,
  );

  static const TextStyle onboardingTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 38 / 36,
    // Figma (like CSS) splits the extra line height evenly above and below.
    leadingDistribution: TextLeadingDistribution.even,
    letterSpacing: -0.72,
    color: AppColors.green,
  );

  static const TextStyle headerTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );

  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.36,
    color: AppColors.white,
  );

  // Home
  static const TextStyle greeting = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const TextStyle userName = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle cardLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.32,
    color: AppColors.white,
  );

  static const TextStyle totalBalance = TextStyle(
    fontFamily: fontFamily,
    fontSize: 30,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.5,
    color: AppColors.white,
  );

  static const TextStyle incomeLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.8,
    color: AppColors.textOnCardMuted,
  );

  static const TextStyle expensesLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.9,
    color: AppColors.textOnCardMuted,
  );

  static const TextStyle cardAmount = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -1,
    color: AppColors.white,
  );

  static const TextStyle statValue = TextStyle(
    fontFamily: fontFamily,
    fontSize: 25.306,
    fontWeight: FontWeight.w600,
    letterSpacing: -1.2653,
    color: AppColors.textPrimary,
  );

  /// Upper-case field and section labels ("DAILY AVERAGE", "NAME", ...).
  static const TextStyle label = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.72,
    color: AppColors.textSecondary,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.36,
    color: AppColors.textDark,
  );

  static const TextStyle seeAll = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.28,
    color: AppColors.textSecondary,
  );

  // Transaction rows
  static const TextStyle rowTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.32,
    color: Colors.black,
  );

  static const TextStyle rowSubtitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.26,
    color: AppColors.textSecondary,
  );

  static const TextStyle rowAmount = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.72,
  );

  // Form fields
  static const TextStyle fieldValue = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.14,
    color: AppColors.textSecondary,
  );

  static const TextStyle amountValue = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.14,
    color: AppColors.green,
  );

  static const TextStyle clearAction = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.green,
  );

  static const TextStyle error = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.overdue,
  );

  // Credit
  static const TextStyle savedListTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.32,
    color: AppColors.textDark,
  );

  // Profile
  static const TextStyle profileName = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );

  static const TextStyle clearStorage = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textHint,
  );
}
