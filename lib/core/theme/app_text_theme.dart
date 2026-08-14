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

  static TextTheme get darkTextTheme {
    return TextTheme(
      // Display
      displayLarge: GoogleFonts.kanit(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),

      displayMedium: GoogleFonts.kanit(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),

      displaySmall: GoogleFonts.kanit(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),

      // Headline
      headlineLarge: GoogleFonts.kanit(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),

      headlineMedium: GoogleFonts.kanit(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),

      // Title
      titleLarge: GoogleFonts.kanit(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),

      titleMedium: GoogleFonts.kanit(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),

      titleSmall: GoogleFonts.kanit(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF94A3B8),
      ),

      // Body
      bodyLarge: GoogleFonts.kanit(fontSize: 16, color: Colors.white),

      bodyMedium: GoogleFonts.kanit(fontSize: 14, color: Colors.white),

      bodySmall: GoogleFonts.kanit(
        fontSize: 12,
        color: const Color(0xFF94A3B8),
      ),

      // Label / Button
      labelLarge: GoogleFonts.kanit(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),

      labelMedium: GoogleFonts.kanit(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF94A3B8),
      ),

      labelSmall: GoogleFonts.kanit(
        fontSize: 11,
        color: const Color(0xFF94A3B8),
      ),
    );
  }
}
