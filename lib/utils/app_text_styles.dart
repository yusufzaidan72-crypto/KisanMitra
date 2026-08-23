import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Premium Typography System (Space Grotesk + DM Sans pairing)
class AppTextStyles {
  // Display & Hero Headings (Space Grotesk)
  static TextStyle displayLarge = GoogleFonts.spaceGrotesk(
    fontSize: 42,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.15,
    letterSpacing: -0.5,
  );

  static TextStyle displayMedium = GoogleFonts.spaceGrotesk(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.2,
    letterSpacing: -0.3,
  );

  static TextStyle displaySmall = GoogleFonts.spaceGrotesk(
    fontSize: 26,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.25,
  );

  static TextStyle headlineLarge = GoogleFonts.spaceGrotesk(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static TextStyle headlineMedium = GoogleFonts.spaceGrotesk(
    fontSize: 19,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static TextStyle headlineSmall = GoogleFonts.spaceGrotesk(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  // Titles & Body (DM Sans)
  static TextStyle titleLarge = GoogleFonts.dmSans(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static TextStyle titleMedium = GoogleFonts.dmSans(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static TextStyle titleSmall = GoogleFonts.dmSans(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static TextStyle bodyLarge = GoogleFonts.dmSans(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.6,
  );

  static TextStyle bodyMedium = GoogleFonts.dmSans(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static TextStyle bodySmall = GoogleFonts.dmSans(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
    height: 1.5,
  );

  static TextStyle labelLarge = GoogleFonts.dmSans(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0.2,
  );

  static TextStyle button = GoogleFonts.spaceGrotesk(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
  );

  static TextStyle appBarTitle = GoogleFonts.spaceGrotesk(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: 0.3,
  );

  static TextStyle navLabel = GoogleFonts.dmSans(
    fontSize: 11,
    fontWeight: FontWeight.w500,
  );

  static TextStyle chip = GoogleFonts.dmSans(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );

  static TextStyle caption = GoogleFonts.dmSans(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );

  static TextStyle demoBadge = GoogleFonts.spaceGrotesk(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    letterSpacing: 0.5,
  );
}
