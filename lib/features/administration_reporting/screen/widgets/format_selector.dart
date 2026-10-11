import 'package:flutter/material.dart';

import '../../../../common/styles/app_colors.dart';
import '../../../../common/styles/app_text_styles.dart';
import '../../viewmodels/generate_report_event.dart';

class FormatSelector extends StatelessWidget {
  const FormatSelector({
    super.key,
    required this.selectedFormat,
    required this.onChanged,
  });

  final ExportDocumentFormat selectedFormat;
  final ValueChanged<ExportDocumentFormat> onChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Format d’export', style: AppTextStyles.cardTitle.copyWith(fontSize: 15)),
      const SizedBox(height: 10),
      Row(
        children: ExportDocumentFormat.values.map((format) {
          final isSelected = selectedFormat == format;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(format),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryGreenLight
                      : AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryGreen
                        : AppColors.borderLight,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      format == ExportDocumentFormat.pdf
                          ? Icons.picture_as_pdf_rounded
                          : Icons.table_chart_rounded,
                      color: isSelected
                          ? AppColors.primaryGreen
                          : AppColors.textSecondary,
                      size: 22,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      format.label.split(' ')[0],
                      style: AppTextStyles.cardTitle.copyWith(
                        fontSize: 12.5,
                        color: isSelected
                            ? AppColors.primaryGreenDark
                            : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    ],
  );
}
