import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../common/navigator/app_routes.dart';
import '../../../common/styles/app_colors.dart';
import '../../../common/styles/app_text_styles.dart';
import '../../../common/widgets/admin_app_header.dart';
import '../../../common/widgets/admin_scaffold.dart';
import '../../../common/widgets/primary_button.dart';
import '../../../common/widgets/responsive_container.dart';
import '../../../data/repositories/admin_repository.dart';
import '../models/analysis_model.dart';
import '../models/report_model.dart';
import '../viewmodels/generate_report_bloc.dart';
import '../viewmodels/generate_report_event.dart';
import '../viewmodels/generate_report_state.dart';
import 'widgets/analysis_report_progress.dart';
import 'widgets/format_selector.dart';
import 'widgets/report_notes_field.dart';
import 'widgets/report_title_field.dart';

class AdminGenerateReportPage extends StatelessWidget {
  const AdminGenerateReportPage({
    super.key,
    this.analysisId,
    this.initialTitle,
    this.initialDescription = '',
    this.initialFormat,
  });

  final String? analysisId;
  final String? initialTitle;
  final String initialDescription;
  final ReportFormat? initialFormat;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (context) => GenerateReportBloc(
      context.read<AdminRepository>(),
      analysisId: analysisId,
      initialTitle: initialTitle,
      initialDescription: initialDescription,
      initialFormat: initialFormat,
    ),
    child: BlocListener<GenerateReportBloc, GenerateReportState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == ReportFormStatus.invalidAnalysis) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? 'Analyse requise.')),
          );
          context.go(AppRoutes.newAnalysis());
        } else if (state.status == ReportFormStatus.success) {
          context.push(
            AppRoutes.exportSuccess(
              title: state.title,
              file: state.generatedFilePath,
            ),
          );
        } else if (state.status == ReportFormStatus.failure &&
            state.errorMessage != null) {
          context.push(
            AppRoutes.exportFailure(
              title: state.title,
              error: state.errorMessage,
              analysisId: state.analysisId,
              description: state.description,
              format: state.format.name,
            ),
          );
        } else if (state.status == ReportFormStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: AppColors.criticalRed,
              content: Text(
                'Veuillez corriger les erreurs indiquées ci-dessus.',
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        }
      },
      child: BlocBuilder<GenerateReportBloc, GenerateReportState>(
        builder: (context, state) {
          final bloc = context.read<GenerateReportBloc>();
          if (state.status == ReportFormStatus.initial ||
              state.status == ReportFormStatus.invalidAnalysis ||
              state.analysis == null) {
            return const AdminScaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          final analysis = state.analysis!;
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
                            description:
                                'Le rapport sera créé à partir de cette analyse.',
                            showBackButton: true,
                            onBack: () {
                              if (context.canPop()) {
                                context.pop();
                              } else {
                                context.go(
                                  AppRoutes.analysisResult(analysis.id),
                                );
                              }
                            },
                          ),
                          const AnalysisReportProgress(reportStep: true),
                          _AnalysisReportSummary(analysis: analysis),
                          const SizedBox(height: 22),
                          ReportTitleField(
                            title: state.title,
                            errorText: state.titleError,
                            onChanged: bloc.setTitle,
                          ),
                          const SizedBox(height: 20),
                          ReportNotesField(
                            notes: state.description,
                            errorText: state.descriptionError,
                            onChanged: bloc.setDescription,
                          ),
                          const SizedBox(height: 22),
                          FormatSelector(
                            selectedFormat: state.format,
                            onChanged: bloc.setFormat,
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  color: AppColors.surfaceWhite,
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  child: ResponsiveContainer(
                    padding: EdgeInsets.zero,
                    child: PrimaryButton(
                      label: state.status == ReportFormStatus.submitting
                          ? 'Génération en cours...'
                          : 'Générer le rapport',
                      isLoading: state.status == ReportFormStatus.submitting,
                      icon: const Icon(
                        Icons.cloud_download_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: state.status == ReportFormStatus.submitting
                          ? null
                          : () => context.read<GenerateReportBloc>().add(
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

class _AnalysisReportSummary extends StatelessWidget {
  const _AnalysisReportSummary({required this.analysis});

  final Analysis analysis;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.primaryGreenLight,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.borderLight),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Analyse associée', style: AppTextStyles.cardTitle),
        const SizedBox(height: 6),
        Text(analysis.type, style: AppTextStyles.body),
        const SizedBox(height: 4),
        Text(
          '${_formatDate(analysis.periodStart)} – '
          '${_formatDate(analysis.periodEnd)}',
          style: AppTextStyles.bodySecondary,
        ),
        const SizedBox(height: 4),
        Text(
          '${analysis.zoneIds.length} zones analysées',
          style: AppTextStyles.bodySecondary,
        ),
      ],
    ),
  );

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year}';
}
