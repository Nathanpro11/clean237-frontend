import 'package:flutter/material.dart';

import '../../../../common/styles/app_colors.dart';
import '../../../../common/styles/app_text_styles.dart';
import '../../../../common/widgets/status_badge.dart';
import '../../models/zone_model.dart';

class ZoneSummaryCard extends StatelessWidget {
  const ZoneSummaryCard({super.key, required this.zone});

  final Zone zone;

  @override
  Widget build(BuildContext context) {
    final (scoreBackground, scoreTextColor) = switch (zone.status) {
      ZoneStatus.critical => (
        AppColors.criticalRedLight,
        AppColors.criticalRed,
      ),
      ZoneStatus.warning => (
        AppColors.warningOrangeLight,
        AppColors.warningOrange,
      ),
      ZoneStatus.normal => (AppColors.normalGreenLight, AppColors.normalGreen),
    };

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderLight, width: 1),
        boxShadow: AppColors.cardShadow,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: scoreBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${zone.score}',
                  style: AppTextStyles.scoreLarge.copyWith(
                    color: scoreTextColor,
                    fontSize: 26,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      zone.status.label,
                      style: AppTextStyles.cardTitle.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 6),
                    StatusBadge(
                      label: zone.status.label,
                      color: scoreTextColor,
                      variant: BadgeVariant.filled,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _ZoneMetric(
                  label: 'Évolution',
                  value:
                      '${zone.evolutionPoints > 0 ? "+" : ""}'
                      '${zone.evolutionPoints} pts',
                  valueFontSize: 16,
                  valueFontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ZoneMetric(
                  label: 'Dernière mise à jour',
                  value: zone.lastUpdate,
                  valueFontSize: 15,
                  valueFontWeight: FontWeight.w700,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ZoneMetric extends StatelessWidget {
  const _ZoneMetric({
    required this.label,
    required this.value,
    required this.valueFontSize,
    required this.valueFontWeight,
    this.maxLines,
  });

  final String label;
  final String value;
  final double valueFontSize;
  final FontWeight valueFontWeight;
  final int? maxLines;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySecondary.copyWith(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.cardTitle.copyWith(
            fontSize: valueFontSize,
            fontWeight: valueFontWeight,
          ),
          maxLines: maxLines,
          overflow: maxLines == null ? null : TextOverflow.ellipsis,
        ),
      ],
    ),
  );
}
