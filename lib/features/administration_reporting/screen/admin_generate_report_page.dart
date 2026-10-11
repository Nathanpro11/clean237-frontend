import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../data/repositories/admin_repository.dart';
import '../../../common/styles/app_colors.dart';
import '../../../common/widgets/admin_app_header.dart';
import '../../../common/widgets/admin_scaffold.dart';
import '../../../common/widgets/primary_button.dart';
import '../../../common/widgets/responsive_container.dart';
import 'widgets/format_selector.dart';
import 'widgets/report_period_selector.dart';
import 'widgets/report_notes_field.dart';
import 'widgets/report_title_field.dart';
import 'widgets/zone_selector.dart';
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

                            ReportTitleField(
                              title: viewModel.title,
                              errorText: viewModel.titleError,
                              onChanged: viewModel.setTitle,
                            ),

                            const SizedBox(height: 22),

                            ZoneSelector(
                              zones: viewModel.availableZones,
                              selectedZoneIds: viewModel.selectedZoneIds,
                              errorText: viewModel.zonesError,
                              onSelectAll: viewModel.selectAllZones,
                              onClear: viewModel.clearZoneSelection,
                              onToggle: viewModel.toggleZone,
                            ),
                            const SizedBox(height: 20),

                            ReportPeriodSelector(
                              selectedPeriod: viewModel.selectedPeriod,
                              isCustomPeriod: viewModel.isCustomPeriod,
                              customStartDate: viewModel.customStartDate,
                              customEndDate: viewModel.customEndDate,
                              dateError: viewModel.dateError,
                              predefinedPeriods:
                                  GenerateReportBloc.predefinedPeriods,
                              onPeriodChanged: viewModel.setPeriod,
                              onCustomPeriodChanged:
                                  viewModel.enableCustomPeriod,
                              onCustomDatesChanged: viewModel.setCustomDates,
                            ),
                            const SizedBox(height: 22),

                            FormatSelector(
                              selectedFormat: viewModel.selectedFormat,
                              onChanged: viewModel.setFormat,
                            ),

                            const SizedBox(height: 22),
                            ReportNotesField(
                              notes: viewModel.notes,
                              errorText: viewModel.notesError,
                              onChanged: viewModel.setNotes,
                            ),

                            const SizedBox(height: 24),
                          ],
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
}
