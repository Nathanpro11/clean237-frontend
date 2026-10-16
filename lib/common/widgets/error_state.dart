import 'package:flutter/material.dart';

import '../styles/app_colors.dart';
import '../styles/app_text_styles.dart';
import 'primary_button.dart';

class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.message,
    required this.onRetry,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final VoidCallback onRetry;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            size: 44,
            color: AppColors.criticalRed,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: AppTextStyles.body,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 180,
            child: PrimaryButton(
              label: 'Réessayer',
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              onPressed: onRetry,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 8),
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    ),
  );
}
