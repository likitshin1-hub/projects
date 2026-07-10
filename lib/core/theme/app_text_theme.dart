import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';

class AppTextTheme {
  AppTextTheme._();

  static TextTheme get lightTextTheme {
    return TextTheme(
      // Display
      displayLarge: GoogleFonts.kanit(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),

      displayMedium: GoogleFonts.kanit(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),

      displaySmall: GoogleFonts.kanit(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),

      // Headline
      headlineLarge: GoogleFonts.kanit(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),

      headlineMedium: GoogleFonts.kanit(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),

      // Title
      titleLarge: GoogleFonts.kanit(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),

      titleMedium: GoogleFonts.kanit(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),

      titleSmall: GoogleFonts.kanit(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      ),

      // Body
      bodyLarge: GoogleFonts.kanit(fontSize: 16, color: AppColors.textPrimary),

      bodyMedium: GoogleFonts.kanit(fontSize: 14, color: AppColors.textPrimary),

      bodySmall: GoogleFonts.kanit(
        fontSize: 12,
        color: AppColors.textSecondary,
      ),

      // Label / Button
      labelLarge: GoogleFonts.kanit(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
      ),

      labelMedium: GoogleFonts.kanit(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      ),

      labelSmall: GoogleFonts.kanit(
        fontSize: 11,
        color: AppColors.textSecondary,
      ),
    );
  }
}
