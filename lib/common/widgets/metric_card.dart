import 'package:flutter/material.dart';

import '../styles/app_colors.dart';
import '../styles/app_text_styles.dart';

class MetricCard extends StatelessWidget {
  final num count;
  final String title;
  final String subtitle;
  final Color countColor;
  final Color countBgColor;
  final VoidCallback? onTap;

  const MetricCard({
    super.key,
    required this.count,
    required this.title,
    required this.subtitle,
    required this.countColor,
    required this.countBgColor,
    this.onTap,
  });

  factory MetricCard.zones({
    Key? key,
    required int count,
    String subtitle = 'Total des zones',
    VoidCallback? onTap,
  }) {
    return MetricCard(
      key: key,
      count: count,
      title: 'Zones',
      subtitle: subtitle,
      countColor: AppColors.textPrimary,
      countBgColor: const Color(0xFFF1F5F9),
      onTap: onTap,
    );
  }

  factory MetricCard.critical({
    Key? key,
    required int count,
    String subtitle = 'Zones de niveau critique',
    VoidCallback? onTap,
  }) {
    return MetricCard(
      key: key,
      count: count,
      title: 'Critiques',
      subtitle: subtitle,
      countColor: AppColors.criticalRed,
      countBgColor: AppColors.criticalRedLight,
      onTap: onTap,
    );
  }

  factory MetricCard.alerts({
    Key? key,
    required int count,
    String subtitle = 'Alertes actives',
    VoidCallback? onTap,
  }) {
    return MetricCard(
      key: key,
      count: count,
      title: 'Alertes',
      subtitle: subtitle,
      countColor: AppColors.warningOrange,
      countBgColor: AppColors.warningOrangeLight,
      onTap: onTap,
    );
  }

  factory MetricCard.reports({
    Key? key,
    required int count,
    String subtitle = 'Total des rapports',
    VoidCallback? onTap,
  }) {
    return MetricCard(
      key: key,
      count: count,
      title: 'Rapports',
      subtitle: subtitle,
      countColor: AppColors.normalGreen,
      countBgColor: AppColors.normalGreenLight,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isZeroAlertOrCritical =
        count == 0 && (title == 'Critiques' || title == 'Alertes');
    final effectiveCountColor =
        isZeroAlertOrCritical ? AppColors.normalGreen : countColor;
    final effectiveCountBgColor =
        isZeroAlertOrCritical ? AppColors.normalGreenLight : countBgColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderLight, width: 1),
        boxShadow: AppColors.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: effectiveCountBgColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$count',
                    style: AppTextStyles.metricNumber.copyWith(
                      color: effectiveCountColor,
                      fontSize: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(title, style: AppTextStyles.cardTitle),
                      const SizedBox(height: 3),
                      Text(subtitle, style: AppTextStyles.bodySecondary),
                    ],
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
