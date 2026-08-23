import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Gradient? gradient;
  final double? elevation;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final Border? border;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.gradient,
    this.elevation,
    this.borderRadius,
    this.onTap,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final br = borderRadius ?? BorderRadius.circular(16);
    final borderStyle = border ?? Border.all(color: AppColors.border.withValues(alpha: 0.5), width: 1);

    Widget card = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: gradient == null ? (backgroundColor ?? Colors.white) : null,
        gradient: gradient,
        borderRadius: br,
        border: gradient != null ? null : borderStyle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.05),
            blurRadius: 16,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: br,
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      card = Material(
        color: Colors.transparent,
        borderRadius: br,
        child: InkWell(
          borderRadius: br,
          onTap: onTap,
          splashColor: AppColors.primaryLight.withValues(alpha: 0.12),
          highlightColor: AppColors.primarySurface.withValues(alpha: 0.2),
          child: card,
        ),
      );
    }
    return card;
  }
}
