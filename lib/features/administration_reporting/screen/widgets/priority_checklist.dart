import 'package:flutter/material.dart';

import '../../../../common/styles/app_colors.dart';
import '../../../../common/styles/app_text_styles.dart';

class PriorityChecklist extends StatelessWidget {
  const PriorityChecklist({
    super.key,
    required this.priorities,
    required this.completedPriorities,
    required this.onToggle,
  });

  final List<String> priorities;
  final Set<String> completedPriorities;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'ACTIONS PRIORITAIRES RECOMMANDÉES',
        style: AppTextStyles.sectionLabelGreen,
      ),
      const SizedBox(height: 10),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderLight, width: 1),
        ),
        child: Column(
          children: priorities.map((priority) {
            final isDone = completedPriorities.contains(priority);
            return InkWell(
              onTap: () => onToggle(priority),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Icon(
                      isDone
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: isDone
                          ? AppColors.primaryGreen
                          : AppColors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        priority,
                        style: AppTextStyles.body.copyWith(
                          fontSize: 13.5,
                          decoration: isDone ? TextDecoration.lineThrough : null,
                          color: isDone
                              ? AppColors.textSecondary
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
      const SizedBox(height: 16),
    ],
  );
}
