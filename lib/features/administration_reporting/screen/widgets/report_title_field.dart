import 'package:flutter/material.dart';

import '../../../../common/styles/app_colors.dart';
import '../../../../common/styles/app_text_styles.dart';

class ReportTitleField extends StatelessWidget {
  const ReportTitleField({
    super.key,
    required this.title,
    required this.errorText,
    required this.onChanged,
  });

  final String title;
  final String? errorText;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Titre du rapport *',
        style: AppTextStyles.cardTitle.copyWith(fontSize: 15),
      ),
      const SizedBox(height: 8),
      TextFormField(
        initialValue: title,
        onChanged: onChanged,
        style: AppTextStyles.body.copyWith(
          color: AppColors.textPrimary,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: 'Ex: Bilan mensuel propreté septembre',
          filled: true,
          fillColor: AppColors.surfaceWhite,
          prefixIcon: const Icon(
            Icons.edit_note_rounded,
            color: AppColors.primaryGreen,
          ),
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
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: AppColors.criticalRed,
              width: 1.5,
            ),
          ),
        ),
      ),
    ],
  );
}
