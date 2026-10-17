import 'package:flutter/material.dart';

import '../../features/administration_reporting/models/report_model.dart';
import '../styles/app_colors.dart';
import '../styles/app_text_styles.dart';
import 'status_badge.dart';

class ReportCard extends StatelessWidget {
  final AdminReport report;
  final VoidCallback? onTap;

  const ReportCard({super.key, required this.report, this.onTap});

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
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row with 2 badges
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTypeBadge(),
                    StatusBadge(
                      label: report.status.label,
                      variant: BadgeVariant.neutral,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Title
                Text(
                  report.title,
                  style: AppTextStyles.cardTitle.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 12),
                // Meta pills
                Row(
                  children: [
                    _buildMetaPill(report.date),
                    const SizedBox(width: 8),
                    _buildMetaPill('${report.zoneCount} zones'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeBadge() {
    switch (report.type) {
      case ReportType.synthesis:
        return StatusBadge.normal(label: 'Synthèse');
      case ReportType.tracking:
        return StatusBadge.warning(label: 'Suivi');
      case ReportType.export:
        return StatusBadge.critical(label: 'Export');
    }
  }

  Widget _buildMetaPill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: AppTextStyles.badge.copyWith(
          color: AppColors.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
