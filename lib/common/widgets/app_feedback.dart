import 'package:flutter/material.dart';

import '../../data/exceptions/app_exception.dart';
import '../styles/app_colors.dart';

class AppFeedback {
  AppFeedback._();

  static void showSuccess(
    BuildContext context,
    String? message, {
    String fallback = 'Opération effectuée avec succès.',
  }) {
    final text = (message != null && message.trim().isNotEmpty)
        ? message.trim()
        : fallback;
    _showSnackBar(
      context,
      message: text,
      backgroundColor: AppColors.primaryGreen,
      icon: Icons.check_circle_rounded,
    );
  }

  static void showError(
    BuildContext context,
    dynamic error, {
    String fallback = 'Une erreur est survenue.',
  }) {
    final String text;
    if (error is AppException) {
      text = error.message.trim().isNotEmpty ? error.message : fallback;
    } else if (error is String && error.trim().isNotEmpty) {
      text = error.trim();
    } else if (error is Object) {
      final str = error.toString().trim();
      text = str.isNotEmpty ? str : fallback;
    } else {
      text = fallback;
    }
    _showSnackBar(
      context,
      message: text,
      backgroundColor: AppColors.criticalRed,
      icon: Icons.error_outline_rounded,
    );
  }

  static void _showSnackBar(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    required IconData icon,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
