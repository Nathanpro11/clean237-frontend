import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../data/repositories/admin_repository.dart';
import '../../../common/styles/app_colors.dart';
import '../../../common/styles/app_text_styles.dart';
import '../../../common/widgets/admin_app_header.dart';
import '../../../common/widgets/admin_scaffold.dart';
import '../../../common/widgets/primary_button.dart';
import '../../../common/widgets/responsive_container.dart';
import '../viewmodels/generate_report_bloc.dart';
import '../viewmodels/generate_report_event.dart';
import '../viewmodels/generate_report_state.dart';

class AdminGenerateReportPage extends StatefulWidget {
  final String? preselectedZoneId;

  const AdminGenerateReportPage({super.key, this.preselectedZoneId});

  @override
  State<AdminGenerateReportPage> createState() =>
      _AdminGenerateReportPageState();
}

class _AdminGenerateReportPageState extends State<AdminGenerateReportPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GenerateReportBloc(
        context.read<AdminRepository>(),
        preselectedZoneId: widget.preselectedZoneId,
      ),
      child: BlocListener<GenerateReportBloc, GenerateReportState>(
        listenWhen: (previous, current) =>
            previous.submissionStatus != current.submissionStatus,
        listener: (context, state) {
          if (state.submissionStatus == SubmissionStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                backgroundColor: AppColors.primaryGreen,
                content: Text(
                  'Document généré avec succès !',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            );
            context.push(
              '/admin/export/success?title=${Uri.encodeComponent(state.title)}&file=${state.generatedFilePath}',
            );
          } else if (state.submissionStatus == SubmissionStatus.failure) {
            if (state.errorMessage != null) {
              context.push(
                '/admin/export/failure?title=${Uri.encodeComponent(state.title)}&error=${Uri.encodeComponent(state.errorMessage!)}',
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: AppColors.criticalRed,
                  behavior: SnackBarBehavior.floating,
                  content: Text(
                    'Veuillez corriger les erreurs de validation indiquées ci-dessus.',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              );
            }
          }
        },
        child: BlocBuilder<GenerateReportBloc, GenerateReportState>(
          builder: (context, state) {
            final viewModel = context.read<GenerateReportBloc>();
            return AdminScaffold(
              body: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: ResponsiveContainer(
                        child: Form(
                          key: _formKey,
                          autovalidateMode: viewModel.hasSubmittedOnce
                              ? AutovalidateMode.onUserInteraction
                              : AutovalidateMode.disabled,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AdminAppHeader(
                                title: 'Nouveau rapport',
                                subtitle: 'Clean237 · Administration',
                                description: 'Configurez et validez les paramètres de votre export.',
                                showBackButton: true,
                                onBack: () {
                                  if (context.canPop()) {
                                    context.pop();
                                  } else {
                                    context.go('/admin/reports');
                                  }
                                },
                              ),

                              // CHAMP 1 : TITRE DU RAPPORT (Validation obligatoire)
                              Text(
                                'Titre du rapport *',
                                style: AppTextStyles.cardTitle.copyWith(
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                initialValue: viewModel.title,
                                onChanged: viewModel.setTitle,
                                validator: (_) => viewModel.titleError,
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.textPrimary,
                                  fontSize: 14,
                                ),
                                decoration: InputDecoration(
                                  hintText:
                                      'Ex: Bilan mensuel propreté septembre',
                                  filled: true,
                                  fillColor: AppColors.surfaceWhite,
                                  prefixIcon: const Icon(
                                    Icons.edit_note_rounded,
                                    color: AppColors.primaryGreen,
                                  ),
                                  errorText: viewModel.titleError,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(
                                      color: AppColors.borderLight,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(
                                      color: AppColors.borderLight,
                                    ),
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

                              const SizedBox(height: 22),

                              // CHAMP 2 : SÉLECTION DES ZONES (Validation au moins 1 zone)
                              Wrap(
                                alignment: WrapAlignment.spaceBetween,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                runSpacing: 4,
                                children: [
                                  Text(
                                    'Sélection des zones auditées *',
                                    style: AppTextStyles.cardTitle.copyWith(
                                      fontSize: 15,
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextButton(
                                        onPressed: viewModel.selectAllZones,
                                        child: const Text('Tout'),
                                      ),
                                      TextButton(
                                        onPressed: viewModel.clearZoneSelection,
                                        child: const Text('Effacer'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),

                              // Alerte de validation zones
                              if (viewModel.zonesError != null) ...[
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.criticalRedLight,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.criticalRed.withValues(
                                        alpha: 0.4,
                                      ),
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
                                          viewModel.zonesError!,
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

                              ...viewModel.availableZones.take(6).map((zone) {
                                final isChecked = viewModel.selectedZoneIds
                                    .contains(zone.id);
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
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                          ),
                                      value: isChecked,
                                      activeColor: AppColors.primaryGreen,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      title: Text(
                                        zone.name,
                                        style: AppTextStyles.cardTitle.copyWith(
                                          fontSize: 14,
                                          fontWeight: isChecked
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                        ),
                                      ),
                                      subtitle: Text(
                                        'Score : ${zone.score}/100 · ${zone.status.name}',
                                        style: AppTextStyles.bodySecondary
                                            .copyWith(fontSize: 12),
                                      ),
                                      onChanged: (_) =>
                                          viewModel.toggleZone(zone.id),
                                    ),
                                  ),
                                );
                              }),

                              const SizedBox(height: 20),

                              // CHAMP 3 : PÉRIODE DU RAPPORT ET PLAGE PERSONNALISÉE
                              Text(
                                'Période couverte *',
                                style: AppTextStyles.cardTitle.copyWith(
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 10),

                              // Sélecteur Type de période
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  ChoiceChip(
                                    label: const Text('Période standard'),
                                    selected: !viewModel.isCustomPeriod,
                                    onSelected: (selected) {
                                      if (selected) {
                                        viewModel.enableCustomPeriod(false);
                                      }
                                    },
                                  ),
                                  ChoiceChip(
                                    label: const Text('Dates personnalisées'),
                                    selected: viewModel.isCustomPeriod,
                                    onSelected: (selected) {
                                      if (selected) {
                                        viewModel.enableCustomPeriod(true);
                                      }
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              if (!viewModel.isCustomPeriod)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceWhite,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: AppColors.borderLight,
                                      width: 1,
                                    ),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      isExpanded: true,
                                      value: viewModel.selectedPeriod,
                                      items: GenerateReportBloc
                                          .predefinedPeriods
                                          .map((p) {
                                            return DropdownMenuItem<String>(
                                              value: p,
                                              child: Text(
                                                p,
                                                style: AppTextStyles.body
                                                    .copyWith(
                                                      color:
                                                          AppColors.textPrimary,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                              ),
                                            );
                                          })
                                          .toList(),
                                      onChanged: (val) {
                                        if (val != null) {
                                          viewModel.setPeriod(val);
                                        }
                                      },
                                    ),
                                  ),
                                )
                              else ...[
                                // Plage de dates avec DatePicker
                                _buildCustomDatePicker(context),
                                if (viewModel.dateError != null) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    viewModel.dateError!,
                                    style: AppTextStyles.body.copyWith(
                                      color: AppColors.criticalRed,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ],

                              const SizedBox(height: 22),

                              // CHAMP 4 : FORMAT DU DOCUMENT
                              Text(
                                'Format d’export',
                                style: AppTextStyles.cardTitle.copyWith(
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: ExportDocumentFormat.values.map((
                                  format,
                                ) {
                                  final isSelected =
                                      viewModel.selectedFormat == format;
                                  return Expanded(
                                    child: GestureDetector(
                                      onTap: () => viewModel.setFormat(format),
                                      child: Container(
                                        margin: const EdgeInsets.only(right: 8),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? AppColors.primaryGreenLight
                                              : AppColors.surfaceWhite,
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
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
                                              style: AppTextStyles.cardTitle
                                                  .copyWith(
                                                    fontSize: 12.5,
                                                    color: isSelected
                                                        ? AppColors
                                                              .primaryGreenDark
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

                              const SizedBox(height: 22),

                              // CHAMP 5 : OBSERVATIONS ET NOTES
                              Wrap(
                                alignment: WrapAlignment.spaceBetween,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                runSpacing: 4,
                                children: [
                                  Text(
                                    'Notes & Observations (optionnel)',
                                    style: AppTextStyles.cardTitle.copyWith(
                                      fontSize: 15,
                                    ),
                                  ),
                                  Text(
                                    '${viewModel.notes.length}/300',
                                    style: AppTextStyles.bodySecondary.copyWith(
                                      fontSize: 12,
                                      color: viewModel.notes.length > 300
                                          ? AppColors.criticalRed
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                initialValue: viewModel.notes,
                                maxLines: 3,
                                maxLength: 300,
                                onChanged: viewModel.setNotes,
                                buildCounter: (
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
                                  errorText: viewModel.notesError,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(
                                      color: AppColors.borderLight,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(
                                      color: AppColors.borderLight,
                                    ),
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

                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Bouton Soumission avec feedback de validation client
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceWhite,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    child: ResponsiveContainer(
                      padding: EdgeInsets.zero,
                      child: PrimaryButton(
                        label: viewModel.isExporting
                            ? 'Génération en cours...'
                            : 'Générer le rapport',
                        isLoading: viewModel.isExporting,
                        icon: const Icon(
                          Icons.cloud_download_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () => context.read<GenerateReportBloc>().add(
                          const SubmitPressed(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCustomDatePicker(BuildContext context) {
    final viewModel = context.read<GenerateReportBloc>();
    final startStr = viewModel.customStartDate != null
        ? '${viewModel.customStartDate!.day.toString().padLeft(2, '0')}/${viewModel.customStartDate!.month.toString().padLeft(2, '0')}/${viewModel.customStartDate!.year}'
        : 'Date début';

    final endStr = viewModel.customEndDate != null
        ? '${viewModel.customEndDate!.day.toString().padLeft(2, '0')}/${viewModel.customEndDate!.month.toString().padLeft(2, '0')}/${viewModel.customEndDate!.year}'
        : 'Date fin';

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
            startStr,
            style: AppTextStyles.body.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: viewModel.customStartDate ?? DateTime.now(),
              firstDate: DateTime(2024),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              viewModel.setCustomDates(picked, viewModel.customEndDate);
            }
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
            endStr,
            style: AppTextStyles.body.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: viewModel.customEndDate ?? DateTime.now(),
              firstDate: DateTime(2024),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              viewModel.setCustomDates(viewModel.customStartDate, picked);
            }
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
}
