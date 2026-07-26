import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  AppTypography._();

  static TextStyle displayLarge(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: 32,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.5,
    );
  }

  static TextStyle headlineLarge(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: 26,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.3,
    );
  }

  static TextStyle headlineMedium(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.2,
    );
  }

  static TextStyle titleLarge(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: 18,
      fontWeight: FontWeight.w600,
    );
  }

  static TextStyle titleMedium(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    );
  }

  static TextStyle bodyLarge(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      height: 1.4,
    );
  }

  static TextStyle bodyMedium(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.4,
    );
  }

  static TextStyle bodySmall(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.3,
    );
  }

  static TextStyle labelLarge(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
    );
  }

  static TextStyle labelSmall(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
    );
  }
}
