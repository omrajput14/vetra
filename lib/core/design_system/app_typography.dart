import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  static TextStyle screenTitle = GoogleFonts.lexend(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 32 / 24,
    color: AppColors.textPrimary,
  );

  static TextStyle sectionHeading = GoogleFonts.lexend(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 28 / 20,
    color: AppColors.textPrimary,
  );

  static TextStyle cardTitle = GoogleFonts.lexend(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 24 / 18,
    color: AppColors.textPrimary,
  );

  static TextStyle bodyDefault = GoogleFonts.lexend(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 24 / 16,
    color: AppColors.textPrimary,
  );

  static TextStyle buttonLabel = GoogleFonts.lexend(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 20 / 16,
    color: AppColors.textPrimary,
  );

  static TextStyle alertText = GoogleFonts.lexend(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 20 / 16,
    color: AppColors.alertCritical,
  );

  static TextStyle captionMetadata = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 16 / 13,
    color: AppColors.textMetadata,
  );

  static TextStyle vetDataRow = GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 20 / 15,
    color: AppColors.textPrimary,
  );
}
