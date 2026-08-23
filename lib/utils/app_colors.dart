import 'package:flutter/material.dart';

/// Premium UI UX Pro Max Color System for KisanMitra
/// Style: Organic Biophilic + Glassmorphism Dark Mode
class AppColors {
  // Brand Dark Canvas
  static const Color background = Color(0xFF090D16);
  static const Color backgroundSecondary = Color(0xFF0F172A);
  static const Color canvasDark = Color(0xFF070A10);
  static const Color surface = Color(0xFF131C2E);

  // Glassmorphic Surface Colors
  static const Color glassSurface = Color(0x99131C2E);
  static const Color glassSurfaceHover = Color(0xB31E293B);
  static const Color glassBorder = Color(0x3338BDF8);
  static const Color glassBorderGreen = Color(0x4422C55E);
  static const Color cardBg = Color(0xFF131C2E);

  // Primary - Emerald Leaf & Bio Tech
  static const Color primary = Color(0xFF22C55E);
  static const Color primaryDark = Color(0xFF15803D);
  static const Color primaryLight = Color(0xFF4ADE80);
  static const Color primaryGlow = Color(0x6622C55E);
  static const Color primarySurface = Color(0x2022C55E);

  // Secondary - Water & Irrigation Cyan Tech
  static const Color secondary = Color(0xFF06B6D4);
  static const Color secondaryDark = Color(0xFF0891B2);
  static const Color secondaryLight = Color(0xFF38BDF8);
  static const Color secondaryGlow = Color(0x6606B6D4);
  static const Color secondarySurface = Color(0x2006B6D4);

  // Accent - Harvest Sunset Gold
  static const Color accent = Color(0xFFF59E0B);
  static const Color accentDark = Color(0xFFD97706);
  static const Color accentLight = Color(0xFFFBBF24);
  static const Color accentGlow = Color(0x66F59E0B);
  static const Color accentSurface = Color(0x20F59E0B);

  // Earth Tones
  static const Color soilDark = Color(0xFF2D1B18);
  static const Color soilLight = Color(0xFF8D6E63);

  // Status & Weather Indicators
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  static const Color rainy = Color(0xFF0284C7);

  // Text Hierarchy
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textHint = Color(0xFF475569);
  static const Color textOnPrimary = Color(0xFF052E16);

  // Border & Divider
  static const Color border = Color(0xFF1E293B);
  static const Color borderLight = Color(0xFF334155);
  static const Color divider = Color(0x1F1E293B);

  // Premium Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF16A34A), Color(0xFF22C55E), Color(0xFF06B6D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF0F291E), Color(0xFF090D16), Color(0xFF0B1726)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [Color(0x3322C55E), Color(0x1A06B6D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient harvestGradient = LinearGradient(
    colors: [Color(0xFF22C55E), Color(0xFFF59E0B)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient weatherGradient = LinearGradient(
    colors: [Color(0xFF0F172A), Color(0xFF0369A1), Color(0xFF15803D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glowCardBorder = LinearGradient(
    colors: [Color(0xAA22C55E), Color(0x3306B6D4), Color(0xAAF59E0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
