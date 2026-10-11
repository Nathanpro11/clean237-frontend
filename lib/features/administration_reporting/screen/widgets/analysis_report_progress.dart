import 'package:flutter/material.dart';

import '../../../../common/styles/app_colors.dart';
import '../../../../common/styles/app_text_styles.dart';

class AnalysisReportProgress extends StatelessWidget {
  const AnalysisReportProgress({super.key, required this.reportStep});

  final bool reportStep;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 20),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: AppColors.primaryGreenLight,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Text(
      reportStep
          ? '1. Analyse ✓  ›  2. Rapport'
          : '1. Analyse  ›  2. Rapport',
      style: AppTextStyles.cardTitle.copyWith(
        color: AppColors.primaryGreenDark,
        fontSize: 13,
      ),
      textAlign: TextAlign.center,
    ),
  );
}
