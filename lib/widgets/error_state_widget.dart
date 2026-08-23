import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_button.dart';

class ErrorStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  const ErrorStateWidget({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline_rounded, size: 52, color: AppColors.error),
            ),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center, style: AppTextStyles.bodyLarge),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              AppButton(label: 'Retry', onPressed: onRetry, icon: Icons.refresh),
            ],
          ],
        ),
      ),
    );
  }
}
