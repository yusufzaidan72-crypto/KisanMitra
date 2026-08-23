import 'package:flutter/material.dart';
import '../utils/utils.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;
  const LoadingWidget({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.primarySurface,
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(message!, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
          ],
        ],
      ),
    );
  }
}
