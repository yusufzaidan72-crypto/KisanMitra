import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

/// Glassmorphism Card Component with Blur, Gradient Borders, and Glow Effects
class GlassCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blur;
  final Color? backgroundColor;
  final Color? borderColor;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.margin,
    this.borderRadius = 20,
    this.blur = 12,
    this.backgroundColor,
    this.borderColor,
    this.onTap,
  });

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin ?? const EdgeInsets.symmetric(vertical: 8),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: (widget.borderColor ?? AppColors.primary).withValues(alpha: 0.25),
                      blurRadius: 20,
                      spreadRadius: 2,
                    )
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 10,
                      spreadRadius: 0,
                      offset: const Offset(0, 4),
                    )
                  ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: widget.blur,
                sigmaY: widget.blur,
              ),
              child: GestureDetector(
                onTap: widget.onTap,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: widget.padding,
                  decoration: BoxDecoration(
                    color: _isHovered
                        ? (widget.backgroundColor ?? AppColors.glassSurfaceHover)
                        : (widget.backgroundColor ?? AppColors.glassSurface),
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    border: Border.all(
                      color: _isHovered
                          ? (widget.borderColor ?? AppColors.primary)
                          : (widget.borderColor ?? AppColors.glassBorder),
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
