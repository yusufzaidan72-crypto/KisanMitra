import 'package:flutter/material.dart';

class AppColors {
  // Primary - Deep Forest & Leaf Green (nature, growth, smart agriculture)
  static const Color primary = Color(0xFF1B6B3A);
  static const Color primaryDark = Color(0xFF0F4D27);
  static const Color primaryLight = Color(0xFF2E9D5E);
  static const Color primaryMint = Color(0xFF4CAF7D);
  static const Color primarySurface = Color(0xFFEBF7F0);
  static const Color primarySurfaceLight = Color(0xFFF4FAF6);

  // Secondary - Warm Harvest Gold & Amber (wheat, sunshine, prosperity)
  static const Color secondary = Color(0xFFD4820A);
  static const Color secondaryDark = Color(0xFF9A5F00);
  static const Color secondaryLight = Color(0xFFFFB74D);
  static const Color secondaryLight2 = Color(0xFFFFF3E0);
  static const Color secondarySurface = Color(0xFFFFF7EA);

  // Accent - Water Azure & Monsoon Blue (irrigation, rain, humidity)
  static const Color accent = Color(0xFF0277BD);
  static const Color accentDark = Color(0xFF01579B);
  static const Color accentLight = Color(0xFF4FC3F7);
  static const Color accentSurface = Color(0xFFE8F5FD);

  // Earthy Tones (soil, organic farming, land)
  static const Color soilBrown = Color(0xFF6D4C41);
  static const Color soilLight = Color(0xFF8D6E63);
  static const Color soilSurface = Color(0xFFF7F3F0);

  // Status Colors
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFE65100);
  static const Color error = Color(0xFFC62828);
  static const Color info = Color(0xFF0277BD);

  // Weather Colors
  static const Color sunny = Color(0xFFFFB300);
  static const Color rainy = Color(0xFF1565C0);
  static const Color cloudy = Color(0xFF546E7A);
  static const Color stormy = Color(0xFF37474F);

  // Crop Health Colors
  static const Color healthGood = Color(0xFF2E7D32);
  static const Color healthWarning = Color(0xFFE65100);
  static const Color healthCritical = Color(0xFFC62828);

  // Background & Surfaces (warm off-white/cream outdoor canvas)
  static const Color background = Color(0xFFF6FAF7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color cardBgTinted = Color(0xFFF2F9F5);

  // Text
  static const Color textPrimary = Color(0xFF142919);
  static const Color textSecondary = Color(0xFF435D4D);
  static const Color textHint = Color(0xFF82A38E);
  static const Color textOnDark = Color(0xFFFFFFFF);

  // Borders & Dividers
  static const Color border = Color(0xFFD4E7DC);
  static const Color borderLight = Color(0xFFEAF4EE);
  static const Color divider = Color(0xFFE5F0E9);

  // Premium Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1B6B3A), Color(0xFF2E9D5E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF0F4D27), Color(0xFF1B6B3A), Color(0xFF2E9D5E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient harvestGradient = LinearGradient(
    colors: [Color(0xFF1B6B3A), Color(0xFFD4820A)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient weatherGradient = LinearGradient(
    colors: [Color(0xFF0277BD), Color(0xFF2E9D5E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient earthGradient = LinearGradient(
    colors: [Color(0xFF5D4037), Color(0xFF8D6E63)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient emeraldGlass = LinearGradient(
    colors: [Color(0x301B6B3A), Color(0x102E9D5E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
