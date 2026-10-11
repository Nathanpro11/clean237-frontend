import 'package:clean237_frontend/features/administration_reporting/models/report_model.dart';
import 'package:clean237_frontend/features/administration_reporting/models/zone_model.dart';
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
import '../../../common/widgets/secondary_button.dart';
import '../../../common/widgets/status_badge.dart';
import '../controller/admin_export_controller.dart';
import '../viewmodels/reports_viewmodel.dart';

class AdminReportPreviewPage extends StatefulWidget {
  final String reportId;

  const AdminReportPreviewPage({super.key, required this.reportId});

  @override
  State<AdminReportPreviewPage> createState() => _AdminReportPreviewPageState();
}

class _AdminReportPreviewPageState extends State<AdminReportPreviewPage> {
  final _exportController = AdminExportController();
  late final ReportsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ReportsViewModel(
      adminRepository: context.read<AdminRepository>(),
    );
  }

  @override
  void dispose() {
    _exportController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final report = _viewModel.getReportById(widget.reportId);

    if (report == null) {
      return _buildReportNotFound(context);
    }

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
                          context.go('/admin/reports');
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              StatusBadge.normal(label: report.type.label),
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

                    // Zones incluses
                    Text(
                      'Zones et scores audités',
                      style: AppTextStyles.cardTitle.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 12),

                    ...report.zoneNames.map((zoneName) {
                      final zone = _viewModel.getZoneByName(zoneName);
                      return InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: zone == null
                            ? null
                            : () => context.push('/admin/zones/${zone.id}'),
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                zoneName,
                                style: AppTextStyles.cardTitle.copyWith(
                                  fontSize: 14,
                                ),
                              ),
                              if (zone != null)
                                Row(
                                  children: [
                                    Text(
                                      '${zone.score}/100',
                                      style: AppTextStyles.cardTitle.copyWith(
                                        fontSize: 14,
                                        color: zone.score < 50
                                            ? AppColors.criticalRed
                                            : AppColors.normalGreen,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    StatusBadge(
                                      label: zone.status.label,
                                      color: zone.score < 50
                                          ? AppColors.criticalRed
                                          : AppColors.normalGreen,
                                    ),
                                    const SizedBox(width: 6),
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
          AnimatedBuilder(
            animation: _exportController,
            builder: (context, _) {
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
                    label: _exportController.isExporting
                        ? 'Exportation en cours...'
                        : 'Télécharger / Exporter PDF',
                    isLoading: _exportController.isExporting,
                    icon: const Icon(
                      Icons.file_download_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () async {
                      final success = await _exportController.startExport(
                        reportTitle: report.title,
                      );
                      if (!context.mounted) return;
                      if (success) {
                        context.push(
                          '/admin/export/success?title=${Uri.encodeComponent(report.title)}&file=${_exportController.generatedFilePath}',
                        );
                      } else {
                        context.push(
                          '/admin/export/failure?title=${Uri.encodeComponent(report.title)}',
                        );
                      }
                    },
                  ),
                ),
              );
            },
          ),
        ],
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
                  context.go('/admin/reports');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
