import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  // Brand Colors
  // static const Color primaryColor = Color(0xFF34C3EB);
  static const Color primaryColor = Color(0xFF2Ac0EE);
  static const Color secondaryColor = Color(0xFF30d15b);
  static const Color backgroundColor = Color(0xFF1A1A1A);
  static const Color surfaceColor = Color(0xFF2A2A2A);
  static const Color errorColor = Color(0xFFE53935);
  static const Color successColor = Color(0xFF43A047);
  static const Color warningColor = Color(0xFFFFA000);

  // Text Colors
  static const Color primaryTextColor = Color(0xFFFFFFFF);
  static const Color secondaryTextColor = Color(0xFFB3B3B3);
  static const Color disabledTextColor = Color(0xFF757575);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, Color(0xFF2196F3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Typography
  static final TextTheme textTheme = TextTheme(
    displayLarge: GoogleFonts.montserrat(
      fontSize: 96,
      fontWeight: FontWeight.w700,
      letterSpacing: -1.5,
    ),
    displayMedium: GoogleFonts.montserrat(
      fontSize: 60,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.5,
    ),
    displaySmall: GoogleFonts.montserrat(
      fontSize: 48,
      fontWeight: FontWeight.w600,
    ),
    headlineMedium: GoogleFonts.montserrat(
      fontSize: 34,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.25,
    ),
    headlineSmall: GoogleFonts.montserrat(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      fontStyle: FontStyle.italic,
    ),
    titleLarge: GoogleFonts.poppins(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.15,
    ),
    titleMedium: GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
    ),
    titleSmall: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
    ),
    bodyLarge: GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
    ),
    bodyMedium: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
    ),
    labelLarge: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.25,
    ),
    bodySmall: GoogleFonts.poppins(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
      fontStyle: FontStyle.italic,
    ),
    labelSmall: GoogleFonts.poppins(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      letterSpacing: 1.5,
    ),
  );

  // Dark Theme
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: surfaceColor,
      background: backgroundColor,
      error: errorColor,
    ),
    scaffoldBackgroundColor: backgroundColor,
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: backgroundColor,
      elevation: 0,
      titleTextStyle: textTheme.titleLarge?.copyWith(color: primaryTextColor),
      iconTheme: const IconThemeData(color: primaryTextColor),
    ),
    cardTheme: CardTheme(
      color: surfaceColor,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: textTheme.labelLarge,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 17),
        textStyle: textTheme.labelLarge,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: textTheme.labelLarge,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: primaryColor.withOpacity(0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: errorColor),
      ),
      labelStyle: textTheme.bodyMedium?.copyWith(color: secondaryTextColor),
      hintStyle: textTheme.bodyMedium?.copyWith(color: disabledTextColor),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: primaryTextColor,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: surfaceColor,
      selectedItemColor: primaryColor,
      unselectedItemColor: secondaryTextColor,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    dividerTheme: const DividerThemeData(
      color: surfaceColor,
      thickness: 1,
      space: 1,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: surfaceColor,
      contentTextStyle: textTheme.bodyMedium?.copyWith(color: primaryTextColor),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primaryColor,
      linearTrackColor: surfaceColor,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: surfaceColor,
      labelStyle: textTheme.bodyMedium?.copyWith(color: primaryTextColor),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );

  // Light Theme (with similar structure but different colors)
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryColor,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: Colors.white,
      background: Color(0xFFF5F5F5),
      error: errorColor,
    ),
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: textTheme.titleLarge?.copyWith(color: Colors.black87),
      iconTheme: const IconThemeData(color: Colors.black87),
    ),
    // Add similar component themes as in dark theme but with light mode colors
    // ...
  );

  // Helper method to get color based on theme mode
  static Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? backgroundColor
        : const Color(0xFFF5F5F5);
  }
} 