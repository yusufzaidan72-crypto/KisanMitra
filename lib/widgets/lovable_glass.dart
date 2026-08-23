import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/lovable_colors.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// Faithfully replicates the Lovable `.glass` + `.glass-hover` + `.glass-strong`
/// utility classes in Flutter.
/// ─────────────────────────────────────────────────────────────────────────────
class LovableGlassCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final bool enableHover;
  final VoidCallback? onTap;
  final bool strong;

  const LovableGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.margin,
    this.borderRadius = 24,
    this.enableHover = true,
    this.onTap,
    this.strong = false,
  });

  @override
  State<LovableGlassCard> createState() => _LovableGlassCardState();
}

class _LovableGlassCardState extends State<LovableGlassCard>
    with SingleTickerProviderStateMixin {
  bool _hovered = false;
  late AnimationController _ctrl;
  late Animation<double> _translateY;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    // Matches Lovable: translateY(-4px) scale(1.015) on hover
    _translateY = Tween<double>(begin: 0, end: -4).animate(
      CurvedAnimation(parent: _ctrl, curve: const Cubic(0.22, 1, 0.36, 1)),
    );
    _scale = Tween<double>(begin: 1.0, end: 1.015).animate(
      CurvedAnimation(parent: _ctrl, curve: const Cubic(0.22, 1, 0.36, 1)),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onEnter(_) {
    setState(() => _hovered = true);
    if (widget.enableHover) _ctrl.forward();
  }

  void _onExit(_) {
    setState(() => _hovered = false);
    if (widget.enableHover) _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: _onEnter,
      onExit: _onExit,
      cursor: widget.onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (ctx, child) => Transform.translate(
          offset: Offset(0, _translateY.value),
          child: Transform.scale(
            scale: _scale.value,
            child: child,
          ),
        ),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            margin: widget.margin,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              boxShadow: _hovered ? LovableColors.shadowFloat : LovableColors.shadowGlass,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              child: BackdropFilter(
                // .glass: blur(28px) saturate(160%)  |  .glass-strong: blur(36px) saturate(170%)
                filter: ImageFilter.blur(
                  sigmaX: widget.strong ? 36 : 28,
                  sigmaY: widget.strong ? 36 : 28,
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  padding: widget.padding,
                  decoration: BoxDecoration(
                    color: _hovered
                        ? LovableColors.glassStrong
                        : (widget.strong
                            ? LovableColors.glassStrong
                            : LovableColors.glass),
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    border: Border.all(
                      color: _hovered
                          ? Colors.white.withValues(alpha: 0.95)
                          : LovableColors.glassBorder,
                      width: 1,
                    ),
                  ),
                  child: widget.child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────────────────────────
/// Replicates the .cta-gradient button with glow shadow and hover transform
/// ─────────────────────────────────────────────────────────────────────────────
class CtaButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool isLoading;

  const CtaButton({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.width,
    this.isLoading = false,
  });


  @override
  State<CtaButton> createState() => _CtaButtonState();
}

class _CtaButtonState extends State<CtaButton> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _pressed ? 0.96 : (_hovered ? 1.03 : 1.0),
          duration: const Duration(milliseconds: 300),
          curve: const Cubic(0.22, 1, 0.36, 1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: widget.width,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            decoration: BoxDecoration(
              gradient: LovableColors.ctaGradient,
              borderRadius: BorderRadius.circular(50),
              boxShadow: _hovered
                  ? [
                      BoxShadow(
                        color: const Color(0xFF10B981).withValues(alpha: 0.75),
                        blurRadius: 55,
                        spreadRadius: -12,
                        offset: const Offset(0, 22),
                      ),
                    ]
                  : LovableColors.shadowGlow,
            ),
            child: widget.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisSize: widget.width != null ? MainAxisSize.max : MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        widget.label,
                        style: const TextStyle(
                          fontFamily: 'Outfit',
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ],
                  ),

          ),
        ),
      ),
    );
  }
}

/// Glass outline secondary button
class GlassOutlineButton extends StatefulWidget {
  final String label;
  final IconData? trailingIcon;
  final VoidCallback? onTap;

  const GlassOutlineButton({
    super.key,
    required this.label,
    this.trailingIcon,
    this.onTap,
  });

  @override
  State<GlassOutlineButton> createState() => _GlassOutlineButtonState();
}

class _GlassOutlineButtonState extends State<GlassOutlineButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _hovered ? 1.03 : 1.0,
          duration: const Duration(milliseconds: 300),
          curve: const Cubic(0.22, 1, 0.36, 1),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  color: _hovered ? LovableColors.glassStrong : LovableColors.glass,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: _hovered ? Colors.white : LovableColors.glassBorder,
                  ),
                  boxShadow: LovableColors.shadowGlass,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.label,
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        color: LovableColors.forest,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (widget.trailingIcon != null) ...[
                      const SizedBox(width: 6),
                      Icon(widget.trailingIcon, size: 16, color: LovableColors.forest),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Small inner glass chip (used for weather stats, per-quintal badge, etc.)
class GlassChip extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const GlassChip({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: LovableColors.glass,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: LovableColors.glassBorder, width: 1),
          ),
          child: child,
        ),
      ),
    );
  }
}
