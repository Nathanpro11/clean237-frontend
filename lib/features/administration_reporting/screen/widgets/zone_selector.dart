import 'package:flutter/material.dart';

import '../../../../common/styles/app_colors.dart';
import '../../../../common/styles/app_text_styles.dart';
import '../../models/zone_model.dart';

class ZoneSelector extends StatelessWidget {
  const ZoneSelector({
    super.key,
    required this.zones,
    required this.selectedZoneIds,
    required this.errorText,
    required this.onSelectAll,
    required this.onClear,
    required this.onToggle,
  });

  final List<Zone> zones;
  final Set<String> selectedZoneIds;
  final String? errorText;
  final VoidCallback onSelectAll;
  final VoidCallback onClear;
  final ValueChanged<String> onToggle;

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
            'Sélection des zones auditées *',
            style: AppTextStyles.cardTitle.copyWith(fontSize: 15),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(onPressed: onSelectAll, child: const Text('Tout')),
              TextButton(onPressed: onClear, child: const Text('Effacer')),
            ],
          ),
        ],
      ),
      const SizedBox(height: 6),
      if (errorText != null) ...[
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.criticalRedLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.criticalRed.withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: AppColors.criticalRed,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  errorText!,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.criticalRed,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
      ],
      ...zones.take(6).map((zone) {
        final isChecked = selectedZoneIds.contains(zone.id);
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isChecked
                  ? AppColors.primaryGreen
                  : AppColors.borderLight,
              width: isChecked ? 1.5 : 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: CheckboxListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              value: isChecked,
              activeColor: AppColors.primaryGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                zone.name,
                style: AppTextStyles.cardTitle.copyWith(
                  fontSize: 14,
                  fontWeight: isChecked ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              subtitle: Text(
                'Score de risque : ${zone.score}/100 · ${zone.status.name}',
                style: AppTextStyles.bodySecondary.copyWith(fontSize: 12),
              ),
              onChanged: (_) => onToggle(zone.id),
            ),
          ),
        );
      }),
    ],
  );
}
