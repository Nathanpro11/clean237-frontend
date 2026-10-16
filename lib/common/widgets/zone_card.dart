import 'package:flutter/material.dart';

import '../../features/administration_reporting/models/zone_model.dart';
import '../styles/app_colors.dart';
import '../styles/app_text_styles.dart';
import 'status_badge.dart';
import 'zone_score_gauge.dart';

enum ZoneCardVariant { squareScore, circularGauge }

class ZoneCard extends StatelessWidget {
  final Zone zone;
  final VoidCallback? onTap;
  final ZoneCardVariant variant;

  const ZoneCard({
    super.key,
    required this.zone,
    this.onTap,
    this.variant = ZoneCardVariant.squareScore,
  });

  @override
  Widget build(BuildContext context) {
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
                _buildScoreIndicator(),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        zone.name,
                        style: AppTextStyles.cardTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      _buildStatusBadge(),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondary,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScoreIndicator() {
    final risk = ZoneRiskLevel.fromScore(zone.score);

    if (variant == ZoneCardVariant.circularGauge) {
      return ZoneScoreGauge(
        score: zone.score,
        size: 56,
        strokeWidth: 4.5,
        colorOverride: risk.color,
      );
    }

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: risk.backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child: Text(
        '${zone.score}',
        style: AppTextStyles.scoreLarge.copyWith(
          color: risk.color,
          fontSize: 22,
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    final isOutlined = variant == ZoneCardVariant.circularGauge;
    final badgeVariant = isOutlined
        ? BadgeVariant.outlined
        : BadgeVariant.filled;
    final risk = ZoneRiskLevel.fromScore(zone.score);

    switch (risk.status) {
      case ZoneStatus.critical:
        return StatusBadge.critical(variant: badgeVariant);
      case ZoneStatus.warning:
        return StatusBadge.warning(variant: badgeVariant);
      case ZoneStatus.normal:
        return StatusBadge.normal(variant: badgeVariant);
    }
  }
}
