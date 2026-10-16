import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:open_filex/open_filex.dart';

import '../../../common/navigator/app_routes.dart';
import '../../../common/styles/app_colors.dart';
import '../../../common/styles/app_text_styles.dart';
import '../../../common/widgets/admin_scaffold.dart';
import '../../../common/widgets/primary_button.dart';
import '../../../common/widgets/responsive_container.dart';
import '../../../common/widgets/secondary_button.dart';

class AdminExportSuccessPage extends StatelessWidget {
  final String title;
  final String? fileName;
  final String? filePath;
  final String format;

  const AdminExportSuccessPage({
    super.key,
    required this.title,
    this.fileName,
    this.filePath,
    this.format = 'pdf',
  });

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
                  color: AppColors.primaryGreenLight,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.primaryGreen,
                  size: 46,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Rapport exporté avec succès',
                style: AppTextStyles.pageTitle.copyWith(fontSize: 24),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                kIsWeb
                    ? 'Fichier téléchargé par votre navigateur.'
                    : 'Le document "$title" a été enregistré sur votre appareil.',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              if (fileName != null) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderLight, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.picture_as_pdf_rounded,
                        color: AppColors.criticalRed,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fileName!,
                              style: AppTextStyles.cardTitle.copyWith(
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (filePath != null &&
                                filePath!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                filePath!,
                                style: AppTextStyles.bodySecondary,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const Spacer(),
              if (!kIsWeb)
                PrimaryButton(
                  label: format == 'csv' ? 'Ouvrir le fichier CSV' : 'Ouvrir le PDF',
                  icon: const Icon(
                    Icons.open_in_new_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: filePath == null
                      ? null
                      : () async {
                          final result = await OpenFilex.open(filePath!);
                          if (!context.mounted) return;
                          if (result.type != ResultType.done) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(result.message)),
                            );
                          }
                        },
                ),
              const SizedBox(height: 12),
              SecondaryButton(
                label: 'Retourner aux rapports',
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  size: 18,
                  color: AppColors.textPrimary,
                ),
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
