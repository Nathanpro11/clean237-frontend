import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../common/navigator/app_routes.dart';
import '../../../common/styles/app_colors.dart';
import '../../../common/styles/app_text_styles.dart';
import '../../../common/widgets/admin_scaffold.dart';
import '../../../common/widgets/app_feedback.dart';
import '../../../common/widgets/primary_button.dart';
import '../../../common/widgets/responsive_container.dart';
import '../../../common/widgets/secondary_button.dart';
import '../../../data/exceptions/app_exception.dart';
import '../../../data/repositories/admin_repository.dart';
import '../../../data/services/report_file_service.dart';
import '../models/report_model.dart';

class AdminExportFailurePage extends StatefulWidget {
  final String title;
  final String? errorMessage;
  final String? retryPath;
  final String? reportId;
  final String? format;

  const AdminExportFailurePage({
    super.key,
    required this.title,
    this.errorMessage,
    this.retryPath,
    this.reportId,
    this.format,
  });

  @override
  State<AdminExportFailurePage> createState() => _AdminExportFailurePageState();
}

class _AdminExportFailurePageState extends State<AdminExportFailurePage> {
  final ReportFileService _fileService = const ReportFileService();
  bool _isRetrying = false;

  Future<void> _retryExport(BuildContext context) async {
    if (_isRetrying) return;
    setState(() => _isRetrying = true);
    try {
      final reportFormat = widget.format == ReportFormat.csv.name
          ? ReportFormat.csv
          : ReportFormat.pdf;
      final bytes = await context.read<AdminRepository>().exportReport(
        widget.reportId!,
        reportFormat,
      );
      final savedFile = await _fileService.save(
        bytes: bytes,
        title: widget.title,
        format: reportFormat,
      );
      if (!context.mounted) return;
      context.go(
        AppRoutes.exportSuccess(
          title: widget.title,
          fileName: savedFile.name,
          filePath: savedFile.path,
          format: reportFormat.name,
        ),
      );
    } on AppException catch (error) {
      if (!context.mounted) return;
      AppFeedback.showError(context, error.message);
    } on Object {
      if (!context.mounted) return;
      AppFeedback.showError(
        context,
        'Impossible d’enregistrer le fichier. Veuillez réessayer.',
      );
    } finally {
      if (mounted) {
        setState(() => _isRetrying = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      body: ResponsiveContainer(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: AppColors.criticalRedLight,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.criticalRed,
                  size: 46,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Échec de l’export',
                style: AppTextStyles.pageTitle.copyWith(fontSize: 24),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                widget.errorMessage ??
                    'Impossible de générer le document pour "${widget.title}". Veuillez vérifier vos paramètres ou réessayer ultérieurement.',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              PrimaryButton(
                label: _isRetrying ? 'Export en cours...' : 'Réessayer',
                isLoading: _isRetrying,
                icon: const Icon(
                  Icons.refresh_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: _isRetrying
                    ? null
                    : (widget.reportId != null
                        ? () => _retryExport(context)
                        : () {
                            if (widget.retryPath != null) {
                              context.go(widget.retryPath!);
                            } else if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go(AppRoutes.newAnalysis());
                            }
                          }),
              ),
              const SizedBox(height: 12),
              SecondaryButton(
                label: 'Retourner aux rapports',
                onPressed: () {
                  context.go(AppRoutes.reports);
                },
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => context.go(AppRoutes.dashboard),
                child: const Text('Aller au tableau de bord'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
