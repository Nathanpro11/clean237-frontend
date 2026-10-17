import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../common/navigator/app_routes.dart';
import '../../../common/styles/app_colors.dart';
import '../../../common/styles/app_text_styles.dart';
import '../../../common/widgets/admin_app_header.dart';
import '../../../common/widgets/admin_scaffold.dart';
import '../../../common/widgets/app_feedback.dart';
import '../../../common/widgets/error_state.dart';
import '../../../common/widgets/primary_button.dart';
import '../../../common/widgets/responsive_container.dart';
import '../../../common/widgets/secondary_button.dart';
import '../../../common/widgets/status_badge.dart';
import '../../../data/exceptions/app_exception.dart';
import '../../../data/repositories/admin_repository.dart';
import '../models/analysis_model.dart';
import '../models/report_model.dart';
import '../viewmodels/export_cubit.dart';
import '../viewmodels/export_state.dart';
import '../viewmodels/reports_cubit.dart';
import '../viewmodels/reports_state.dart';

class AdminReportPreviewPage extends StatelessWidget {
  const AdminReportPreviewPage({super.key, required this.reportId});

  final String reportId;

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (context) => ReportsCubit(
          context.read<AdminRepository>(),
          loadOnCreate: false,
        )..loadReport(reportId),
      ),
      BlocProvider(
        create: (context) => ExportCubit(context.read<AdminRepository>()),
      ),
    ],
    child: BlocListener<ExportCubit, ExportState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, exportState) {
        final report = context.read<ReportsCubit>().state.reportDetails;
        if (report == null) return;
        if (exportState.status == ExportStatus.success) {
          context.push(
            AppRoutes.exportSuccess(
              title: report.title,
              fileName: exportState.generatedFileName,
              filePath: exportState.generatedFilePath,
              format: report.format.name,
            ),
          );
        } else if (exportState.status == ExportStatus.failure) {
          context.push(
            AppRoutes.exportFailure(
              title: report.title,
              error: exportState.errorMessage,
              reportId: report.id,
              format: report.format.name,
            ),
          );
        }
      },
      child: BlocBuilder<ReportsCubit, ReportsState>(
        builder: (context, state) {
          final cubit = context.read<ReportsCubit>();
          if (state.status == ReportsStatus.loading ||
              state.status == ReportsStatus.initial) {
            return const AdminScaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (state.status == ReportsStatus.failure) {
            return AdminScaffold(
              body: ErrorState(
                message: state.errorMessage ?? 'Erreur de chargement.',
                onRetry: () => cubit.loadReport(reportId),
              ),
            );
          }
          final report = state.reportDetails;
          if (report == null) return _buildReportNotFound(context);
          return _buildReport(context, report);
        },
      ),
    ),
  );

  Widget _buildReport(BuildContext context, AdminReport report) {
    final exportState = context.watch<ExportCubit>().state;
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
                      title: 'Aperçu du rapport',
                      subtitle: 'Clean237 · Administration',
                      showBackButton: true,
                      onBack: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go(AppRoutes.reports);
                        }
                      },
                      trailing: IconButton(
                        tooltip: 'Supprimer le rapport',
                        onPressed: () => _confirmDelete(context, report),
                        icon: const Icon(Icons.delete_outline_rounded),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceWhite,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: AppColors.borderLight),
                        boxShadow: AppColors.cardShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              StatusBadge.normal(label: report.typeName),
                              StatusBadge(
                                label: report.status.label,
                                variant: BadgeVariant.neutral,
                              ),
                              StatusBadge(
                                label: report.format.label,
                                variant: BadgeVariant.neutral,
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            report.title,
                            style: AppTextStyles.pageTitle.copyWith(fontSize: 20),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Créé le ${report.date}',
                            style: AppTextStyles.bodySecondary,
                          ),
                          if (report.description?.isNotEmpty ?? false) ...[
                            const SizedBox(height: 12),
                            Text(report.description!, style: AppTextStyles.body),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (report.status != ReportStatus.archived)
                          SecondaryButton(
                            label: 'Archiver',
                            onPressed: () => _setStatus(
                              context,
                              report,
                              ReportStatus.archived,
                            ),
                          )
                        else
                          SecondaryButton(
                            label: 'Réactiver',
                            onPressed: () => _setStatus(
                              context,
                              report,
                              ReportStatus.ready,
                            ),
                          ),
                        if (report.analysisId != null)
                          SecondaryButton(
                            label: 'Voir l’analyse associée',
                            icon: const Icon(
                              Icons.analytics_outlined,
                              size: 18,
                              color: AppColors.textPrimary,
                            ),
                            onPressed: () => context.push(
                              AppRoutes.analysisResult(report.analysisId!),
                            ),
                          ),
                      ],
                    ),
                    if (report.zones.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Text('Zones du rapport', style: AppTextStyles.cardTitle),
                      const SizedBox(height: 10),
                      ...report.zones.map(
                        (zone) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(zone.name),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () => context.push(
                            AppRoutes.zoneDetails(zone.id),
                          ),
                        ),
                      ),
                    ],
                    if (report.indicators != null) ...[
                      const SizedBox(height: 18),
                      Text('Indicateurs', style: AppTextStyles.cardTitle),
                      const SizedBox(height: 8),
                      _ReportIndicators(indicators: report.indicators!),
                    ],
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PrimaryButton(
                    label: exportState.status == ExportStatus.loading
                        ? 'Exportation en cours...'
                        : 'Télécharger / Exporter ${report.format.name.toUpperCase()}',
                    isLoading: exportState.status == ExportStatus.loading,
                    icon: const Icon(
                      Icons.file_download_rounded,
                      color: Colors.white,
                    ),
                    onPressed: report.format == ReportFormat.excel ||
                            exportState.status == ExportStatus.loading
                        ? null
                        : () => context.read<ExportCubit>().startExport(
                            reportId: report.id,
                            reportTitle: report.title,
                            format: report.format,
                          ),
                  ),
                  if (exportState.generatedFilePath != null) ...[
                    const SizedBox(height: 8),
                    SecondaryButton(
                      label: 'Ouvrir le fichier téléchargé',
                      onPressed: context.read<ExportCubit>().openExportedFile,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _setStatus(
    BuildContext context,
    AdminReport report,
    ReportStatus status,
  ) async {
    try {
      await context.read<ReportsCubit>().setReportStatus(report.id, status);
      if (context.mounted) {
        AppFeedback.showSuccess(
          context,
          context.read<ReportsCubit>().state.successMessage,
          fallback: 'Statut du rapport mis à jour avec succès.',
        );
      }
    } on AppException catch (error) {
      if (context.mounted) {
        AppFeedback.showError(context, error.message);
      }
    } on Object catch (error) {
      if (context.mounted) {
        AppFeedback.showError(context, error.toString());
      }
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    AdminReport report,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Supprimer le rapport ?'),
        content: Text('Le rapport « ${report.title} » sera supprimé.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      final msg = await context.read<ReportsCubit>().deleteReport(report.id);
      if (context.mounted) {
        AppFeedback.showSuccess(
          context,
          msg,
          fallback: 'Rapport supprimé avec succès.',
        );
        if (context.canPop()) {
          context.pop(true);
        } else {
          context.go(AppRoutes.reports);
        }
      }
    } on AppException catch (error) {
      if (context.mounted) {
        AppFeedback.showError(context, error.message);
      }
    } catch (error) {
      if (context.mounted) {
        final message = switch (error) {
          FormatException e => e.message,
          _ => error.toString().replaceFirst(RegExp(r'^(Exception|Error):\s*'), ''),
        };
        AppFeedback.showError(context, message);
      }
    }
  }

  Widget _buildReportNotFound(BuildContext context) => ResponsiveContainer(
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.description_outlined,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text('Rapport introuvable', style: AppTextStyles.pageTitle),
          const SizedBox(height: 24),
          SecondaryButton(
            label: 'Retourner aux rapports',
            onPressed: () => context.go(AppRoutes.reports),
          ),
        ],
      ),
    ),
  );
}

class _ReportIndicators extends StatelessWidget {
  const _ReportIndicators({required this.indicators});

  final AnalysisIndicators indicators;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (final entry in indicators.byType.entries)
        Card(
          child: ListTile(
            title: Text(entry.key),
            subtitle: Text(
              'Nombre : ${entry.value.count} · Moyenne : ${entry.value.average} '
              '${entry.value.unit ?? ''}',
            ),
            trailing: Text(
              '${entry.value.minimum} – ${entry.value.maximum}',
            ),
          ),
        ),
    ],
  );
}
