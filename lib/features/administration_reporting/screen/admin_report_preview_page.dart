import 'package:clean237_frontend/features/administration_reporting/models/report_model.dart';
import 'package:clean237_frontend/features/administration_reporting/models/zone_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../common/navigator/app_routes.dart';
import '../../../data/repositories/admin_repository.dart';
import '../../../common/styles/app_colors.dart';
import '../../../common/styles/app_text_styles.dart';
import '../../../common/widgets/admin_app_header.dart';
import '../../../common/widgets/admin_scaffold.dart';
import '../../../common/widgets/primary_button.dart';
import '../../../common/widgets/responsive_container.dart';
import '../../../common/widgets/secondary_button.dart';
import '../../../common/widgets/status_badge.dart';
import '../viewmodels/export_cubit.dart';
import '../viewmodels/export_state.dart';
import '../viewmodels/reports_cubit.dart';
import '../viewmodels/reports_state.dart';

class AdminReportPreviewPage extends StatelessWidget {
  final String reportId;

  const AdminReportPreviewPage({super.key, required this.reportId});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ReportsCubit(context.read<AdminRepository>()),
        ),
        BlocProvider(create: (_) => ExportCubit()),
      ],
      child: BlocBuilder<ReportsCubit, ReportsState>(
        builder: (context, state) {
          final report = context.read<ReportsCubit>().getReportById(reportId);

          if (report == null) {
            return _buildReportNotFound(context);
          }

          return BlocListener<ExportCubit, ExportState>(
            listenWhen: (previous, current) =>
                previous.status != current.status,
            listener: (context, state) {
              if (state.status == ExportStatus.success) {
                context.push(
                  AppRoutes.exportSuccess(
                    title: report.title,
                    file: state.generatedFilePath,
                  ),
                );
              } else if (state.status == ExportStatus.failure) {
                context.push(AppRoutes.exportFailure(title: report.title));
              }
            },
            child: AdminScaffold(
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
                            ),

                            // Report Header Card
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceWhite,
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: AppColors.borderLight,
                                  width: 1,
                                ),
                                boxShadow: AppColors.cardShadow,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      StatusBadge.normal(
                                        label: report.type.label,
                                      ),
                                      StatusBadge(
                                        label: report.status.label,
                                        variant: BadgeVariant.neutral,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    report.title,
                                    style: AppTextStyles.pageTitle.copyWith(
                                      fontSize: 20,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Émis le ${report.date} · ${report.zoneCount} zones analysées',
                                    style: AppTextStyles.bodySecondary,
                                  ),
                                  if (report.summary.isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppColors.background,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        report.summary,
                                        style: AppTextStyles.body.copyWith(
                                          fontSize: 13,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),
                            SecondaryButton(
                              label: 'Voir l’analyse associée',
                              icon: const Icon(
                                Icons.analytics_outlined,
                                size: 18,
                                color: AppColors.textPrimary,
                              ),
                              onPressed: () => context.push(
                                AppRoutes.analysisResult(report.analysisId),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Zones incluses
                            Text(
                              'Zones et scores audités',
                              style: AppTextStyles.cardTitle.copyWith(
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 12),

                            ...report.zoneNames.map((zoneName) {
                              final zone = context
                                  .read<ReportsCubit>()
                                  .getZoneByName(zoneName);
                              return InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: zone == null
                                    ? null
                                    : () => context.push(
                                        AppRoutes.zoneDetails(zone.id),
                                      ),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceWhite,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: AppColors.borderLight,
                                      width: 1,
                                    ),
                                  ),
                                  child: Wrap(
                                    alignment: WrapAlignment.spaceBetween,
                                    runSpacing: 8,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      Text(
                                        zoneName,
                                        style: AppTextStyles.cardTitle.copyWith(
                                          fontSize: 14,
                                        ),
                                      ),
                                      if (zone != null)
                                        Wrap(
                                          spacing: 8,
                                          crossAxisAlignment:
                                              WrapCrossAlignment.center,
                                          children: [
                                            Text(
                                              '${zone.score}/100',
                                              style: AppTextStyles.cardTitle
                                                  .copyWith(
                                                    fontSize: 14,
                                                    color: zone.score < 50
                                                        ? AppColors.criticalRed
                                                        : AppColors.normalGreen,
                                                  ),
                                            ),
                                            StatusBadge(
                                              label: zone.status.label,
                                              color: zone.score < 50
                                                  ? AppColors.criticalRed
                                                  : AppColors.normalGreen,
                                            ),
                                            const Icon(
                                              Icons.arrow_forward_ios_rounded,
                                              size: 12,
                                              color: AppColors.textSecondary,
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            }),

                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Bottom Button: Exporter PDF
                  BlocBuilder<ExportCubit, ExportState>(
                    builder: (context, exportState) {
                      return Container(
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
                            label: exportState.status == ExportStatus.loading
                                ? 'Exportation en cours...'
                                : 'Télécharger / Exporter PDF',
                            isLoading:
                                exportState.status == ExportStatus.loading,
                            icon: const Icon(
                              Icons.file_download_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: () {
                              context.read<ExportCubit>().startExport(
                                reportTitle: report.title,
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildReportNotFound(BuildContext context) {
    return ResponsiveContainer(
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
            const SizedBox(height: 8),
            Text(
              'Le rapport sélectionné n’existe plus ou a été supprimé.',
              style: AppTextStyles.bodySecondary,
            ),
            const SizedBox(height: 24),
            SecondaryButton(
              label: 'Retourner aux rapports',
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(AppRoutes.reports);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
