import 'package:flutter/material.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// Eco-Premium Light Theme Design Tokens
/// Source: Lovable project d4756565 styles.css
/// ─────────────────────────────────────────────────────────────────────────────
class LovableColors {
  // ── Brand Semantic ──────────────────────────────────────────────────────────
  /// --forest: oklch(0.35 0.079 164.5) → #064E3B — dark forest green
  static const Color forest = Color(0xFF064E3B);

  /// --slate-green: oklch(0.47 0.05 168) → medium sage-green for body text
  static const Color slateGreen = Color(0xFF2D6A50);

  /// --emerald-accent: oklch(0.68 0.16 158) → vibrant emerald for icons & CTAs
  static const Color emeraldAccent = Color(0xFF10B981);

  /// --cyan-accent: oklch(0.76 0.13 195) → cyan teal for gradient blend
  static const Color cyanAccent = Color(0xFF06B6D4);

  // ── Glass Surface ────────────────────────────────────────────────────────────
  /// --glass: oklch(1 0 0 / 45%) → white 45% opacity
  static const Color glass = Color(0x73FFFFFF);

  /// --glass-strong: oklch(1 0 0 / 62%) → white 62% opacity (hover/active)
  static const Color glassStrong = Color(0x9EFFFFFF);

  /// --glass-border: oklch(1 0 0 / 75%) → white 75% for subtle border
  static const Color glassBorder = Color(0xBFFFFFFF);

  // ── Status ──────────────────────────────────────────────────────────────────
  /// --positive: oklch(0.6 0.15 152) → green positive
  static const Color positive = Color(0xFF22C55E);

  /// --negative: oklch(0.58 0.18 25) → amber/red negative
  static const Color negative = Color(0xFFEF4444);

  // ── Gradients ────────────────────────────────────────────────────────────────
  /// CTA gradient: emerald → cyan (120deg)
  static const LinearGradient ctaGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF06B6D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Hero text gradient: forest → emerald → cyan
  static const LinearGradient textGradient = LinearGradient(
    colors: [Color(0xFF065F46), Color(0xFF059669), Color(0xFF0891B2)],
    begin: Alignment.topLeft,
    end: Alignment.centerRight,
  );

  /// Background overlay: the semi-transparent white/green wash over the farm photo
  /// linear-gradient(180deg, white/55%, green-tinted/62%, white/55%)
  static const LinearGradient bgOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x8CFFFFFF),   // white 55%
      Color(0x9EF0FDF4),   // tinted light-green 62%
      Color(0x8CFFFFFF),   // white 55%
    ],
    stops: [0.0, 0.55, 1.0],
  );

  // ── Shadows ──────────────────────────────────────────────────────────────────
  /// --shadow-glass
  static List<BoxShadow> get shadowGlass => [
    BoxShadow(
      color: const Color(0xFF065F46).withValues(alpha: 0.35),
      blurRadius: 50,
      spreadRadius: -20,
      offset: const Offset(0, 20),
    ),
    BoxShadow(
      color: const Color(0xFF065F46).withValues(alpha: 0.20),
      blurRadius: 10,
      spreadRadius: -4,
      offset: const Offset(0, 2),
    ),
  ];

  /// --shadow-float (used on hover / elevation)
  static List<BoxShadow> get shadowFloat => [
    BoxShadow(
      color: const Color(0xFF065F46).withValues(alpha: 0.45),
      blurRadius: 70,
      spreadRadius: -25,
      offset: const Offset(0, 30),
    ),
  ];

  /// --shadow-glow (used on CTA buttons)
  static List<BoxShadow> get shadowGlow => [
    BoxShadow(
      color: const Color(0xFF10B981).withValues(alpha: 0.60),
      blurRadius: 40,
      spreadRadius: -10,
      offset: const Offset(0, 14),
    ),
  ];

  // ── Typography ────────────────────────────────────────────────────────────────
  /// Display font (headings): Outfit
  static const String fontDisplay = 'Outfit';

  /// Body font: Plus Jakarta Sans
  static const String fontBody = 'PlusJakartaSans';

  // ── Background Image ──────────────────────────────────────────────────────────
  static const String bgImageUrl =
      'https://images.unsplash.com/photo-1574943320219-553eb213f72d?auto=format&fit=crop&w=2400&q=80';

  static const String avatarUrl =
      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80';
}
