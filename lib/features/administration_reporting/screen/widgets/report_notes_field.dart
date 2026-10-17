import 'package:flutter/material.dart';

import '../../../../common/styles/app_colors.dart';
import '../../../../common/styles/app_text_styles.dart';
import '../../../../utils/constances/report_constants.dart';

class ReportNotesField extends StatelessWidget {
  const ReportNotesField({
    super.key,
    required this.notes,
    required this.errorText,
    required this.onChanged,
  });

  final String notes;
  final String? errorText;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: 4,
        children: [
          Text(
            'Notes & Observations (optionnel)',
            style: AppTextStyles.cardTitle.copyWith(fontSize: 15),
          ),
          Text(
            '${notes.length}/${ReportConstants.notesMaxLength}',
            style: AppTextStyles.bodySecondary.copyWith(
              fontSize: 12,
              color: notes.length > ReportConstants.notesMaxLength
                  ? AppColors.criticalRed
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      TextFormField(
        initialValue: notes,
        maxLines: 3,
        onChanged: onChanged,
        buildCounter:
            (
              context, {
              required currentLength,
              required isFocused,
              maxLength,
            }) => null,
        style: AppTextStyles.body.copyWith(
          color: AppColors.textPrimary,
          fontSize: 13.5,
        ),
        decoration: InputDecoration(
          hintText: 'Remarques particulières à annexer au rapport...',
          filled: true,
          fillColor: AppColors.surfaceWhite,
          errorText: errorText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.borderLight),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.borderLight),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: AppColors.primaryGreen,
              width: 1.5,
            ),
          ),
        ),
      ),
    ],
  );
}
