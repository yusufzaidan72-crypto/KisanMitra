import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

/// Premium 3D Glassmorphism Card Component
/// Features: Multi-layer blur, hover physics (scale + glow intensification),
/// floating depth shadows, and gradient border animation.
class GlassCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blur;
  final Color? backgroundColor;
  final Color? borderColor;
  final VoidCallback? onTap;
  final bool enableHoverScale;
  final bool enableGlow;
  final double elevation;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.margin,
    this.borderRadius = 24,
    this.blur = 15,
    this.backgroundColor,
    this.borderColor,
    this.onTap,
    this.enableHoverScale = true,
    this.enableGlow = true,
    this.elevation = 1.0,
  });

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.025).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHoverEnter(_) {
    setState(() => _isHovered = true);
    if (widget.enableHoverScale) _controller.forward();
  }

  void _onHoverExit(_) {
    setState(() => _isHovered = false);
    if (widget.enableHoverScale) _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = widget.borderColor ?? AppColors.primary;

    return MouseRegion(
      onEnter: _onHoverEnter,
      onExit: _onHoverExit,
      cursor: widget.onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          margin: widget.margin ?? const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            // Layered floating shadows for 3D depth
            boxShadow: [
              // Deep base shadow for elevation
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.55 * widget.elevation),
                blurRadius: 30 * widget.elevation,
                spreadRadius: 0,
                offset: Offset(0, 14 * widget.elevation),
              ),
              // Ambient diffuse shadow
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25 * widget.elevation),
                blurRadius: 60 * widget.elevation,
                spreadRadius: 4,
                offset: Offset(0, 4 * widget.elevation),
              ),
              // Glow halo on hover
              if (_isHovered && widget.enableGlow)
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.35),
                  blurRadius: 28,
                  spreadRadius: 0,
                  offset: const Offset(0, 0),
                ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: _isHovered ? widget.blur * 1.3 : widget.blur,
                sigmaY: _isHovered ? widget.blur * 1.3 : widget.blur,
              ),
              child: GestureDetector(
                onTap: widget.onTap,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  padding: widget.padding,
                  decoration: BoxDecoration(
                    // Glass surface with subtle colour tint
                    color: _isHovered
                        ? (widget.backgroundColor ?? AppColors.glassSurfaceHover)
                        : (widget.backgroundColor ?? AppColors.glassSurface),
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    // Gradient border for premium depth feel
                    border: Border.all(
                      color: _isHovered
                          ? accentColor.withValues(alpha: 0.7)
                          : accentColor.withValues(alpha: 0.25),
                      width: _isHovered ? 1.5 : 1.0,
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
