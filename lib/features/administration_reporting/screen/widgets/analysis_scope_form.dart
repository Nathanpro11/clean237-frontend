import 'package:flutter/material.dart';

import '../../../../common/styles/app_colors.dart';
import '../../../../common/styles/app_text_styles.dart';
import '../../models/zone_model.dart';
import '../../viewmodels/analysis_form_state.dart';

class AnalysisScopeForm extends StatelessWidget {
  const AnalysisScopeForm({
    super.key,
    required this.zones,
    required this.selectedZoneIds,
    required this.periodPreset,
    required this.periodStart,
    required this.periodEnd,
    required this.periodError,
    required this.zonesError,
    required this.onPeriodPresetChanged,
    required this.onCustomPeriodChanged,
    required this.onZoneToggled,
  });

  final List<Zone> zones;
  final Set<String> selectedZoneIds;
  final AnalysisPeriodPreset periodPreset;
  final DateTime? periodStart;
  final DateTime? periodEnd;
  final String? periodError;
  final String? zonesError;
  final ValueChanged<AnalysisPeriodPreset> onPeriodPresetChanged;
  final void Function(DateTime? start, DateTime? end) onCustomPeriodChanged;
  final ValueChanged<String> onZoneToggled;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Période de l’analyse *', style: AppTextStyles.cardTitle),
      const SizedBox(height: 10),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _periodChip('7 derniers jours', AnalysisPeriodPreset.last7Days),
          _periodChip('30 derniers jours', AnalysisPeriodPreset.last30Days),
          _periodChip('Mois en cours', AnalysisPeriodPreset.currentMonth),
          _periodChip('Personnalisée', AnalysisPeriodPreset.custom),
        ],
      ),
      if (periodPreset == AnalysisPeriodPreset.custom) ...[
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final startButton = _dateButton(
              context,
              date: periodStart,
              label: 'Date de début',
              onPicked: (date) => onCustomPeriodChanged(date, periodEnd),
            );
            final endButton = _dateButton(
              context,
              date: periodEnd,
              label: 'Date de fin',
              onPicked: (date) => onCustomPeriodChanged(periodStart, date),
            );
            if (constraints.maxWidth < 400) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  startButton,
                  const SizedBox(height: 8),
                  endButton,
                ],
              );
            }
            return Row(
              children: [
                Expanded(child: startButton),
                const SizedBox(width: 10),
                Expanded(child: endButton),
              ],
            );
          },
        ),
      ],
      if (periodError != null) ...[
        const SizedBox(height: 8),
        _errorText(periodError!),
      ],
      const SizedBox(height: 24),
      Text('Zones à analyser *', style: AppTextStyles.cardTitle),
      const SizedBox(height: 8),
      if (zonesError != null) ...[
        _errorText(zonesError!),
        const SizedBox(height: 8),
      ],
      ...zones.map((zone) {
        final selected = selectedZoneIds.contains(zone.id);
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.primaryGreen : AppColors.borderLight,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            child: CheckboxListTile(
              value: selected,
              activeColor: AppColors.primaryGreen,
              title: Text(zone.name, style: AppTextStyles.cardTitle),
              subtitle: Text(
                'Score actuel : ${zone.score} pts',
                style: AppTextStyles.bodySecondary,
              ),
              onChanged: (_) => onZoneToggled(zone.id),
            ),
          ),
        );
      }),
    ],
  );

  Widget _periodChip(String label, AnalysisPeriodPreset preset) => ChoiceChip(
    label: Text(label),
    selected: periodPreset == preset,
    onSelected: (_) => onPeriodPresetChanged(preset),
  );

  Widget _dateButton(
    BuildContext context, {
    required DateTime? date,
    required String label,
    required ValueChanged<DateTime> onPicked,
  }) => OutlinedButton.icon(
    onPressed: () async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final picked = await showDatePicker(
        context: context,
        initialDate: date ?? today,
        firstDate: DateTime(2020),
        lastDate: today,
      );
      if (picked != null) onPicked(picked);
    },
    icon: const Icon(Icons.calendar_today_rounded, size: 18),
    label: Text(
      date == null ? label : '${_formatDate(date)} · $label',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    ),
  );

  Widget _errorText(String message) => Text(
    message,
    style: AppTextStyles.body.copyWith(
      color: AppColors.criticalRed,
      fontSize: 12,
      fontWeight: FontWeight.w600,
    ),
  );

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year}';
}
