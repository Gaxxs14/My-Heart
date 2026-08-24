import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemePalette {
  roseGold,
  wineVelvet,
  midnightLove,
  cherryBlossom,
  sunsetRomance,
}

class ThemeProvider extends ChangeNotifier {
  AppThemePalette _currentPalette = AppThemePalette.roseGold;

  AppThemePalette get currentPalette => _currentPalette;

  ThemeProvider() {
    _loadTheme();
  }

  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('theme_palette');
    if (saved != null) {
      _currentPalette = AppThemePalette.values.firstWhere(
        (e) => e.name == saved,
        orElse: () => AppThemePalette.roseGold,
      );
      notifyListeners();
    }
  }

  void setPalette(AppThemePalette palette) async {
    _currentPalette = palette;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_palette', palette.name);
  }

  // Get Colors based on palette
  Color get primaryColor {
    switch (_currentPalette) {
      case AppThemePalette.roseGold:
        return const Color(0xFFFF5E7E);
      case AppThemePalette.wineVelvet:
        return const Color(0xFF9C27B0);
      case AppThemePalette.midnightLove:
        return const Color(0xFF6C5CE7);
      case AppThemePalette.cherryBlossom:
        return const Color(0xFFF06292);
      case AppThemePalette.sunsetRomance:
        return const Color(0xFFFF7043);
    }
  }

  Color get secondaryColor {
    switch (_currentPalette) {
      case AppThemePalette.roseGold:
        return const Color(0xFF880E4F);
      case AppThemePalette.wineVelvet:
        return const Color(0xFF4A148C);
      case AppThemePalette.midnightLove:
        return const Color(0xFF2D3436);
      case AppThemePalette.cherryBlossom:
        return const Color(0xFFAD1457);
      case AppThemePalette.sunsetRomance:
        return const Color(0xFFD84315);
    }
  }

  Color get softBgColor {
    switch (_currentPalette) {
      case AppThemePalette.roseGold:
        return const Color(0xFFFFF9FA);
      case AppThemePalette.wineVelvet:
        return const Color(0xFFFAF5FB);
      case AppThemePalette.midnightLove:
        return const Color(0xFFF7F8FC);
      case AppThemePalette.cherryBlossom:
        return const Color(0xFFFFF5F8);
      case AppThemePalette.sunsetRomance:
        return const Color(0xFFFFF8F5);
    }
  }

  Color get softAccentColor {
    switch (_currentPalette) {
      case AppThemePalette.roseGold:
        return const Color(0xFFFFE3E8);
      case AppThemePalette.wineVelvet:
        return const Color(0xFFF3E5F5);
      case AppThemePalette.midnightLove:
        return const Color(0xFFE8E9FF);
      case AppThemePalette.cherryBlossom:
        return const Color(0xFFFCE4EC);
      case AppThemePalette.sunsetRomance:
        return const Color(0xFFFFEBE5);
    }
  }

  LinearGradient get mainGradient {
    switch (_currentPalette) {
      case AppThemePalette.roseGold:
        return const LinearGradient(
          colors: [Color(0xFFFF5E7E), Color(0xFFFF8E53)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case AppThemePalette.wineVelvet:
        return const LinearGradient(
          colors: [Color(0xFFBA68C8), Color(0xFF7B1FA2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case AppThemePalette.midnightLove:
        return const LinearGradient(
          colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case AppThemePalette.cherryBlossom:
        return const LinearGradient(
          colors: [Color(0xFFF48FB1), Color(0xFFFF4081)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case AppThemePalette.sunsetRomance:
        return const LinearGradient(
          colors: [Color(0xFFFF7043), Color(0xFFFFB74D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: softBgColor,
      ),
      scaffoldBackgroundColor: softBgColor,
      textTheme: GoogleFonts.outfitTextTheme().copyWith(
        displayLarge: GoogleFonts.playfairDisplay(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF2B2B2B),
        ),
        displayMedium: GoogleFonts.playfairDisplay(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF2B2B2B),
        ),
        titleLarge: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF2B2B2B),
        ),
        bodyLarge: GoogleFonts.outfit(
          fontSize: 16,
          color: const Color(0xFF2B2B2B),
        ),
        bodyMedium: GoogleFonts.outfit(
          fontSize: 14,
          color: const Color(0xFF757575),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: softAccentColor, width: 1.2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: softAccentColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: softAccentColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
      ),
    );
  }
}
