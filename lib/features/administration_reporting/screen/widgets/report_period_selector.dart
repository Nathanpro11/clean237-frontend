import 'package:flutter/material.dart';

import '../../../../common/styles/app_colors.dart';
import '../../../../common/styles/app_text_styles.dart';

class ReportPeriodSelector extends StatelessWidget {
  const ReportPeriodSelector({
    super.key,
    required this.selectedPeriod,
    required this.isCustomPeriod,
    required this.customStartDate,
    required this.customEndDate,
    required this.dateError,
    required this.predefinedPeriods,
    required this.onPeriodChanged,
    required this.onCustomPeriodChanged,
    required this.onCustomDatesChanged,
  });

  final String selectedPeriod;
  final bool isCustomPeriod;
  final DateTime? customStartDate;
  final DateTime? customEndDate;
  final String? dateError;
  final List<String> predefinedPeriods;
  final ValueChanged<String> onPeriodChanged;
  final ValueChanged<bool> onCustomPeriodChanged;
  final void Function(DateTime? startDate, DateTime? endDate)
  onCustomDatesChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Période couverte *',
        style: AppTextStyles.cardTitle.copyWith(fontSize: 15),
      ),
      const SizedBox(height: 10),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          ChoiceChip(
            label: const Text('Période standard'),
            selected: !isCustomPeriod,
            onSelected: (selected) {
              if (selected) onCustomPeriodChanged(false);
            },
          ),
          ChoiceChip(
            label: const Text('Dates personnalisées'),
            selected: isCustomPeriod,
            onSelected: (selected) {
              if (selected) onCustomPeriodChanged(true);
            },
          ),
        ],
      ),
      const SizedBox(height: 12),
      if (!isCustomPeriod)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight, width: 1),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: selectedPeriod,
              items: predefinedPeriods
                  .map(
                    (period) => DropdownMenuItem<String>(
                      value: period,
                      child: Text(
                        period,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (period) {
                if (period != null) onPeriodChanged(period);
              },
            ),
          ),
        )
      else ...[
        _CustomDatePicker(
          startDate: customStartDate,
          endDate: customEndDate,
          onChanged: onCustomDatesChanged,
        ),
        if (dateError != null) ...[
          const SizedBox(height: 6),
          Text(
            dateError!,
            style: AppTextStyles.body.copyWith(
              color: AppColors.criticalRed,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    ],
  );
}

class _CustomDatePicker extends StatelessWidget {
  const _CustomDatePicker({
    required this.startDate,
    required this.endDate,
    required this.onChanged,
  });

  final DateTime? startDate;
  final DateTime? endDate;
  final void Function(DateTime? startDate, DateTime? endDate) onChanged;

  @override
  Widget build(BuildContext context) {
    final startLabel = startDate == null
        ? 'Date début'
        : _formatDate(startDate!);
    final endLabel = endDate == null ? 'Date fin' : _formatDate(endDate!);

    return LayoutBuilder(
      builder: (context, constraints) {
        final startButton = OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            side: const BorderSide(color: AppColors.borderLight),
          ),
          icon: const Icon(
            Icons.date_range_rounded,
            color: AppColors.primaryGreen,
            size: 18,
          ),
          label: Text(
            startLabel,
            style: AppTextStyles.body.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: startDate ?? DateTime.now(),
              firstDate: DateTime(2024),
              lastDate: DateTime.now(),
            );
            if (picked != null) onChanged(picked, endDate);
          },
        );
        final endButton = OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            side: const BorderSide(color: AppColors.borderLight),
          ),
          icon: const Icon(
            Icons.event_available_rounded,
            color: AppColors.primaryGreen,
            size: 18,
          ),
          label: Text(
            endLabel,
            style: AppTextStyles.body.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: endDate ?? DateTime.now(),
              firstDate: DateTime(2024),
              lastDate: DateTime.now(),
            );
            if (picked != null) onChanged(startDate, picked);
          },
        );

        if (constraints.maxWidth < 400) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [startButton, const SizedBox(height: 8), endButton],
          );
        }

        return Row(
          children: [
            Expanded(child: startButton),
            const SizedBox(width: 10),
            const Icon(
              Icons.arrow_forward_rounded,
              size: 16,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 10),
            Expanded(child: endButton),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year}';
}
