import 'package:flutter/material.dart';

/// Colors taken from the Expenzia Figma file.
class AppColors {
  AppColors._();

  // Brand
  // Headers, buttons and the balance card.
  static const Color primary = Color(0xFF2F7E79);
  static const Color green = Color(0xFF438883); // Figma style "GREEN"
  // rgba(27, 92, 88, 0.9)
  static const Color balanceCardShadow = Color(0xE61B5C58);

  // Splash gradient
  static const Color splashGradientStart = Color(0xFF63B5AF);
  static const Color splashGradientEnd = Color(0xFF438883);

  // Onboarding
  // Sampled from the Figma render of the "Get Started" button.
  static const Color getStartedGradientTop = Color(0xFF63A9A4);
  static const Color getStartedGradientBottom = Color(0xFF458D88);
  static const Color getStartedShadow = Color(0xFF3E7C78);

  // Amounts
  static const Color income = Color(0xFF25A969);
  static const Color expense = Color(0xFFF95B51); // Figma style "Red"
  static const Color overdue = Color(0xFFD22E2E);

  // Text
  static const Color textPrimary = Color(0xFF050505);
  static const Color textDark = Color(0xFF222222);
  static const Color textAmount = Color(0xFF272727);
  // Figma style "Secondary".
  static const Color textSecondary = Color(0xFF666666);
  static const Color textOnCardMuted = Color(0xFFD0E5E4);
  static const Color textHint = Color(0xFFAEAEAE);

  // Surfaces and borders
  static const Color white = Colors.white;
  static const Color border = Color(0xFFDDDDDD);
  static const Color pillBorder = Color(0xFFDEDEDE);
  static const Color divider = Color(0x1A000000); // black, 10% opacity
  static const Color frostedCircle = Color(0x26FFFFFF); // white, 15% opacity
  static const Color swipeEdit = Color(0xFFE8E8E8);
  static const Color swipeDelete = Color(0xFFFB3E3E);
  static const Color cardShadow = Color(0x14000000); // black, 8% opacity
}
