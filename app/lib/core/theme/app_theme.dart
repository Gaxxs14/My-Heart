import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ─── Core Romantic Palette ────────────────────────────────────────────────
  static const Color primaryRose   = Color(0xFFFF4D79);
  static const Color deepWine      = Color(0xFF7B1041);
  static const Color softPink      = Color(0xFFFFEDF1);
  static const Color blushPink     = Color(0xFFFFD6E0);
  static const Color romanticGold  = Color(0xFFFFBF47);
  static const Color darkCharcoal  = Color(0xFF1A1A2E);
  static const Color softBackground= Color(0xFFFFF8FA);
  static const Color cardBg        = Color(0xFFFFFFFF);
  static const Color textDark      = Color(0xFF1E1E2E);
  static const Color textMuted     = Color(0xFF8E8E9A);
  static const Color textLight     = Color(0xFFBEBEC8);

  // ─── Accent & Utility Colors ─────────────────────────────────────────────
  static const Color mintGreen     = Color(0xFF00C9A7);
  static const Color lavender      = Color(0xFFB5A8FF);
  static const Color peach         = Color(0xFFFF9A7B);
  static const Color skyBlue       = Color(0xFF7BC8F6);

  // ─── Gradients ────────────────────────────────────────────────────────────
  static const LinearGradient loveGradient = LinearGradient(
    colors: [Color(0xFFFF4D79), Color(0xFFFF8A5B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient deepLoveGradient = LinearGradient(
    colors: [Color(0xFFFF2D5B), Color(0xFFFF6B35)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient softHeartGradient = LinearGradient(
    colors: [Color(0xFFFFF0F5), Color(0xFFFFE3ED)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFFFFF8FA), Color(0xFFFFF0F5), Color(0xFFFFF8FA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient navGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFFFF5F8)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ─── Shadow System (color-matched) ───────────────────────────────────────
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: primaryRose.withOpacity(0.08),
      blurRadius: 20,
      spreadRadius: 0,
      offset: const Offset(0, 6),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get heroShadow => [
    BoxShadow(
      color: primaryRose.withOpacity(0.30),
      blurRadius: 32,
      spreadRadius: -4,
      offset: const Offset(0, 12),
    ),
    BoxShadow(
      color: primaryRose.withOpacity(0.12),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get navShadow => [
    BoxShadow(
      color: primaryRose.withOpacity(0.12),
      blurRadius: 24,
      spreadRadius: 0,
      offset: const Offset(0, -6),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 12,
      offset: const Offset(0, -2),
    ),
  ];

  // ─── Border Radius ────────────────────────────────────────────────────────
  static const double radiusSm   = 12.0;
  static const double radiusMd   = 20.0;
  static const double radiusLg   = 28.0;
  static const double radiusXl   = 36.0;
  static const double radiusFull = 100.0;

  // ─── Spacing ──────────────────────────────────────────────────────────────
  static const double spacingXs  =  4.0;
  static const double spacingSm  =  8.0;
  static const double spacingMd  = 16.0;
  static const double spacingLg  = 24.0;
  static const double spacingXl  = 32.0;

  // ─── Glassmorphism Helper ─────────────────────────────────────────────────
  static BoxDecoration glassCard({
    Color? tintColor,
    double opacity = 0.85,
    double borderOpacity = 0.3,
    double radius = 24,
  }) {
    final tint = tintColor ?? Colors.white;
    return BoxDecoration(
      color: tint.withOpacity(opacity),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: tint.withOpacity(borderOpacity),
        width: 1.2,
      ),
      boxShadow: cardShadow,
    );
  }

  // ─── Flutter ThemeData ────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryRose,
        primary: primaryRose,
        secondary: deepWine,
        surface: softBackground,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: softBackground,
      splashFactory: InkSparkle.splashFactory,

      // Typography
      textTheme: GoogleFonts.outfitTextTheme().copyWith(
        displayLarge: GoogleFonts.playfairDisplay(
          fontSize: 34,
          fontWeight: FontWeight.w700,
          color: textDark,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.playfairDisplay(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: textDark,
          letterSpacing: -0.3,
        ),
        titleLarge: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textDark,
          letterSpacing: -0.2,
        ),
        titleMedium: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        bodyLarge: GoogleFonts.outfit(
          fontSize: 16,
          color: textDark,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.outfit(
          fontSize: 14,
          color: textMuted,
          height: 1.4,
        ),
        labelSmall: GoogleFonts.outfit(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
          color: textMuted,
        ),
      ),

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: deepWine,
        ),
        iconTheme: const IconThemeData(color: deepWine),
      ),

      // Card
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: const BorderSide(color: Color(0xFFFFE3ED), width: 1),
        ),
        shadowColor: primaryRose.withOpacity(0.08),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryRose,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusFull),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),

      // OutlinedButton
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryRose,
          side: const BorderSide(color: primaryRose, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusFull),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // TextButton
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryRose,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusFull),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input Fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 17),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: Color(0xFFFFD6E0), width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: Color(0xFFFFD6E0), width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: primaryRose, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
        labelStyle: GoogleFonts.outfit(
          color: textMuted,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelStyle: GoogleFonts.outfit(
          color: primaryRose,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: GoogleFonts.outfit(
          color: textLight,
          fontSize: 14,
        ),
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: softPink,
        selectedColor: primaryRose,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusFull),
          side: BorderSide(color: primaryRose.withOpacity(0.2)),
        ),
        labelStyle: GoogleFonts.outfit(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: darkCharcoal,
        contentTextStyle: GoogleFonts.outfit(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        elevation: 8,
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: cardBg,
        elevation: 24,
        shadowColor: primaryRose.withOpacity(0.15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXl),
        ),
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textDark,
        ),
        contentTextStyle: GoogleFonts.outfit(
          fontSize: 14,
          color: textMuted,
          height: 1.5,
        ),
      ),

      // Bottom Sheet
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        elevation: 16,
      ),

      // Progress Indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryRose,
        linearTrackColor: blushPink,
      ),
    );
  }
}
