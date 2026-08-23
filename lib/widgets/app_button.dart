import 'package:flutter/material.dart';
import '../utils/utils.dart';

class AppButton extends StatelessWidget {
  final String? text;
  final String? label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool isFullWidth;
  final double? width;
  final bool isOutlined;
  final Color? backgroundColor;
  final Color? textColor;

  const AppButton({
    super.key,
    this.text,
    this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.isFullWidth = true,
    this.width,
    this.isOutlined = false,
    this.backgroundColor,
    this.textColor,
  });

  String get _buttonText => text ?? label ?? '';

  @override
  Widget build(BuildContext context) {
    final effectiveBg = backgroundColor ?? (isOutlined ? Colors.transparent : AppColors.primary);
    final effectiveFg = textColor ?? (isOutlined ? AppColors.primary : AppColors.textOnPrimary);

    final childWidget = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(effectiveFg),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: effectiveFg),
                const SizedBox(width: 8),
              ],
              Text(
                _buttonText,
                style: AppTextStyles.button.copyWith(color: effectiveFg),
              ),
            ],
          );

    final btnStyle = ElevatedButton.styleFrom(
      backgroundColor: effectiveBg,
      foregroundColor: effectiveFg,
      elevation: isOutlined ? 0 : 4,
      shadowColor: AppColors.primaryGlow,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: isOutlined
            ? BorderSide(color: backgroundColor ?? AppColors.primary, width: 1.5)
            : BorderSide.none,
      ),
    );

    final buttonWidget = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: btnStyle,
      child: childWidget,
    );

    if (width != null) {
      return SizedBox(
        width: width,
        child: buttonWidget,
      );
    }

    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        child: buttonWidget,
      );
    }

    return buttonWidget;
  }
}
