import 'package:flutter/material.dart';

import '../styles/app_colors.dart';
import '../styles/app_text_styles.dart';

enum BadgeVariant { filled, outlined, neutral, count }

class StatusBadge extends StatelessWidget {
  final String label;
  final Color? color;
  final BadgeVariant variant;

  const StatusBadge({
    super.key,
    required this.label,
    this.color,
    this.variant = BadgeVariant.filled,
  });

  factory StatusBadge.critical({
    Key? key,
    String label = 'Critique',
    BadgeVariant variant = BadgeVariant.filled,
  }) {
    return StatusBadge(
      key: key,
      label: label,
      color: AppColors.criticalRed,
      variant: variant,
    );
  }

  factory StatusBadge.warning({
    Key? key,
    String label = 'À surveiller',
    BadgeVariant variant = BadgeVariant.filled,
  }) {
    return StatusBadge(
      key: key,
      label: label,
      color: AppColors.warningOrange,
      variant: variant,
    );
  }

  factory StatusBadge.normal({
    Key? key,
    String label = 'Normal',
    BadgeVariant variant = BadgeVariant.filled,
  }) {
    return StatusBadge(
      key: key,
      label: label,
      color: AppColors.normalGreen,
      variant: variant,
    );
  }

  factory StatusBadge.count({Key? key, required String label}) {
    return StatusBadge(key: key, label: label, variant: BadgeVariant.count);
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.textSecondary;

    Color bg;
    Color textColor;
    Border? border;

    switch (variant) {
      case BadgeVariant.filled:
        if (effectiveColor == AppColors.criticalRed) {
          bg = AppColors.criticalRedLight;
          textColor = AppColors.criticalRed;
        } else if (effectiveColor == AppColors.warningOrange) {
          bg = AppColors.warningOrangeLight;
          textColor = AppColors.warningOrange;
        } else if (effectiveColor == AppColors.normalGreen) {
          bg = AppColors.normalGreenLight;
          textColor = AppColors.normalGreen;
        } else {
          bg = AppColors.borderSubtle;
          textColor = effectiveColor;
        }
        border = null;
        break;

      case BadgeVariant.outlined:
        bg = Colors.transparent;
        textColor = effectiveColor;
        border = Border.all(color: effectiveColor, width: 1.2);
        break;

      case BadgeVariant.neutral:
        bg = Colors.transparent;
        textColor = AppColors.textSecondary;
        border = Border.all(color: AppColors.borderLight, width: 1.2);
        break;

      case BadgeVariant.count:
        bg = Colors.white;
        textColor = AppColors.textSecondary;
        border = Border.all(color: AppColors.borderLight, width: 1);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(30),
        border: border,
      ),
      child: Text(
        label,
        style: AppTextStyles.badge.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
